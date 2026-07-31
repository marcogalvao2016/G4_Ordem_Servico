package com.example.g4_os

import android.Manifest
import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "g4_os/compartilhamento"
    private val logTag = "G4_SHARE"
    private val requestWriteStorage = 7041

    private var pendingBytes: ByteArray? = null
    private var pendingFileName: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "compartilharPdf" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val requestedName = call.argument<String>("nomeArquivo")
                        ?: "ordem_servico.pdf"

                    if (bytes == null || bytes.isEmpty()) {
                        result.error(
                            "EMPTY_PDF",
                            "O PDF não foi recebido ou está vazio.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P &&
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        pendingBytes = bytes
                        pendingFileName = requestedName
                        pendingResult = result

                        Log.e(logTag, "Solicitando permissão para gravar em Downloads.")
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                            requestWriteStorage
                        )
                        return@setMethodCallHandler
                    }

                    executarCompartilhamento(bytes, requestedName, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != requestWriteStorage) return

        val bytes = pendingBytes
        val fileName = pendingFileName
        val result = pendingResult

        pendingBytes = null
        pendingFileName = null
        pendingResult = null

        if (result == null) return

        if (grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED &&
            bytes != null &&
            fileName != null
        ) {
            executarCompartilhamento(bytes, fileName, result)
        } else {
            result.error(
                "STORAGE_PERMISSION_DENIED",
                "É necessário permitir o acesso aos arquivos para salvar o PDF em Downloads/G4OS.",
                null
            )
        }
    }

    private fun executarCompartilhamento(
        bytes: ByteArray,
        requestedName: String,
        result: MethodChannel.Result
    ) {
        try {
            compartilharPdf(bytes, requestedName)
            result.success(null)
        } catch (error: Exception) {
            Log.e(logTag, "Falha ao compartilhar o PDF.", error)
            result.error(
                "SHARE_PDF_ERROR",
                error.message ?: "Falha ao compartilhar o PDF.",
                Log.getStackTraceString(error)
            )
        }
    }

    private fun compartilharPdf(bytes: ByteArray, requestedName: String) {
        Log.e(logTag, "========================================")
        Log.e(logTag, "Iniciando compartilhamento do PDF")
        Log.e(logTag, "Android API: ${Build.VERSION.SDK_INT}")
        Log.e(logTag, "Bytes recebidos: ${bytes.size}")
        Log.e(logTag, "Nome solicitado: $requestedName")

        val safeName = requestedName
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
            .let { if (it.lowercase().endsWith(".pdf")) it else "$it.pdf" }

        val contentUri = salvarEmDownloads(bytes, safeName)

        Log.e(logTag, "URI final: $contentUri")
        validarLeituraDaUri(contentUri, bytes.size.toLong())

        val baseIntent = criarIntentCompartilhamento(contentUri, safeName)
        val whatsappPackages = listOf("com.whatsapp", "com.whatsapp.w4b")
        val whatsappPackage = whatsappPackages.firstOrNull { packageName ->
            Intent(baseIntent).setPackage(packageName)
                .resolveActivity(packageManager) != null
        }

        if (whatsappPackage != null) {
            grantUriPermission(
                whatsappPackage,
                contentUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )

            val whatsappIntent = Intent(baseIntent).apply {
                setPackage(whatsappPackage)
            }

            Log.e(logTag, "Abrindo pacote: $whatsappPackage")
            startActivity(whatsappIntent)
            Log.e(logTag, "Intent enviada ao WhatsApp com sucesso.")
            return
        }

        val targets = packageManager.queryIntentActivities(baseIntent, 0)
        if (targets.isEmpty()) {
            throw IllegalStateException(
                "Nenhum aplicativo disponível para compartilhar arquivos PDF."
            )
        }

        targets.forEach { target ->
            grantUriPermission(
                target.activityInfo.packageName,
                contentUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        }

        val chooser = Intent.createChooser(
            baseIntent,
            "Compartilhar ordem de serviço"
        ).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            clipData = ClipData.newUri(contentResolver, safeName, contentUri)
        }

        Log.e(logTag, "WhatsApp não localizado. Abrindo seletor padrão.")
        startActivity(chooser)
        Log.e(logTag, "Intent enviada ao seletor com sucesso.")
    }

    private fun salvarEmDownloads(bytes: ByteArray, safeName: String): Uri {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            salvarComMediaStore(bytes, safeName)
        } else {
            salvarEmDownloadsLegado(bytes, safeName)
        }
    }

    private fun salvarComMediaStore(bytes: ByteArray, safeName: String): Uri {
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, safeName)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(
                MediaStore.Downloads.RELATIVE_PATH,
                Environment.DIRECTORY_DOWNLOADS + File.separator + "G4OS"
            )
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val collection = MediaStore.Downloads.getContentUri(
            MediaStore.VOLUME_EXTERNAL_PRIMARY
        )
        val uri = contentResolver.insert(collection, values)
            ?: throw IllegalStateException("Não foi possível criar o PDF em Downloads/G4OS.")

        try {
            contentResolver.openOutputStream(uri, "w")?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: throw IllegalStateException("Não foi possível gravar o PDF em Downloads/G4OS.")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)

            Log.e(logTag, "PDF salvo pelo MediaStore em Downloads/G4OS/$safeName")
            return uri
        } catch (error: Exception) {
            contentResolver.delete(uri, null, null)
            throw error
        }
    }

    @Suppress("DEPRECATION")
    private fun salvarEmDownloadsLegado(bytes: ByteArray, safeName: String): Uri {
        val downloads = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        val directory = File(downloads, "G4OS")

        if (!directory.exists() && !directory.mkdirs()) {
            throw IllegalStateException("Não foi possível criar Downloads/G4OS.")
        }

        val pdfFile = File(directory, safeName)
        if (pdfFile.exists() && !pdfFile.delete()) {
            throw IllegalStateException("Não foi possível substituir o PDF anterior.")
        }

        pdfFile.outputStream().buffered().use { output ->
            output.write(bytes)
            output.flush()
        }

        Log.e(logTag, "Arquivo público: ${pdfFile.absolutePath}")
        Log.e(logTag, "Existe: ${pdfFile.exists()}")
        Log.e(logTag, "Tamanho gravado: ${pdfFile.length()}")

        if (!pdfFile.exists() || pdfFile.length() != bytes.size.toLong()) {
            throw IllegalStateException(
                "O PDF não foi gravado corretamente em Downloads/G4OS."
            )
        }

        val authority = "${applicationContext.packageName}.g4_file_provider"
        return FileProvider.getUriForFile(this, authority, pdfFile)
    }

    private fun criarIntentCompartilhamento(
        contentUri: Uri,
        safeName: String
    ): Intent {
        return Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra(Intent.EXTRA_STREAM, contentUri)
            putExtra(Intent.EXTRA_SUBJECT, safeName)
            clipData = ClipData.newUri(contentResolver, safeName, contentUri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
    }

    private fun validarLeituraDaUri(contentUri: Uri, expectedLength: Long) {
        val bytesLidos = contentResolver.openInputStream(contentUri)?.use { input ->
            val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
            var total = 0L

            while (true) {
                val quantidade = input.read(buffer)
                if (quantidade < 0) break
                total += quantidade
            }

            total
        } ?: throw IllegalStateException("Não foi possível abrir a URI do PDF.")

        Log.e(logTag, "Bytes lidos pela URI: $bytesLidos")

        if (bytesLidos != expectedLength) {
            throw IllegalStateException(
                "A URI do PDF não retornou o conteúdo completo. " +
                    "Esperado: $expectedLength; lido: $bytesLidos."
            )
        }
    }
}

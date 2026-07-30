package com.example.g4_os

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "g4_os/compartilhamento"
    private val logTag = "G4_SHARE"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "compartilharPdf" -> {
                    try {
                        val bytes = call.argument<ByteArray>("bytes")
                            ?: throw IllegalArgumentException("PDF não recebido.")
                        val requestedName = call.argument<String>("nomeArquivo")
                            ?: "ordem_servico.pdf"

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

                else -> result.notImplemented()
            }
        }
    }

    private fun compartilharPdf(bytes: ByteArray, requestedName: String) {
        Log.e(logTag, "========================================")
        Log.e(logTag, "Iniciando compartilhamento do PDF")
        Log.e(logTag, "Bytes recebidos: ${bytes.size}")
        Log.e(logTag, "Nome solicitado: $requestedName")

        if (bytes.isEmpty()) {
            throw IllegalArgumentException("O PDF recebido está vazio.")
        }

        val safeName = requestedName
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
            .let { if (it.lowercase().endsWith(".pdf")) it else "$it.pdf" }

        val shareDirectory = File(cacheDir, "shared_pdfs")
        if (!shareDirectory.exists() && !shareDirectory.mkdirs()) {
            throw IllegalStateException("Não foi possível criar a pasta do PDF.")
        }

        val pdfFile = File(shareDirectory, safeName)

        // Recria o arquivo para evitar que um PDF anterior, incompleto ou
        // bloqueado seja reutilizado pelo aplicativo de destino.
        if (pdfFile.exists() && !pdfFile.delete()) {
            throw IllegalStateException("Não foi possível substituir o PDF anterior.")
        }

        pdfFile.outputStream().buffered().use { output ->
            output.write(bytes)
            output.flush()
        }

        Log.e(logTag, "Arquivo: ${pdfFile.absolutePath}")
        Log.e(logTag, "Existe: ${pdfFile.exists()}")
        Log.e(logTag, "Tamanho gravado: ${pdfFile.length()}")
        Log.e(logTag, "Tamanho esperado: ${bytes.size}")

        if (!pdfFile.exists()) {
            throw IllegalStateException("O arquivo PDF não foi criado.")
        }

        if (pdfFile.length() <= 0L) {
            throw IllegalStateException("O arquivo PDF foi criado vazio.")
        }

        if (pdfFile.length() != bytes.size.toLong()) {
            throw IllegalStateException(
                "O arquivo PDF não foi gravado completamente. " +
                    "Esperado: ${bytes.size}; gravado: ${pdfFile.length()}."
            )
        }

        val authority = "${applicationContext.packageName}.g4_file_provider"
        val contentUri = FileProvider.getUriForFile(this, authority, pdfFile)

        Log.e(logTag, "Authority: $authority")
        Log.e(logTag, "URI: $contentUri")

        validarLeituraDaUri(contentUri, bytes.size.toLong())

        val baseIntent = criarIntentCompartilhamento(contentUri, safeName)

        // Envio explícito ao WhatsApp. A permissão é concedida antes da
        // abertura da tela de seleção de contato, inclusive no Android 8.1.
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

        // Caso o WhatsApp não esteja disponível, concede a permissão para
        // todos os aplicativos capazes de receber o PDF e abre o seletor.
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
            clipData = ClipData.newUri(
                contentResolver,
                safeName,
                contentUri
            )
        }

        Log.e(logTag, "WhatsApp não localizado. Abrindo seletor padrão.")
        startActivity(chooser)
        Log.e(logTag, "Intent enviada ao seletor com sucesso.")
    }

    private fun criarIntentCompartilhamento(
        contentUri: Uri,
        safeName: String
    ): Intent {
        return Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra(Intent.EXTRA_STREAM, contentUri)
            clipData = ClipData.newUri(
                contentResolver,
                safeName,
                contentUri
            )
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

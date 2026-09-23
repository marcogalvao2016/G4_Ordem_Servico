import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cliente.dart';
import '../models/empresa.dart';
import '../models/item_atendimento.dart';
import '../models/ordem_servico.dart';
import '../models/ordem_servico_foto.dart';

class RelatorioFotograficoPdfService {
  const RelatorioFotograficoPdfService();

  Future<Uint8List> gerar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoFoto> fotos,
    Empresa? empresa,
  }) async {
    if (fotos.isEmpty) {
      throw StateError('Não existem fotos cadastradas nesta Ordem de Serviço.');
    }

    final fotosValidas = <_FotoPdf>[];
    for (final foto in fotos.take(6)) {
      final arquivo = File(foto.caminhoArquivo);
      if (!await arquivo.exists()) continue;
      final bytes = await arquivo.readAsBytes();
      if (bytes.isEmpty) continue;
      fotosValidas.add(_FotoPdf(foto: foto, bytes: bytes));
    }

    if (fotosValidas.isEmpty) {
      throw StateError('Os arquivos das fotos desta OS não foram encontrados no aparelho.');
    }

    final documento = pw.Document(
      title: 'Relatório Fotográfico OS ${ordem.numeroOs}',
      author: empresa?.nome ?? 'G4 OS',
      subject: 'Relatório Fotográfico da Ordem de Serviço',
      creator: 'G4 OS',
    );

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 30),
        header: (_) => _cabecalho(ordem, empresa),
        footer: _rodape,
        build: (_) => <pw.Widget>[
          _identificacao(cliente, item),
          pw.SizedBox(height: 14),
          pw.Text(
            'REGISTRO FOTOGRÁFICO',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...List<pw.Widget>.generate(fotosValidas.length, (index) {
            final registro = fotosValidas[index];
            final descricao = (registro.foto.descricao ?? '').trim();
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.all(7),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: .6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    'Foto ${index + 1} de ${fotosValidas.length}',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(registro.bytes),
                      fit: pw.BoxFit.contain,
                      height: 245,
                    ),
                  ),
                  if (descricao.isNotEmpty) ...<pw.Widget>[
                    pw.SizedBox(height: 6),
                    pw.Text('Descrição: $descricao', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );

    return documento.save();
  }

  Future<void> imprimir({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoFoto> fotos,
    Empresa? empresa,
  }) async {
    await Printing.layoutPdf(
      name: _nomeArquivo(ordem),
      onLayout: (_) => gerar(
        ordem: ordem,
        cliente: cliente,
        item: item,
        fotos: fotos,
        empresa: empresa,
      ),
    );
  }

  Future<void> compartilhar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoFoto> fotos,
    Empresa? empresa,
  }) async {
    final bytes = await gerar(
      ordem: ordem,
      cliente: cliente,
      item: item,
      fotos: fotos,
      empresa: empresa,
    );
    if (bytes.isEmpty) throw StateError('O relatório fotográfico está vazio.');
    final nome = _nomeArquivo(ordem);

    if (Platform.isAndroid) {
      const canal = MethodChannel('g4_os/compartilhamento');
      await canal.invokeMethod<void>('compartilharPdf', <String, Object>{
        'bytes': bytes,
        'nomeArquivo': nome,
      });
      return;
    }
    await Printing.sharePdf(bytes: bytes, filename: nome);
  }

  String _nomeArquivo(OrdemServico ordem) =>
      'RELATORIO_FOTOGRAFICO_OS_${ordem.numeroOs.toString().padLeft(6, '0')}.pdf';

  pw.Widget _cabecalho(OrdemServico ordem, Empresa? empresa) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 9),
        margin: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: 1.1)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    empresa?.nome ?? 'G4 OS',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  if ((empresa?.cnpj ?? '').trim().isNotEmpty)
                    pw.Text('CNPJ: ${empresa!.cnpj}', style: const pw.TextStyle(fontSize: 8.5)),
                  if ((empresa?.inscricaoEstadual ?? '').trim().isNotEmpty)
                    pw.Text('IE: ${empresa!.inscricaoEstadual}', style: const pw.TextStyle(fontSize: 8.5)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: <pw.Widget>[
                pw.Text('RELATÓRIO FOTOGRÁFICO',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('OS Nº ${ordem.numeroOs.toString().padLeft(6, '0')}'),
                pw.Text('Status: ${ordem.status.replaceAll('_', ' ')}',
                    style: const pw.TextStyle(fontSize: 8.5)),
              ],
            ),
          ],
        ),
      );

  pw.Widget _identificacao(Cliente cliente, ItemAtendimento item) => pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
        columnWidths: const <int, pw.TableColumnWidth>{
          0: pw.FixedColumnWidth(95),
          1: pw.FlexColumnWidth(),
        },
        children: <List<String>>[
          <String>['Cliente', cliente.nome],
          <String>['Telefone', _texto(cliente.telefone)],
          <String>['Veículo / item', item.descricao],
          <String>['Marca / modelo', _juntar(<String?>[item.marca, item.modelo])],
          <String>['Placa', _texto(item.placa)],
        ].map((linha) => pw.TableRow(children: <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey100,
            child: pw.Text(linha[0],
                style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(linha[1], style: const pw.TextStyle(fontSize: 8.5)),
          ),
        ])).toList(),
      );

  pw.Widget _rodape(pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(width: .5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text('Relatório fotográfico gerado pelo G4 OS',
                style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      );

  String _texto(String? valor) {
    final texto = (valor ?? '').trim();
    return texto.isEmpty ? '-' : texto;
  }

  String _juntar(List<String?> valores) {
    final partes = valores
        .map((e) => (e ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return partes.isEmpty ? '-' : partes.join(' / ');
  }
}

class _FotoPdf {
  const _FotoPdf({required this.foto, required this.bytes});
  final OrdemServicoFoto foto;
  final Uint8List bytes;
}

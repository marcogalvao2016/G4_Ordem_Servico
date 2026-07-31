import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cliente.dart';
import '../models/item_atendimento.dart';
import '../models/ordem_servico.dart';
import '../models/vistoria_veiculo.dart';

class VistoriaVeiculoPdfService {
  const VistoriaVeiculoPdfService();

  Future<Uint8List> gerar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required VistoriaVeiculo vistoria,
  }) async {
    final documento = pw.Document(
      title: 'Ficha de Vistoria OS ${ordem.numeroOs}',
      author: 'G4 OS',
      subject: 'Ficha de Vistoria Veicular',
      creator: 'G4 OS',
    );

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _cabecalho(ordem),
        footer: _rodape,
        build: (_) => <pw.Widget>[
          _secao('CLIENTE E VEÍCULO'),
          _tabela(<List<String>>[
            <String>['Cliente', cliente.nome],
            <String>['CPF/CNPJ', _texto(cliente.cpfCnpj)],
            <String>['Telefone', _texto(cliente.telefone)],
            <String>['Veículo / item', item.descricao],
            <String>['Tipo', item.tipo],
            <String>['Marca / modelo', _juntar(<String?>[item.marca, item.modelo])],
            <String>['Placa', _texto(item.placa)],
            <String>['Ano / cor', _juntar(<String?>[item.ano, item.cor])],
            <String>['Número de série', _texto(item.numeroSerie)],
          ]),
          pw.SizedBox(height: 12),
          _secao('IDENTIFICAÇÃO DA VISTORIA'),
          _tabela(<List<String>>[
            <String>['Motorista', _texto(vistoria.nomeMotorista)],
            <String>['Local', _texto(vistoria.local)],
            <String>['Destino', _texto(vistoria.destino)],
            <String>['Quilometragem', _texto(vistoria.km)],
            <String>['Tipos de atendimento', _lista(vistoria.tiposAtendimento)],
            <String>['Motivos', _lista(vistoria.motivos)],
            <String>['Outro motivo', _texto(vistoria.outroMotivo)],
            <String>['Combustível', '${vistoria.combustivel}%'],
          ]),
          pw.SizedBox(height: 12),
          _secao('DANOS E AVARIAS'),
          _danos(vistoria.danos),
          pw.SizedBox(height: 12),
          _secao('PNEUS'),
          _mapa(vistoria.pneus),
          pw.SizedBox(height: 12),
          _secao('ACESSÓRIOS'),
          _mapa(vistoria.acessorios),
          pw.SizedBox(height: 12),
          _secao('DECLARAÇÕES E OBSERVAÇÕES'),
          _tabela(<List<String>>[
            <String>[
              'Pertences retirados',
              vistoria.proprietarioOrientado ? 'SIM' : 'NÃO',
            ],
            <String>[
              'Ciente sobre diárias de pátio',
              vistoria.patioCiente ? 'SIM' : 'NÃO',
            ],
            <String>['Observações', _texto(vistoria.observacoes)],
          ]),
          pw.SizedBox(height: 12),
          _secao('RESPONSÁVEIS'),
          _tabela(<List<String>>[
            <String>['Segurado / beneficiário', _texto(vistoria.seguradoNome)],
            <String>['RG do segurado', _texto(vistoria.seguradoRg)],
            <String>['Confirmação do segurado', _texto(vistoria.seguradoAssinatura)],
            <String>['Destinatário', _texto(vistoria.destinatarioNome)],
            <String>['RG do destinatário', _texto(vistoria.destinatarioRg)],
            <String>['Confirmação do destinatário', _texto(vistoria.destinatarioAssinatura)],
            <String>['Prestador', _texto(vistoria.prestadorNome)],
            <String>['RG do prestador', _texto(vistoria.prestadorRg)],
            <String>['Confirmação do prestador', _texto(vistoria.prestadorAssinatura)],
          ]),
          _assinaturas(),
        ],
      ),
    );

    return documento.save();
  }

  Future<void> imprimir({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required VistoriaVeiculo vistoria,
  }) async {
    await Printing.layoutPdf(
      name: _nomeArquivo(ordem),
      onLayout: (_) => gerar(
        ordem: ordem,
        cliente: cliente,
        item: item,
        vistoria: vistoria,
      ),
    );
  }

  Future<void> compartilhar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required VistoriaVeiculo vistoria,
  }) async {
    final bytes = await gerar(
      ordem: ordem,
      cliente: cliente,
      item: item,
      vistoria: vistoria,
    );
    if (bytes.isEmpty) throw StateError('O PDF da vistoria está vazio.');
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
      'VISTORIA_OS_${ordem.numeroOs.toString().padLeft(6, '0')}.pdf';

  pw.Widget _cabecalho(OrdemServico ordem) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        margin: const pw.EdgeInsets.only(bottom: 12),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: 1.2)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text('G4 OS', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text('Gestão de Ordens de Serviço'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: <pw.Widget>[
                pw.Text('FICHA DE VISTORIA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('OS Nº ${ordem.numeroOs.toString().padLeft(6, '0')}'),
                pw.Text('Status: ${ordem.status.replaceAll('_', ' ')}'),
              ],
            ),
          ],
        ),
      );

  pw.Widget _rodape(pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: .5))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text('Ficha gerada pelo G4 OS', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      );

  pw.Widget _secao(String titulo) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: PdfColors.blueGrey100,
        child: pw.Text(titulo, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _tabela(List<List<String>> linhas) => pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
        columnWidths: const <int, pw.TableColumnWidth>{0: pw.FixedColumnWidth(145), 1: pw.FlexColumnWidth()},
        children: linhas.map((linha) => pw.TableRow(children: <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            color: PdfColors.grey100,
            child: pw.Text(linha[0], style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(linha[1], style: const pw.TextStyle(fontSize: 8.5))),
        ])).toList(),
      );

  pw.Widget _danos(List<Map<String, String>> danos) {
    if (danos.isEmpty) return _vazio('NENHUM DANO OU AVARIA REGISTRADO.');
    return pw.TableHelper.fromTextArray(
      headers: const <String>['Nº', 'Região', 'Tipo', 'Detalhes'],
      data: List<List<String>>.generate(danos.length, (i) {
        final d = danos[i];
        return <String>[
          '${i + 1}',
          _primeiro(d, const <String>['regiao', 'parte', 'local', 'area']),
          _primeiro(d, const <String>['tipo', 'dano', 'avaria']),
          _primeiro(d, const <String>['detalhes', 'descricao', 'observacao']),
        ];
      }),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
    );
  }

  pw.Widget _mapa(Map<String, String> valores) {
    final entradas = valores.entries.where((e) => e.value.trim().isNotEmpty).toList();
    if (entradas.isEmpty) return _vazio('NENHUMA INFORMAÇÃO REGISTRADA.');
    return _tabela(entradas.map((e) => <String>[_rotulo(e.key), e.value]).toList());
  }

  pw.Widget _vazio(String texto) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: .5)),
        child: pw.Text(texto, style: const pw.TextStyle(fontSize: 8)),
      );

  pw.Widget _assinaturas() => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 28),
        child: pw.Row(children: <pw.Widget>[
          pw.Expanded(child: _linhaAssinatura('SEGURADO / RESPONSÁVEL')),
          pw.SizedBox(width: 24),
          pw.Expanded(child: _linhaAssinatura('PRESTADOR / VISTORIADOR')),
        ]),
      );

  pw.Widget _linhaAssinatura(String texto) => pw.Column(children: <pw.Widget>[
        pw.Container(height: 25),
        pw.Container(height: .7, color: PdfColors.black),
        pw.SizedBox(height: 4),
        pw.Text(texto, style: const pw.TextStyle(fontSize: 8)),
      ]);

  String _texto(String? valor) => (valor ?? '').trim().isEmpty ? '-' : valor!.trim();
  String _lista(List<String> valores) => valores.isEmpty ? '-' : valores.join(' / ');
  String _juntar(List<String?> valores) {
    final s = valores.map((e) => e?.trim() ?? '').where((e) => e.isNotEmpty).join(' / ');
    return s.isEmpty ? '-' : s;
  }
  String _rotulo(String valor) => valor.replaceAll('_', ' ').toUpperCase();
  String _primeiro(Map<String, String> mapa, List<String> chaves) {
    for (final chave in chaves) {
      final valor = mapa[chave];
      if (valor != null && valor.trim().isNotEmpty) return valor;
    }
    final valores = mapa.values.where((e) => e.trim().isNotEmpty);
    return valores.isEmpty ? '-' : valores.first;
  }
}

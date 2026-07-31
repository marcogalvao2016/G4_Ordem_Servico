import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../models/checklist_os_item.dart';
import '../models/cliente.dart';
import '../models/item_atendimento.dart';
import '../models/ordem_servico.dart';
import '../models/ordem_servico_item.dart';

class OrdemServicoPdfService {
  const OrdemServicoPdfService();

  Future<Uint8List> gerar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoItem> servicos,
    required List<ChecklistOsItem> checklist,
  }) async {
    final documento = pw.Document(
      title: 'Ordem de Serviço ${ordem.numeroOs}',
      author: 'G4 OS',
      subject: 'Ordem de Serviço',
      creator: 'G4 OS',
    );

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _cabecalho(ordem, context),
        footer: (context) => _rodape(context),
        build: (context) => <pw.Widget>[
          _tituloSecao('DADOS DO CLIENTE'),
          _tabelaDados(<List<String>>[
            <String>['Cliente', cliente.nome],
            <String>['CPF/CNPJ', _texto(cliente.cpfCnpj)],
            <String>['Telefone', _texto(cliente.telefone)],
            <String>['E-mail', _texto(cliente.email)],
            <String>['Endereço', _enderecoCliente(cliente)],
          ]),
          pw.SizedBox(height: 14),
          _tituloSecao('ITEM / EQUIPAMENTO'),
          _tabelaDados(<List<String>>[
            <String>['Tipo', item.tipo],
            <String>['Descrição', item.descricao],
            <String>['Marca / Modelo', _juntar(<String?>[item.marca, item.modelo])],
            <String>['Número de série', _texto(item.numeroSerie)],
            <String>['Placa', _texto(item.placa)],
            <String>['Ano / Cor', _juntar(<String?>[item.ano, item.cor])],
          ]),
          pw.SizedBox(height: 14),
          _tituloSecao('DETALHES DA ORDEM DE SERVIÇO'),
          _campoTexto('Problema relatado', ordem.descricaoProblema),
          _campoTexto('Diagnóstico', ordem.diagnostico),
          _campoTexto('Solução aplicada', ordem.solucao),
          pw.SizedBox(height: 14),
          _tituloSecao('SERVIÇOS'),
          _tabelaServicos(servicos),
          pw.SizedBox(height: 14),
          if (checklist.isNotEmpty) ...<pw.Widget>[
            _tituloSecao('CHECKLIST'),
            _checklist(checklist),
            pw.SizedBox(height: 14),
          ],
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
    required List<OrdemServicoItem> servicos,
    required List<ChecklistOsItem> checklist,
  }) async {
    await Printing.layoutPdf(
      name: _nomeArquivo(ordem),
      onLayout: (_) => gerar(
        ordem: ordem,
        cliente: cliente,
        item: item,
        servicos: servicos,
        checklist: checklist,
      ),
    );
  }

  Future<void> compartilhar({
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoItem> servicos,
    required List<ChecklistOsItem> checklist,
  }) async {
    final bytes = await gerar(
      ordem: ordem,
      cliente: cliente,
      item: item,
      servicos: servicos,
      checklist: checklist,
    );

    final nomeArquivo = _nomeArquivo(ordem);

    if (bytes.isEmpty) {
      throw StateError('O PDF gerado está vazio.');
    }

    // Logs visíveis no adb logcat. Eles permitem confirmar se o Flutter
    // gerou o documento e quantos bytes foram enviados ao Android nativo.
    print('G4_SHARE_FLUTTER: nome=$nomeArquivo');
    print('G4_SHARE_FLUTTER: bytes=${bytes.length}');

    // No Android, o código nativo grava o PDF em Downloads/G4OS e entrega
    // uma URI com permissão temporária de leitura ao aplicativo escolhido.
    // Em Android 9 ou anterior, a permissão de armazenamento é solicitada
    // na primeira utilização.
    if (Platform.isAndroid) {
      const canal = MethodChannel('g4_os/compartilhamento');
      await canal.invokeMethod<void>(
        'compartilharPdf',
        <String, Object>{
          'bytes': bytes,
          'nomeArquivo': nomeArquivo,
        },
      );
      return;
    }

    // Fallback para Windows, iOS e demais plataformas usando o próprio
    // pacote printing, já utilizado pela impressão do documento.
    await Printing.sharePdf(
      bytes: bytes,
      filename: nomeArquivo,
    );
  }

  String _nomeArquivo(OrdemServico ordem) =>
      'OS_${ordem.numeroOs.toString().padLeft(6, '0')}.pdf';

  pw.Widget _cabecalho(OrdemServico ordem, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1.2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'G4 OS',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Gestão de Ordens de Serviço'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              pw.Text(
                'ORDEM DE SERVIÇO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Nº ${ordem.numeroOs.toString().padLeft(6, '0')}'),
              pw.Text('Abertura: ${_dataHora(ordem.dataAbertura)}'),
              pw.Text('Status: ${ordem.status.replaceAll('_', ' ')}'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _rodape(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text('Documento gerado pelo G4 OS', style: const pw.TextStyle(fontSize: 8)),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _tituloSecao(String titulo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: PdfColors.grey300,
      child: pw.Text(
        titulo,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tabelaDados(List<List<String>> linhas) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FixedColumnWidth(105),
        1: pw.FlexColumnWidth(),
      },
      children: linhas
          .map(
            (linha) => pw.TableRow(
              children: <pw.Widget>[
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  color: PdfColors.grey100,
                  child: pw.Text(
                    linha[0],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(linha[1], style: const pw.TextStyle(fontSize: 9)),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  pw.Widget _campoTexto(String titulo, String? valor) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(7),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          pw.SizedBox(height: 3),
          pw.Text(_texto(valor), style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _tabelaServicos(List<OrdemServicoItem> servicos) {
    final total = servicos.fold<double>(0, (soma, item) => soma + item.valorTotal);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        pw.TableHelper.fromTextArray(
          headers: const <String>['Descrição', 'Qtd.', 'Vlr. unit.', 'Desconto', 'Total'],
          data: servicos
              .map(
                (item) => <String>[
                  item.observacao == null || item.observacao!.trim().isEmpty
                      ? item.descricao
                      : '${item.descricao}\n${item.observacao}',
                  _numero(item.quantidade),
                  _moeda(item.valorUnitario),
                  _moeda(item.desconto),
                  _moeda(item.valorTotal),
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
          cellStyle: const pw.TextStyle(fontSize: 8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          cellAlignments: const <int, pw.Alignment>{
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          columnWidths: const <int, pw.TableColumnWidth>{
            0: pw.FlexColumnWidth(3.3),
            1: pw.FlexColumnWidth(0.7),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.1),
            4: pw.FlexColumnWidth(1.2),
          },
        ),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey100,
          child: pw.Text(
            'VALOR TOTAL: ${_moeda(total)}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  pw.Widget _checklist(List<ChecklistOsItem> itens) {
    return pw.Column(
      children: itens
          .map(
            (item) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(item.concluido ? '[X]' : '[ ]', style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Text(
                      '${item.descricao}${(item.observacao ?? '').trim().isEmpty ? '' : ' - ${item.observacao}'}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _assinaturas() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 28),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(child: _linhaAssinatura('Cliente / responsável')),
          pw.SizedBox(width: 30),
          pw.Expanded(child: _linhaAssinatura('Técnico / responsável')),
        ],
      ),
    );
  }

  pw.Widget _linhaAssinatura(String legenda) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Container(height: 28),
        pw.Container(height: 0.7, color: PdfColors.black),
        pw.SizedBox(height: 4),
        pw.Text(legenda, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  String _texto(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? '-' : texto;
  }

  String _juntar(List<String?> partes) {
    final resultado = partes
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' / ');
    return resultado.isEmpty ? '-' : resultado;
  }

  String _enderecoCliente(Cliente cliente) {
    final linha1 = <String>[
      cliente.logradouro?.trim() ?? '',
      cliente.numero?.trim() ?? '',
      cliente.complemento?.trim() ?? '',
    ].where((e) => e.isNotEmpty).join(', ');
    final linha2 = <String>[
      cliente.bairro?.trim() ?? '',
      cliente.cidade?.trim() ?? '',
      cliente.uf?.trim() ?? '',
      cliente.cep?.trim() ?? '',
    ].where((e) => e.isNotEmpty).join(' - ');
    final endereco = <String>[linha1, linha2].where((e) => e.isNotEmpty).join(' | ');
    return endereco.isEmpty ? '-' : endereco;
  }

  String _dataHora(DateTime data) {
    String dois(int value) => value.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }

  String _numero(double valor) {
    final casas = valor == valor.roundToDouble() ? 0 : 2;
    return valor.toStringAsFixed(casas).replaceAll('.', ',');
  }

  String _moeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final buffer = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      final posicaoRestante = inteiro.length - i;
      buffer.write(inteiro[i]);
      if (posicaoRestante > 1 && posicaoRestante % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'R\$ ${buffer.toString()},${partes[1]}';
  }
}

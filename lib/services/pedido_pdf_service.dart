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
import '../models/ordem_servico_item.dart';
import '../models/ordem_servico_produto.dart';

class PedidoPdfService {
  const PedidoPdfService();

  Future<Uint8List> gerar({
    required Empresa empresa,
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoItem> servicos,
    required List<OrdemServicoProduto> produtos,
  }) async {
    final logo = await _carregarLogo(empresa);

    final doc = pw.Document(
      title: 'Pedido OS ${ordem.numeroOs}',
      author: empresa.nome,
      creator: 'G4 OS',
    );

    final linhas = <_LinhaPedido>[
      ...servicos.map((s) => _LinhaPedido(
            quantidade: s.quantidade,
            descricao: s.descricao,
            valorUnitario: s.valorUnitario,
            valorTotal: s.valorTotal,
          )),
      ...produtos.map((p) => _LinhaPedido(
            quantidade: p.quantidade,
            descricao: p.descricao,
            valorUnitario: p.valorUnitario,
            valorTotal: p.valorTotal,
          )),
    ];

    final total = linhas.fold<double>(0, (soma, linha) => soma + linha.valorTotal);
    final formato = _formatoCompacto(
      empresa: empresa,
      cliente: cliente,
      item: item,
      linhas: linhas,
    );

    doc.addPage(
      pw.Page(
        pageFormat: formato,
        margin: const pw.EdgeInsets.fromLTRB(14, 14, 14, 12),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: <pw.Widget>[
          _cabecalho(empresa, logo),
          pw.SizedBox(height: 10),
          _linhaCampo('Data:', _data(ordem.dataAbertura), 'Veículo:', _veiculo(item)),
          pw.SizedBox(height: 7),
          _campoLinhaInteira('Nome:', cliente.nome),
          pw.SizedBox(height: 7),
          _campoLinhaInteira('Endereço:', _enderecoCliente(cliente)),
          pw.SizedBox(height: 7),
          _linhaCampo('Cidade:', _cidadeCliente(cliente), 'Fone:', _texto(cliente.telefone)),
          pw.SizedBox(height: 9),
          _tabela(linhas),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'TOTAL: ${_moeda(total)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'OS Nº ${ordem.numeroOs.toString().padLeft(6, '0')}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          pw.SizedBox(height: 8),
          _rodape(empresa),
          ],
        ),
      ),
    );

    return doc.save();
  }

  Future<void> imprimir({
    required Empresa empresa,
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoItem> servicos,
    required List<OrdemServicoProduto> produtos,
  }) async {
    await Printing.layoutPdf(
      name: _nomeArquivo(ordem),
      onLayout: (_) => gerar(
        empresa: empresa,
        ordem: ordem,
        cliente: cliente,
        item: item,
        servicos: servicos,
        produtos: produtos,
      ),
    );
  }

  Future<void> compartilhar({
    required Empresa empresa,
    required OrdemServico ordem,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<OrdemServicoItem> servicos,
    required List<OrdemServicoProduto> produtos,
  }) async {
    final bytes = await gerar(
      empresa: empresa,
      ordem: ordem,
      cliente: cliente,
      item: item,
      servicos: servicos,
      produtos: produtos,
    );

    if (bytes.isEmpty) {
      throw StateError('O PDF do pedido está vazio.');
    }

    final nomeArquivo = _nomeArquivo(ordem);
    if (Platform.isAndroid) {
      const canal = MethodChannel('g4_os/compartilhamento');
      await canal.invokeMethod<void>('compartilharPdf', <String, Object>{
        'bytes': bytes,
        'nomeArquivo': nomeArquivo,
      });
      return;
    }

    await Printing.sharePdf(bytes: bytes, filename: nomeArquivo);
  }

  String _nomeArquivo(OrdemServico ordem) =>
      'PEDIDO_OS_${ordem.numeroOs.toString().padLeft(6, '0')}.pdf';

  Future<pw.MemoryImage?> _carregarLogo(Empresa empresa) async {
    final caminho = empresa.logoPath?.trim();
    if (caminho == null || caminho.isEmpty) return null;
    try {
      final arquivo = File(caminho);
      if (!await arquivo.exists()) return null;
      final bytes = await arquivo.readAsBytes();
      if (bytes.isEmpty) return null;
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  pw.Widget _cabecalho(Empresa empresa, pw.MemoryImage? logo) {
    final dadosEmpresa = pw.Column(
      crossAxisAlignment: logo == null
          ? pw.CrossAxisAlignment.center
          : pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          empresa.nome,
          textAlign: logo == null ? pw.TextAlign.center : pw.TextAlign.left,
          style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold),
        ),
        if (_texto(empresa.cnpj) != '-') ...<pw.Widget>[
          pw.SizedBox(height: 2),
          pw.Text(
            'CNPJ: ${_texto(empresa.cnpj)}${_texto(empresa.inscricaoEstadual) == '-' ? '' : '   IE: ${_texto(empresa.inscricaoEstadual)}'}',
            textAlign: logo == null ? pw.TextAlign.center : pw.TextAlign.left,
            style: const pw.TextStyle(fontSize: 7.5),
          ),
        ],
      ],
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        if (logo == null)
          pw.Center(child: dadosEmpresa)
        else
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: <pw.Widget>[
              pw.Container(
                width: 44,
                height: 44,
                alignment: pw.Alignment.center,
                child: pw.Image(logo, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(child: dadosEmpresa),
            ],
          ),
        pw.SizedBox(height: 7),
        pw.Container(height: .8, color: PdfColors.grey700),
      ],
    );
  }

  pw.Widget _linhaCampo(String rotulo1, String valor1, String rotulo2, String valor2) {
    return pw.Row(
      children: <pw.Widget>[
        pw.Expanded(flex: 3, child: _campo(rotulo1, valor1)),
        pw.SizedBox(width: 8),
        pw.Expanded(flex: 4, child: _campo(rotulo2, valor2)),
      ],
    );
  }

  pw.Widget _campoLinhaInteira(String rotulo, String valor) => _campo(rotulo, valor);

  pw.Widget _campo(String rotulo, String valor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: <pw.Widget>[
        pw.Text(rotulo, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 3),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: .6)),
            ),
            child: pw.Text(valor, style: const pw.TextStyle(fontSize: 7.5)),
          ),
        ),
      ],
    );
  }

  pw.Widget _tabela(List<_LinhaPedido> linhas) {
    final dados = linhas.isEmpty
        ? <List<String>>[<String>['', 'SEM ITENS LANÇADOS', '', '']]
        : linhas.map((l) => <String>[
              _numero(l.quantidade),
              l.descricao,
              _moeda(l.valorUnitario),
              _moeda(l.valorTotal),
            ]).toList();

    return pw.TableHelper.fromTextArray(
      headers: const <String>['Quant.', 'Descrição das Mercadorias', 'P. Unit.', 'Preço Total'],
      data: dados,
      headerStyle: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 6.8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      border: pw.TableBorder.all(width: .55, color: PdfColors.grey700),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      cellAlignments: const <int, pw.Alignment>{
        0: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(.8),
        1: pw.FlexColumnWidth(3.5),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.35),
      },
    );
  }

  pw.Widget _rodape(Empresa empresa) {
    final partes = <String>[
      _textoSemTraco(empresa.endereco),
      _textoSemTraco(empresa.bairro),
      _juntarCidadeUf(empresa.cidade, empresa.uf),
      if (_textoSemTraco(empresa.cep).isNotEmpty) 'CEP: ${empresa.cep}',
    ].where((e) => e.trim().isNotEmpty).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: .6))),
      child: pw.Column(
        children: <pw.Widget>[
          if (partes.isNotEmpty)
            pw.Text(partes.join(' - '), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6.4)),
          if (_textoSemTraco(empresa.email).isNotEmpty || _textoSemTraco(empresa.celular).isNotEmpty)
            pw.Text(
              <String>[
                if (_textoSemTraco(empresa.email).isNotEmpty) 'E-mail: ${empresa.email}',
                if (_textoSemTraco(empresa.celular).isNotEmpty) 'Contato: ${empresa.celular}',
              ].join('   '),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 6.4),
            ),
        ],
      ),
    );
  }

  PdfPageFormat _formatoCompacto({
    required Empresa empresa,
    required Cliente cliente,
    required ItemAtendimento item,
    required List<_LinhaPedido> linhas,
  }) {
    const larguraMm = 90.0;

    // Altura base: cabeçalho, dados do cliente/veículo, total e rodapé.
    double alturaMm = 91.0;
    if (_textoSemTraco(empresa.logoPath).isNotEmpty) alturaMm += 5.0;

    // Cada item ocupa somente o necessário. Descrições maiores acrescentam
    // altura ao talão, mantendo o PDF curto quando houver poucos itens.
    for (final linha in linhas) {
      final caracteres = linha.descricao.trim().length;
      final linhasDescricao = (caracteres / 32).ceil().clamp(1, 5);
      alturaMm += 7.0 + ((linhasDescricao - 1) * 3.6);
    }

    if (linhas.isEmpty) alturaMm += 8.0;

    final enderecoCliente = _enderecoCliente(cliente);
    if (enderecoCliente.length > 45) alturaMm += 4.0;

    final veiculo = _veiculo(item);
    if (veiculo.length > 38) alturaMm += 4.0;

    final enderecoEmpresa = <String>[
      _textoSemTraco(empresa.endereco),
      _textoSemTraco(empresa.bairro),
      _juntarCidadeUf(empresa.cidade, empresa.uf),
      _textoSemTraco(empresa.cep),
    ].where((e) => e.isNotEmpty).join(' - ');
    if (enderecoEmpresa.length > 55) alturaMm += 4.0;

    // Evita um documento minúsculo e deixa pequena margem de segurança
    // para fontes e quebras de linha calculadas pelo motor do PDF.
    if (alturaMm < 105.0) alturaMm = 105.0;
    alturaMm += 5.0;

    return PdfPageFormat(
      larguraMm * PdfPageFormat.mm,
      alturaMm * PdfPageFormat.mm,
      marginAll: 0,
    );
  }

  String _veiculo(ItemAtendimento item) {
    return [item.descricao, item.marca, item.modelo, item.placa]
        .where((e) => e != null && e!.trim().isNotEmpty)
        .map((e) => e!.trim())
        .join(' / ');
  }

  String _enderecoCliente(Cliente c) => <String?>[c.logradouro, c.numero, c.complemento, c.bairro]
      .where((e) => e != null && e!.trim().isNotEmpty)
      .map((e) => e!.trim())
      .join(', ');

  String _cidadeCliente(Cliente c) => _juntarCidadeUf(c.cidade, c.uf);
  String _juntarCidadeUf(String? cidade, String? uf) =>
      [cidade, uf].where((e) => e != null && e!.trim().isNotEmpty).map((e) => e!.trim()).join(' - ');
  String _texto(String? value) => value == null || value.trim().isEmpty ? '-' : value.trim();
  String _textoSemTraco(String? value) => value == null ? '' : value.trim();
  String _data(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  String _moeda(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  String _numero(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2).replaceAll('.', ',');
}

class _LinhaPedido {
  const _LinhaPedido({
    required this.quantidade,
    required this.descricao,
    required this.valorUnitario,
    required this.valorTotal,
  });

  final double quantidade;
  final String descricao;
  final double valorUnitario;
  final double valorTotal;
}

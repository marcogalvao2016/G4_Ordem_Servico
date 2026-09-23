import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/uppercase_text_formatter.dart';
import '../../models/produto.dart';
import '../../repositories/produto_repository.dart';

class ProdutoFormScreen extends StatefulWidget {
  const ProdutoFormScreen({super.key, this.produto});

  final Produto? produto;

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProdutoRepository();
  final _codigo = TextEditingController();
  final _descricao = TextEditingController();
  final _unidade = TextEditingController(text: 'UN');
  final _valorVenda = TextEditingController();
  final _ncm = TextEditingController();
  final _csosn = TextEditingController();
  final _cfop = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    if (p != null) {
      _codigo.text = p.codigo.toString();
      _descricao.text = p.descricao;
      _unidade.text = p.unidade;
      _valorVenda.text = p.valorVenda.toStringAsFixed(2).replaceAll('.', ',');
      _ncm.text = p.ncm ?? '';
      _csosn.text = p.csosn ?? '';
      _cfop.text = p.cfop ?? '';
    } else {
      _carregarProximoCodigo();
    }
  }

  Future<void> _carregarProximoCodigo() async {
    final codigo = await _repository.proximoCodigo();
    if (mounted && _codigo.text.isEmpty) {
      setState(() => _codigo.text = codigo.toString());
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final agora = DateTime.now();
      final original = widget.produto;
      final produto = Produto(
        id: original?.id,
        uuid: original?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        codigo: int.parse(_codigo.text.trim()),
        descricao: _descricao.text.trim().toUpperCase(),
        unidade: _unidade.text.trim().toUpperCase(),
        valorVenda: parseCurrency(_valorVenda.text),
        ncm: _ncm.text.trim().isEmpty ? null : _ncm.text.trim(),
        csosn: _csosn.text.trim().isEmpty ? null : _csosn.text.trim(),
        cfop: _cfop.text.trim().isEmpty ? null : _cfop.text.trim(),
        criadoEm: original?.criadoEm ?? agora,
        atualizadoEm: agora,
      );

      if (original == null) {
        await _repository.salvar(produto);
      } else {
        await _repository.atualizar(produto);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar o produto: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _validarDigitos(String? value, int tamanho, String campo) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return null;
    if (texto.length != tamanho || int.tryParse(texto) == null) {
      return '$campo deve conter $tamanho dígitos.';
    }
    return null;
  }

  @override
  void dispose() {
    _codigo.dispose();
    _descricao.dispose();
    _unidade.dispose();
    _valorVenda.dispose();
    _ncm.dispose();
    _csosn.dispose();
    _cfop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo produto' : 'Editar produto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _codigo,
                    decoration: const InputDecoration(labelText: 'Código *'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final codigo = int.tryParse(value?.trim() ?? '');
                      return codigo == null || codigo <= 0 ? 'Informe o código.' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unidade,
                    decoration: const InputDecoration(labelText: 'Unidade *'),
                    inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a unidade.'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Ex.: ÓLEO 5W30, PNEU 175/70 R14, FILTRO DE ÓLEO',
              ),
              inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe a descrição.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valorVenda,
              decoration: const InputDecoration(
                labelText: 'Valor de venda *',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => parseCurrency(value ?? '') < 0
                  ? 'Informe um valor válido.'
                  : null,
            ),
            const SizedBox(height: 18),
            Text('Dados fiscais', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Campos preparados para futura emissão de NF-e/NFC-e.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ncm,
              decoration: const InputDecoration(labelText: 'NCM'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              maxLength: 8,
              validator: (value) => _validarDigitos(value, 8, 'NCM'),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _csosn,
                    decoration: const InputDecoration(labelText: 'CSOSN'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    maxLength: 3,
                    validator: (value) => _validarDigitos(value, 3, 'CSOSN'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cfop,
                    decoration: const InputDecoration(labelText: 'CFOP'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    validator: (value) => _validarDigitos(value, 4, 'CFOP'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(_salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

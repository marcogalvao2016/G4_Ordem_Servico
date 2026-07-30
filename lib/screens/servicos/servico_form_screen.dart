import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/formatters.dart';
import '../../core/session/session_manager.dart';
import '../../models/servico.dart';
import '../../repositories/servico_repository.dart';

class ServicoFormScreen extends StatefulWidget {
  const ServicoFormScreen({super.key, this.servico});

  final Servico? servico;

  @override
  State<ServicoFormScreen> createState() => _ServicoFormScreenState();
}

class _ServicoFormScreenState extends State<ServicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ServicoRepository();

  late final TextEditingController _descricao;
  late final TextEditingController _valor;
  late final TextEditingController _observacoes;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricao = TextEditingController(text: widget.servico?.descricao);
    _valor = TextEditingController(
      text: widget.servico == null
          ? ''
          : widget.servico!.valorPadrao.toStringAsFixed(2).replaceAll('.', ','),
    );
    _observacoes = TextEditingController(text: widget.servico?.observacoes);
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final now = DateTime.now();
      final original = widget.servico;
      final servico = Servico(
        id: original?.id,
        uuid: original?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        descricao: _descricao.text.trim(),
        valorPadrao: parseCurrency(_valor.text),
        observacoes: _observacoes.text.trim(),
        criadoEm: original?.criadoEm ?? now,
        atualizadoEm: now,
      );

      if (original == null) {
        await _repository.salvar(servico);
      } else {
        await _repository.atualizar(servico);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servico == null ? 'Novo serviço' : 'Editar serviço'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição *'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe a descrição.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valor,
              decoration: const InputDecoration(
                labelText: 'Valor padrão',
                prefixText: 'R\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Observações'),
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

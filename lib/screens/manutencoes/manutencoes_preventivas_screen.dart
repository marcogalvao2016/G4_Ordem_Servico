import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/uppercase_text_formatter.dart';
import '../../models/manutencao_preventiva.dart';
import '../../repositories/manutencao_preventiva_repository.dart';

class ManutencoesPreventivasScreen extends StatefulWidget {
  const ManutencoesPreventivasScreen({super.key});

  @override
  State<ManutencoesPreventivasScreen> createState() =>
      _ManutencoesPreventivasScreenState();
}

class _ManutencoesPreventivasScreenState
    extends State<ManutencoesPreventivasScreen> {
  final _repository = ManutencaoPreventivaRepository();
  bool _carregando = true;
  List<ManutencaoPreventiva> _itens = <ManutencaoPreventiva>[];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final itens = await _repository.listar();
    if (!mounted) return;
    setState(() {
      _itens = itens;
      _carregando = false;
    });
  }

  String _intervalo(ManutencaoPreventiva item) {
    final partes = <String>[];
    if (item.intervaloKm != null) {
      partes.add('${item.intervaloKm} km');
    }
    if (item.intervaloMeses != null) {
      partes.add('${item.intervaloMeses} meses');
    }
    return partes.isEmpty ? 'Sem intervalo definido' : partes.join(' ou ');
  }

  Future<void> _editar([ManutencaoPreventiva? atual]) async {
    final descricao = TextEditingController(text: atual?.descricao ?? '');
    final categoria = TextEditingController(text: atual?.categoria ?? 'GERAL');
    final km = TextEditingController(text: atual?.intervaloKm?.toString() ?? '');
    final meses = TextEditingController(
      text: atual?.intervaloMeses?.toString() ?? '',
    );
    final observacoes = TextEditingController(text: atual?.observacoes ?? '');
    bool ativo = atual?.ativo ?? true;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(atual == null ? 'Nova manutenção preventiva' : 'Editar manutenção'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: descricao,
                  inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
                  decoration: const InputDecoration(labelText: 'Descrição *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoria,
                  inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
                  decoration: const InputDecoration(labelText: 'Categoria *'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: km,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Intervalo em km'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: meses,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Intervalo em meses'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observacoes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: ativo,
                  title: const Text('Ativo'),
                  onChanged: (value) => setDialogState(() => ativo = value),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (descricao.text.trim().isEmpty || categoria.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (confirmou == true) {
      final agora = DateTime.now();
      final item = ManutencaoPreventiva(
        id: atual?.id,
        uuid: atual?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        descricao: descricao.text.trim().toUpperCase(),
        categoria: categoria.text.trim().toUpperCase(),
        intervaloKm: int.tryParse(km.text.trim()),
        intervaloMeses: int.tryParse(meses.text.trim()),
        observacoes: observacoes.text.trim(),
        ativo: ativo,
        criadoEm: atual?.criadoEm ?? agora,
        atualizadoEm: agora,
      );
      if (atual == null) {
        await _repository.salvar(item);
      } else {
        await _repository.atualizar(item);
      }
      await _carregar();
    }

    descricao.dispose();
    categoria.dispose();
    km.dispose();
    meses.dispose();
    observacoes.dispose();
  }

  Future<void> _excluir(ManutencaoPreventiva item) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir manutenção'),
        content: Text('Deseja excluir "${item.descricao}"? O histórico já registrado não será apagado.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmou == true) {
      await _repository.excluir(item);
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manutenções preventivas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(),
        icon: const Icon(Icons.add),
        label: const Text('Nova manutenção'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Os intervalos abaixo são referências configuráveis. O manual do fabricante do veículo deve prevalecer quando houver orientação específica.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._itens.map(
                    (item) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(item.ativo ? Icons.build_circle_outlined : Icons.pause_circle_outline),
                        ),
                        title: Text(item.descricao),
                        subtitle: Text('${item.categoria} • ${_intervalo(item)}${(item.observacoes ?? '').trim().isEmpty ? '' : '\n${item.observacoes}'}'),
                        isThreeLine: (item.observacoes ?? '').trim().isNotEmpty,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') _editar(item);
                            if (value == 'excluir') _excluir(item);
                          },
                          itemBuilder: (_) => const <PopupMenuEntry<String>>[
                            PopupMenuItem(value: 'editar', child: Text('Editar')),
                            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

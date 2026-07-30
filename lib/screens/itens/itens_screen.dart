import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../models/item_atendimento.dart';
import '../../repositories/item_repository.dart';
import 'item_form_screen.dart';

class ItensScreen extends StatefulWidget {
  const ItensScreen({super.key});

  @override
  State<ItensScreen> createState() => _ItensScreenState();
}

class _ItensScreenState extends State<ItensScreen> {
  final _repository = ItemRepository();
  late Future<List<ItemAtendimento>> _future;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _future = _repository.listar();
  }

  Future<void> _abrir([ItemAtendimento? item]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemFormScreen(item: item)),
    );
    if (changed == true && mounted) {
      setState(_recarregar);
    }
  }

  Future<void> _excluir(ItemAtendimento item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Excluir "${item.descricao}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _repository.excluir(item);
      if (mounted) setState(_recarregar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itens')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrir,
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: FutureBuilder<List<ItemAtendimento>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final itens = snapshot.data ?? <ItemAtendimento>[];
          if (itens.isEmpty) {
            return const Center(child: Text('Nenhum item cadastrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: itens.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = itens[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.devices_other)),
                title: Text(item.descricao),
                subtitle: Text(
                  <String?>[item.tipo, item.marca, item.modelo, item.placa]
                      .where((e) => e != null && e!.trim().isNotEmpty)
                      .join(' • '),
                ),
                onTap: () => _abrir(item),
                trailing: IconButton(
                  onPressed: () => _excluir(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../models/cliente.dart';
import '../../repositories/cliente_repository.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteRepository _repository = ClienteRepository();
  late Future<List<Cliente>> _future;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _future = _repository.listar();
  }

  Future<void> _abrirFormulario([Cliente? cliente]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClienteFormScreen(cliente: cliente),
      ),
    );

    if (changed == true && mounted) {
      setState(_recarregar);
    }
  }

  Future<void> _excluir(Cliente cliente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text('Excluir "${cliente.nome}"?'),
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

    if (confirmed == true) {
      await _repository.excluir(cliente);
      if (mounted) {
        setState(_recarregar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo cliente'),
      ),
      body: FutureBuilder<List<Cliente>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final clientes = snapshot.data ?? <Cliente>[];
          if (clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: clientes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(cliente.nome),
                subtitle: Text(
                  [
                    cliente.cpfCnpj,
                    cliente.telefone,
                    cliente.cidade,
                  ].where((e) => e != null && e!.trim().isNotEmpty).join(' • '),
                ),
                onTap: () => _abrirFormulario(cliente),
                trailing: IconButton(
                  tooltip: 'Excluir',
                  onPressed: () => _excluir(cliente),
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

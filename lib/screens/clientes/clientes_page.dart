import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../widgets/empty_state.dart';
import 'cadastro_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final List<Cliente> _clientes = [];

  Future<void> _abrirCadastro() async {
    final cliente = await Navigator.of(context).push<Cliente>(
      MaterialPageRoute<Cliente>(
        builder: (_) => const CadastroClientePage(),
      ),
    );
    if (cliente != null) setState(() => _clientes.add(cliente));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Novo cliente'),
      ),
      body: _clientes.isEmpty
          ? const EmptyState(
              icone: Icons.people_outline,
              titulo: 'Nenhum cliente cadastrado',
              descricao: 'Toque em “Novo cliente” para começar.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _clientes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final cliente = _clientes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(cliente.nome[0].toUpperCase()),
                    ),
                    title: Text(cliente.nome),
                    subtitle: Text(
                      '${cliente.telefone}\n${cliente.cidade} - ${cliente.uf}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

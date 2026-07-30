import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/session/session_manager.dart';
import '../../models/servico.dart';
import '../../repositories/servico_repository.dart';
import 'servico_form_screen.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final _repository = ServicoRepository();
  late Future<List<Servico>> _future;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _future = _repository.listar();
  }

  Future<void> _abrir([Servico? servico]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ServicoFormScreen(servico: servico)),
    );
    if (changed == true && mounted) setState(_recarregar);
  }

  Future<void> _excluir(Servico servico) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir serviço'),
        content: Text('Excluir "${servico.descricao}"?'),
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
      await _repository.excluir(servico);
      if (mounted) setState(_recarregar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrir,
        icon: const Icon(Icons.add),
        label: const Text('Novo serviço'),
      ),
      body: FutureBuilder<List<Servico>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final servicos = snapshot.data ?? <Servico>[];
          if (servicos.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: servicos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final servico = servicos[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.build)),
                title: Text(servico.descricao),
                subtitle: Text(formatCurrency(servico.valorPadrao)),
                onTap: () => _abrir(servico),
                trailing: IconButton(
                  onPressed: () => _excluir(servico),
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

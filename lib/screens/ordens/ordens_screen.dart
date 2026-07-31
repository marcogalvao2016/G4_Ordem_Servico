import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/session/session_manager.dart';
import '../../models/ordem_servico.dart';
import '../../repositories/ordem_servico_repository.dart';
import '../../widgets/elegant_list_card.dart';
import 'ordem_form_screen.dart';

class OrdensScreen extends StatefulWidget {
  const OrdensScreen({super.key});

  @override
  State<OrdensScreen> createState() => _OrdensScreenState();
}

class _OrdensScreenState extends State<OrdensScreen> {
  final _repository = OrdemServicoRepository();
  late Future<List<OrdemServico>> _future;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _future = _repository.listar();
  }

  Future<void> _abrir([OrdemServico? ordem]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => OrdemFormScreen(ordem: ordem)),
    );
    if (changed == true && mounted) setState(_recarregar);
  }

  Future<void> _excluir(OrdemServico ordem) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir ordem'),
        content: Text('Excluir a OS ${ordem.numeroOs}?'),
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
      await _repository.excluir(ordem);
      if (mounted) setState(_recarregar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrir,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: FutureBuilder<List<OrdemServico>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final ordens = snapshot.data ?? <OrdemServico>[];
          if (ordens.isEmpty) {
            return const Center(child: Text('Nenhuma ordem cadastrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 96),
            itemCount: ordens.length,
            itemBuilder: (_, index) {
              final ordem = ordens[index];
              return ElegantListCard(
                icon: Icons.assignment_outlined,
                title: 'OS ${ordem.numeroOs.toString().padLeft(6, '0')}',
                badges: <Widget>[
                  ElegantBadge(
                    label: ordem.status.replaceAll('_', ' '),
                    icon: Icons.flag_outlined,
                    emphasis: true,
                  ),
                  ElegantBadge(
                    label: formatCurrency(ordem.valorTotal),
                    icon: Icons.payments_outlined,
                  ),
                  ElegantBadge(
                    label: '${ordem.dataAbertura.day.toString().padLeft(2, '0')}/${ordem.dataAbertura.month.toString().padLeft(2, '0')}/${ordem.dataAbertura.year}',
                    icon: Icons.calendar_today_outlined,
                  ),
                  ElegantBadge(
                    label: ordem.descricaoProblema,
                    icon: Icons.description_outlined,
                  ),
                ],
                onTap: () => _abrir(ordem),
                onDelete: () => _excluir(ordem),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/checklist_template.dart';
import '../../models/vistoria_veiculo.dart';

class VistoriaDashboard extends StatelessWidget {
  const VistoriaDashboard({
    super.key,
    required this.numeroOs,
    required this.template,
    required this.vistoria,
    required this.onAbrirEtapa,
  });

  final int numeroOs;
  final ChecklistTemplate template;
  final VistoriaVeiculo vistoria;
  final ValueChanged<int> onAbrirEtapa;

  bool get _identificacaoConcluida =>
      vistoria.nomeMotorista.trim().isNotEmpty &&
      vistoria.local.trim().isNotEmpty &&
      vistoria.destino.trim().isNotEmpty &&
      vistoria.km.trim().isNotEmpty;

  bool get _atendimentoConcluido =>
      vistoria.tiposAtendimento.isNotEmpty && vistoria.motivos.isNotEmpty;

  bool get _avariasConcluidas => true;

  bool get _pneusConcluidos => template.pneus.keys.every(
        (key) => (vistoria.pneus[key] ?? 'Não verificado') != 'Não verificado',
      );

  bool get _acessoriosConcluidos {
    final itens = template.gruposAcessorios.expand((grupo) => grupo.itens);
    return itens.every(
      (item) => (vistoria.acessorios[item] ?? 'Não verificado') != 'Não verificado',
    );
  }

  bool get _finalizacaoConcluida =>
      vistoria.proprietarioOrientado &&
      vistoria.patioCiente &&
      vistoria.prestadorNome.trim().isNotEmpty;

  List<bool> get _status => <bool>[
        _identificacaoConcluida,
        _atendimentoConcluido,
        _avariasConcluidas,
        _pneusConcluidos,
        _acessoriosConcluidos,
        _finalizacaoConcluida,
      ];

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final concluidas = status.where((item) => item).length;
    final progresso = concluidas / status.length;

    final avarias = vistoria.danos.length;
    final observacoes = vistoria.danos.where((dano) {
      final tipo = (dano['tipo'] ?? '').toLowerCase();
      return tipo == 'risco' || tipo == 'pintura' || tipo == 'ferrugem';
    }).length;
    final relevantes = avarias - observacoes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vistoria da OS $numeroOs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text('${template.nome} • ${template.segmento}'),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(progresso * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$concluidas de ${status.length} etapas concluídas'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.check_circle_outline,
                value: '$concluidas',
                label: 'Etapas OK',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.warning_amber_rounded,
                value: '$observacoes',
                label: 'Observações',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.report_gmailerrorred_outlined,
                value: '$relevantes',
                label: 'Avarias',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Etapas da vistoria', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(status.length, (index) {
          final etapa = template.etapas[index + 1];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => onAbrirEtapa(index + 1),
              leading: CircleAvatar(
                child: Icon(status[index] ? Icons.check : Icons.more_horiz),
              ),
              title: Text(etapa.titulo),
              subtitle: Text(etapa.descricao),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        }),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

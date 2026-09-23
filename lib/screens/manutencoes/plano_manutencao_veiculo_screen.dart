import 'package:flutter/material.dart';

import '../../models/item_atendimento.dart';
import '../../models/manutencao_preventiva.dart';
import '../../repositories/manutencao_preventiva_repository.dart';

class PlanoManutencaoVeiculoScreen extends StatefulWidget {
  const PlanoManutencaoVeiculoScreen({
    super.key,
    required this.item,
    required this.kmAtual,
    required this.executadasNestaOrdem,
  });

  final ItemAtendimento item;
  final int? kmAtual;
  final Set<String> executadasNestaOrdem;

  @override
  State<PlanoManutencaoVeiculoScreen> createState() => _PlanoManutencaoVeiculoScreenState();
}

class _PlanoManutencaoVeiculoScreenState extends State<PlanoManutencaoVeiculoScreen> {
  final _repository = ManutencaoPreventivaRepository();
  List<ManutencaoVeiculoStatus> _status = <ManutencaoVeiculoStatus>[];
  late Set<String> _selecionadas;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _selecionadas = Set<String>.of(widget.executadasNestaOrdem);
    _carregar();
  }

  Future<void> _carregar() async {
    final status = await _repository.listarStatusDoVeiculo(widget.item.uuid);
    if (!mounted) return;
    setState(() {
      _status = status;
      _carregando = false;
    });
  }

  Color _cor(String situacao, ColorScheme scheme) {
    switch (situacao) {
      case 'VENCIDA':
        return scheme.error;
      case 'PROXIMA':
      case 'VERIFICAR':
        return scheme.tertiary;
      case 'EM_DIA':
        return scheme.primary;
      default:
        return scheme.outline;
    }
  }

  String _rotulo(String situacao) {
    switch (situacao) {
      case 'VENCIDA': return 'VENCIDA';
      case 'PROXIMA': return 'PRÓXIMA';
      case 'VERIFICAR': return 'VERIFICAR';
      case 'EM_DIA': return 'EM DIA';
      default: return 'SEM HISTÓRICO';
    }
  }

  String _historico(ManutencaoVeiculoStatus item) {
    final ultima = item.ultimaExecucao;
    if (ultima == null) return 'Nenhuma execução registrada';
    final partes = <String>['Última: ${ultima.dataExecucao.day.toString().padLeft(2, '0')}/${ultima.dataExecucao.month.toString().padLeft(2, '0')}/${ultima.dataExecucao.year}'];
    if (ultima.quilometragem != null) partes.add('${ultima.quilometragem} km');
    final proxKm = item.proximaKm();
    final proxData = item.proximaData();
    if (proxKm != null) partes.add('Próxima: $proxKm km');
    if (proxData != null) partes.add('ou ${proxData.day.toString().padLeft(2, '0')}/${proxData.month.toString().padLeft(2, '0')}/${proxData.year}');
    return partes.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _selecionadas);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plano de manutenção'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, _selecionadas),
              child: const Text('Concluir'),
            ),
          ],
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.item.descricao, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('${widget.item.marca ?? ''} ${widget.item.modelo ?? ''} ${widget.item.placa ?? ''}'.trim()),
                          const SizedBox(height: 4),
                          Text(widget.kmAtual == null ? 'Informe a quilometragem atual na OS para avaliar os intervalos por km.' : 'Quilometragem atual: ${widget.kmAtual} km'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._status.map((status) {
                    final situacao = status.situacao(kmAtual: widget.kmAtual);
                    final cor = _cor(situacao, scheme);
                    final selecionada = _selecionadas.contains(status.manutencao.uuid);
                    return Card(
                      child: CheckboxListTile(
                        value: selecionada,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selecionadas.add(status.manutencao.uuid);
                            } else {
                              _selecionadas.remove(status.manutencao.uuid);
                            }
                          });
                        },
                        title: Row(
                          children: <Widget>[
                            Expanded(child: Text(status.manutencao.descricao)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(border: Border.all(color: cor), borderRadius: BorderRadius.circular(12)),
                              child: Text(_rotulo(situacao), style: TextStyle(color: cor, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${status.manutencao.categoria} • ${_historico(status)}\nMarque se esta manutenção foi executada nesta OS.'),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

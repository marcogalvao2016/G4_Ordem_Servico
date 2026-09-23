import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/cliente.dart';
import '../../models/ordem_servico.dart';
import '../../repositories/cliente_repository.dart';
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
  final _clienteRepository = ClienteRepository();
  final _numeroController = TextEditingController();

  late Future<List<OrdemServico>> _future;
  late Future<List<Cliente>> _clientesFuture;

  String? _statusSelecionado;
  String? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    _recarregar();
    _clientesFuture = _clienteRepository.listar();
    _numeroController.addListener(_atualizarFiltros);
  }

  @override
  void dispose() {
    _numeroController.removeListener(_atualizarFiltros);
    _numeroController.dispose();
    super.dispose();
  }

  void _atualizarFiltros() {
    if (mounted) setState(() {});
  }

  void _recarregar() {
    _future = _repository.listar();
  }

  void _limparFiltros() {
    setState(() {
      _statusSelecionado = null;
      _clienteSelecionado = null;
      _numeroController.clear();
    });
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

  List<OrdemServico> _aplicarFiltros(List<OrdemServico> ordens) {
    final numero = _numeroController.text.trim();

    return ordens.where((ordem) {
      if (_statusSelecionado != null && ordem.status != _statusSelecionado) {
        return false;
      }
      if (_clienteSelecionado != null &&
          ordem.clienteUuid != _clienteSelecionado) {
        return false;
      }
      if (numero.isNotEmpty && !ordem.numeroOs.toString().contains(numero)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _filtros(List<OrdemServico> ordens, List<Cliente> clientes) {
    final status = ordens.map((e) => e.status).toSet().toList()..sort();
    final temFiltro = _statusSelecionado != null ||
        _clienteSelecionado != null ||
        _numeroController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.filter_alt_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (temFiltro)
                  TextButton.icon(
                    onPressed: _limparFiltros,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _numeroController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número da OS',
                hintText: 'Ex.: 25',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _statusSelecionado,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos os status'),
                ),
                ...status.map(
                  (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s.replaceAll('_', ' ')),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _statusSelecionado = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _clienteSelecionado,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                prefixIcon: Icon(Icons.person_search_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos os clientes'),
                ),
                ...clientes.map(
                  (cliente) => DropdownMenuItem<String>(
                    value: cliente.uuid,
                    child: Text(
                      cliente.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _clienteSelecionado = value),
            ),
          ],
        ),
      ),
    );
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
      body: FutureBuilder<List<Cliente>>(
        future: _clientesFuture,
        builder: (_, clientesSnapshot) {
          if (clientesSnapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (clientesSnapshot.hasError) {
            return Center(child: Text('Erro: ${clientesSnapshot.error}'));
          }

          final clientes = clientesSnapshot.data ?? <Cliente>[];

          return FutureBuilder<List<OrdemServico>>(
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

              final ordensFiltradas = _aplicarFiltros(ordens);

              return Column(
                children: <Widget>[
                  _filtros(ordens, clientes),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    child: Row(
                      children: <Widget>[
                        Text(
                          '${ordensFiltradas.length} ordem(ns) encontrada(s)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ordensFiltradas.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma ordem encontrada com os filtros informados.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 6, bottom: 96),
                            itemCount: ordensFiltradas.length,
                            itemBuilder: (_, index) {
                              final ordem = ordensFiltradas[index];
                              return ElegantListCard(
                                icon: Icons.assignment_outlined,
                                title:
                                    'OS ${ordem.numeroOs.toString().padLeft(6, '0')}',
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
                                    label:
                                        '${ordem.dataAbertura.day.toString().padLeft(2, '0')}/${ordem.dataAbertura.month.toString().padLeft(2, '0')}/${ordem.dataAbertura.year}',
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
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

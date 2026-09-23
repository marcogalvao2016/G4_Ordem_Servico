import 'package:flutter/material.dart';

import '../../models/item_atendimento.dart';
import 'cadastro_item_page.dart';

class ItensPage extends StatefulWidget {
  const ItensPage({super.key});

  @override
  State<ItensPage> createState() => _ItensPageState();
}

class _ItensPageState extends State<ItensPage> {
  final List<ItemAtendimento> _itens = [];
  String _filtro = '';

  List<ItemAtendimento> get _itensFiltrados {
    final filtro = _filtro.trim().toLowerCase();

    if (filtro.isEmpty) return _itens;

    return _itens.where((item) {
      final conteudo = [
        item.cliente,
        item.tipo,
        item.titulo,
        item.marca,
        item.modelo,
        item.identificacaoPrincipal,
      ].join(' ').toLowerCase();

      return conteudo.contains(filtro);
    }).toList();
  }

  Future<void> _novoItem() async {
    final item = await Navigator.push<ItemAtendimento>(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroItemPage(),
      ),
    );

    if (item == null) return;

    setState(() => _itens.add(item));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item cadastrado com sucesso.')),
    );
  }

  Future<void> _editarItem(int indiceReal) async {
    final itemAtual = _itens[indiceReal];

    final itemEditado = await Navigator.push<ItemAtendimento>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroItemPage(item: itemAtual),
      ),
    );

    if (itemEditado == null) return;

    setState(() => _itens[indiceReal] = itemEditado);
  }

  Future<void> _excluirItem(int indiceReal) async {
    final item = _itens[indiceReal];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Deseja excluir "${item.titulo}"?'),
        actions: [
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

    if (confirmar != true) return;

    setState(() => _itens.removeAt(indiceReal));
  }

  IconData _iconeTipo(String tipo) {
    switch (tipo) {
      case 'Carro':
        return Icons.directions_car;
      case 'Caminhão':
        return Icons.local_shipping;
      case 'Moto':
        return Icons.two_wheeler;
      case 'Máquina agrícola':
        return Icons.agriculture;
      case 'Computador':
        return Icons.computer;
      case 'Ar-condicionado':
        return Icons.ac_unit;
      default:
        return Icons.precision_manufacturing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = _itensFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoItem,
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (valor) => setState(() => _filtro = valor),
              decoration: InputDecoration(
                labelText: 'Pesquisar item',
                hintText: 'Cliente, placa, série, marca ou modelo',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => _filtro = ''),
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: itens.isEmpty
                ? _EstadoVazio(
                    possuiCadastro: _itens.isNotEmpty,
                    onNovoItem: _novoItem,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                    itemCount: itens.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = itens[index];
                      final indiceReal = _itens.indexOf(item);
                      final identificacao = item.identificacaoPrincipal;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_iconeTipo(item.tipo)),
                          ),
                          title: Text(
                            item.titulo,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              item.cliente,
                              item.tipo,
                              if (identificacao.isNotEmpty) identificacao,
                            ].join(' • '),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (acao) {
                              if (acao == 'editar') {
                                _editarItem(indiceReal);
                              } else if (acao == 'excluir') {
                                _excluirItem(indiceReal);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'editar',
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Editar'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'excluir',
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Excluir'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _editarItem(indiceReal),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final bool possuiCadastro;
  final VoidCallback onNovoItem;

  const _EstadoVazio({
    required this.possuiCadastro,
    required this.onNovoItem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              possuiCadastro ? Icons.search_off : Icons.inventory_2_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              possuiCadastro
                  ? 'Nenhum item encontrado'
                  : 'Nenhum item cadastrado',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              possuiCadastro
                  ? 'Altere os termos da pesquisa.'
                  : 'Cadastre veículos, máquinas ou equipamentos atendidos.',
              textAlign: TextAlign.center,
            ),
            if (!possuiCadastro) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onNovoItem,
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar primeiro item'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

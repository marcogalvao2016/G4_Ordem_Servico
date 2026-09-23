import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/produto.dart';
import '../../repositories/produto_repository.dart';
import '../../widgets/elegant_list_card.dart';
import 'produto_form_screen.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final _repository = ProdutoRepository();
  late Future<List<Produto>> _future;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() => _future = _repository.listar();

  Future<void> _abrir([Produto? produto]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdutoFormScreen(produto: produto)),
    );
    if (changed == true && mounted) setState(_recarregar);
  }

  Future<void> _excluir(Produto produto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Excluir "${produto.descricao}"?'),
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
      await _repository.excluir(produto);
      if (mounted) setState(_recarregar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrir,
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: FutureBuilder<List<Produto>>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final produtos = snapshot.data ?? <Produto>[];
          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 96),
            itemCount: produtos.length,
            itemBuilder: (_, index) {
              final produto = produtos[index];
              final fiscal = <String>[
                if ((produto.ncm ?? '').isNotEmpty) 'NCM ${produto.ncm}',
                if ((produto.csosn ?? '').isNotEmpty) 'CSOSN ${produto.csosn}',
                if ((produto.cfop ?? '').isNotEmpty) 'CFOP ${produto.cfop}',
              ].join(' • ');
              return ElegantListCard(
                icon: Icons.inventory_2_outlined,
                title: '${produto.codigo} - ${produto.descricao}',
                badges: <Widget>[
                  ElegantBadge(label: produto.unidade, icon: Icons.straighten_outlined),
                  ElegantBadge(
                    label: formatCurrency(produto.valorVenda),
                    icon: Icons.payments_outlined,
                    emphasis: true,
                  ),
                  if (fiscal.isNotEmpty)
                    ElegantBadge(label: fiscal, icon: Icons.receipt_long_outlined),
                ],
                onTap: () => _abrir(produto),
                onDelete: () => _excluir(produto),
              );
            },
          );
        },
      ),
    );
  }
}

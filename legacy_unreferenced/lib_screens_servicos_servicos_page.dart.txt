import 'package:flutter/material.dart';

import '../../models/servico.dart';
import '../../widgets/empty_state.dart';
import 'cadastro_servico_page.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final List<Servico> _servicos = [];

  Future<void> _abrirCadastro() async {
    final servico = await Navigator.of(context).push<Servico>(
      MaterialPageRoute<Servico>(
        builder: (_) => const CadastroServicoPage(),
      ),
    );
    if (servico != null) setState(() => _servicos.add(servico));
  }

  String _formatarMoeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Novo serviço'),
      ),
      body: _servicos.isEmpty
          ? const EmptyState(
              icone: Icons.handyman_outlined,
              titulo: 'Nenhum serviço cadastrado',
              descricao: 'Cadastre os serviços prestados e seus valores.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _servicos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final servico = _servicos[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.build_outlined),
                    ),
                    title: Text(servico.descricao),
                    subtitle: Text(
                      servico.observacao.isEmpty
                          ? 'Sem observações'
                          : servico.observacao,
                    ),
                    trailing: Text(
                      _formatarMoeda(servico.valor),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

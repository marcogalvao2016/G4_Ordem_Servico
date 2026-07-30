import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../clientes/clientes_screen.dart';
import '../itens/itens_screen.dart';
import '../login/login_screen.dart';
import '../ordens/ordens_screen.dart';
import '../servicos/servicos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await SessionManager.instance.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance;

    final modules = <_Module>[
      _Module(
        title: 'Clientes',
        icon: Icons.people_alt_outlined,
        builder: (_) => const ClientesScreen(),
      ),
      _Module(
        title: 'Itens',
        icon: Icons.devices_other_outlined,
        builder: (_) => const ItensScreen(),
      ),
      _Module(
        title: 'Serviços',
        icon: Icons.build_outlined,
        builder: (_) => const ServicosScreen(),
      ),
      _Module(
        title: 'Ordens de Serviço',
        icon: Icons.assignment_outlined,
        builder: (_) => const OrdensScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('G4 OS'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(session.usuarioNome ?? 'Usuário'),
              subtitle: Text(session.perfil ?? ''),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 150,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: module.builder),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(module.icon, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          module.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
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

class _Module {
  const _Module({
    required this.title,
    required this.icon,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

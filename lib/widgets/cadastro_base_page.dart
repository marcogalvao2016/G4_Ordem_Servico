import 'package:flutter/material.dart';

class CadastroBasePage extends StatelessWidget {
  final String titulo;
  final Widget child;
  final VoidCallback onSalvar;

  const CadastroBasePage({
    super.key,
    required this.titulo,
    required this.child,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onSalvar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: child,
          ),
        ),
      ),
    );
  }
}

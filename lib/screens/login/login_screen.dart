import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'admin@g4os.com.br');
  final _senha = TextEditingController(text: '123456');
  final _authService = AuthService();

  bool _ocultarSenha = true;
  bool _entrando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _entrando = true);

    try {
      final result = await _authService.login(
        email: _email.text,
        senha: _senha.text,
      );

      await SessionManager.instance.saveSession(
        token: result.token,
        empresaUuid: result.empresaUuid,
        usuarioUuid: result.usuarioUuid,
        usuarioNome: result.usuarioNome,
        perfil: result.perfil,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao entrar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 72,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'G4 OS',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text('Gestão de Ordens de Serviço'),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Informe o e-mail.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _senha,
                          obscureText: _ocultarSenha,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _ocultarSenha = !_ocultarSenha);
                              },
                              icon: Icon(
                                _ocultarSenha
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Informe a senha.'
                              : null,
                          onFieldSubmitted: (_) => _entrar(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _entrando ? null : _entrar,
                            icon: const Icon(Icons.login),
                            label: Text(_entrando ? 'Entrando...' : 'Entrar'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Acesso temporário de desenvolvimento',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

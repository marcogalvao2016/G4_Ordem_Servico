import 'dart:async';

import '../models/auth_result.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  Future<AuthResult> login({
    required String email,
    required String senha,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail != 'admin@g4os.com.br' || senha != '123456') {
      throw const AuthException('E-mail ou senha inválidos.');
    }

    // Autenticação local temporária.
    // Esta implementação será substituída pela API REST/JWT.
    return const AuthResult(
      token: 'TOKEN-LOCAL-DEMONSTRACAO',
      empresaUuid: 'EMPRESA-DEMONSTRACAO',
      usuarioUuid: 'USUARIO-ADMIN-DEMONSTRACAO',
      usuarioNome: 'Administrador',
      perfil: 'ADMINISTRADOR',
    );
  }
}

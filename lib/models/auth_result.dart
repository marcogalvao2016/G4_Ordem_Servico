class AuthResult {
  const AuthResult({
    required this.token,
    required this.empresaUuid,
    required this.usuarioUuid,
    required this.usuarioNome,
    required this.perfil,
  });

  final String token;
  final String empresaUuid;
  final String usuarioUuid;
  final String usuarioNome;
  final String perfil;
}

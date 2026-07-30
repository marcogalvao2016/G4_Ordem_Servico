import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  static const _keyToken = 'session_token';
  static const _keyEmpresaUuid = 'session_empresa_uuid';
  static const _keyUsuarioUuid = 'session_usuario_uuid';
  static const _keyUsuarioNome = 'session_usuario_nome';
  static const _keyPerfil = 'session_perfil';

  SharedPreferences? _preferences;

  String? token;
  String? empresaUuid;
  String? usuarioUuid;
  String? usuarioNome;
  String? perfil;

  bool get isAuthenticated {
    return token != null &&
        token!.isNotEmpty &&
        empresaUuid != null &&
        empresaUuid!.isNotEmpty &&
        usuarioUuid != null &&
        usuarioUuid!.isNotEmpty;
  }

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();

    token = _preferences!.getString(_keyToken);
    empresaUuid = _preferences!.getString(_keyEmpresaUuid);
    usuarioUuid = _preferences!.getString(_keyUsuarioUuid);
    usuarioNome = _preferences!.getString(_keyUsuarioNome);
    perfil = _preferences!.getString(_keyPerfil);
  }

  Future<void> saveSession({
    required String token,
    required String empresaUuid,
    required String usuarioUuid,
    required String usuarioNome,
    required String perfil,
  }) async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();

    await preferences.setString(_keyToken, token);
    await preferences.setString(_keyEmpresaUuid, empresaUuid);
    await preferences.setString(_keyUsuarioUuid, usuarioUuid);
    await preferences.setString(_keyUsuarioNome, usuarioNome);
    await preferences.setString(_keyPerfil, perfil);

    this.token = token;
    this.empresaUuid = empresaUuid;
    this.usuarioUuid = usuarioUuid;
    this.usuarioNome = usuarioNome;
    this.perfil = perfil;
  }

  Future<void> clear() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();

    await preferences.remove(_keyToken);
    await preferences.remove(_keyEmpresaUuid);
    await preferences.remove(_keyUsuarioUuid);
    await preferences.remove(_keyUsuarioNome);
    await preferences.remove(_keyPerfil);

    token = null;
    empresaUuid = null;
    usuarioUuid = null;
    usuarioNome = null;
    perfil = null;
  }

  String requireEmpresaUuid() {
    final value = empresaUuid;
    if (value == null || value.isEmpty) {
      throw StateError('Nenhuma empresa autenticada na sessão.');
    }
    return value;
  }
}

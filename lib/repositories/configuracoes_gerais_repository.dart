import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/configuracoes_gerais.dart';

class ConfiguracoesGeraisRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<ConfiguracoesGerais> obter() async {
    final db = await _db;
    final maps = await db.query(
      'configuracoes_gerais',
      where: 'empresa_uuid = ?',
      whereArgs: <Object?>[_empresaUuid],
      limit: 1,
    );
    if (maps.isEmpty) {
      return ConfiguracoesGerais(empresaUuid: _empresaUuid);
    }
    return ConfiguracoesGerais.fromMap(maps.first);
  }

  Future<void> salvar(ConfiguracoesGerais configuracoes) async {
    final db = await _db;
    await db.insert(
      'configuracoes_gerais',
      configuracoes.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

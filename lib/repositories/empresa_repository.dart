import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/empresa.dart';

class EmpresaRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<Empresa?> obter() async {
    final db = await _db;
    final maps = await db.query(
      'empresa_config',
      where: 'empresa_uuid = ?',
      whereArgs: <Object?>[_empresaUuid],
      limit: 1,
    );
    return maps.isEmpty ? null : Empresa.fromMap(maps.first);
  }

  Future<void> salvar(Empresa empresa) async {
    final db = await _db;
    final existente = await obter();
    final map = empresa.toMap()..remove('id');
    map['sincronizado'] = 0;
    map['atualizado_em'] = DateTime.now().toIso8601String();

    if (existente == null) {
      await db.insert('empresa_config', map);
    } else {
      await db.update(
        'empresa_config',
        map,
        where: 'empresa_uuid = ?',
        whereArgs: <Object?>[_empresaUuid],
      );
    }
  }
}

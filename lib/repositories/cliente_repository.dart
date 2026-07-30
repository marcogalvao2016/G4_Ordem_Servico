import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/cliente.dart';

class ClienteRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<Cliente>> listar() async {
    final db = await _db;
    final maps = await db.query(
      'clientes',
      where: 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'nome COLLATE NOCASE',
    );
    return maps.map(Cliente.fromMap).toList();
  }

  Future<void> salvar(Cliente cliente) async {
    final db = await _db;
    final map = cliente.toMap()..remove('id');
    await db.insert('clientes', map);
  }

  Future<void> atualizar(Cliente cliente) async {
    final db = await _db;
    final map = cliente.toMap()
      ..remove('id')
      ..['sincronizado'] = 0
      ..['atualizado_em'] = DateTime.now().toIso8601String();

    await db.update(
      'clientes',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[cliente.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(Cliente cliente) async {
    final db = await _db;
    await db.update(
      'clientes',
      <String, Object?>{
        'excluido': 1,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[cliente.uuid, _empresaUuid],
    );
  }
}

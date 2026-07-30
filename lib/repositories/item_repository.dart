import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/item_atendimento.dart';

class ItemRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<ItemAtendimento>> listar() async {
    final db = await _db;
    final maps = await db.query(
      'itens',
      where: 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'descricao COLLATE NOCASE',
    );
    return maps.map(ItemAtendimento.fromMap).toList();
  }

  Future<List<ItemAtendimento>> listarPorCliente(String clienteUuid) async {
    final db = await _db;
    final maps = await db.query(
      'itens',
      where: 'empresa_uuid = ? AND cliente_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, clienteUuid],
      orderBy: 'descricao COLLATE NOCASE',
    );
    return maps.map(ItemAtendimento.fromMap).toList();
  }

  Future<void> salvar(ItemAtendimento item) async {
    final db = await _db;
    final map = item.toMap()..remove('id');
    await db.insert('itens', map);
  }

  Future<void> atualizar(ItemAtendimento item) async {
    final db = await _db;
    final map = item.toMap()
      ..remove('id')
      ..['sincronizado'] = 0
      ..['atualizado_em'] = DateTime.now().toIso8601String();

    await db.update(
      'itens',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[item.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(ItemAtendimento item) async {
    final db = await _db;
    await db.update(
      'itens',
      <String, Object?>{
        'excluido': 1,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[item.uuid, _empresaUuid],
    );
  }
}

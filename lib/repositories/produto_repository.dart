import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/produto.dart';

class ProdutoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<Produto>> listar() async {
    final db = await _db;
    final maps = await db.query(
      'produtos',
      where: 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'descricao COLLATE NOCASE',
    );
    return maps.map(Produto.fromMap).toList();
  }

  Future<int> proximoCodigo() async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(MAX(codigo), 0) + 1 AS proximo
      FROM produtos
      WHERE empresa_uuid = ?
      ''',
      <Object?>[_empresaUuid],
    );
    return (result.first['proximo'] as int?) ?? 1;
  }

  Future<void> salvar(Produto produto) async {
    final db = await _db;
    final map = produto.toMap()..remove('id');
    await db.insert('produtos', map);
  }

  Future<void> atualizar(Produto produto) async {
    final db = await _db;
    final map = produto.toMap()
      ..remove('id')
      ..['sincronizado'] = 0
      ..['atualizado_em'] = DateTime.now().toIso8601String();
    await db.update(
      'produtos',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[produto.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(Produto produto) async {
    final db = await _db;
    await db.update(
      'produtos',
      <String, Object?>{
        'excluido': 1,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[produto.uuid, _empresaUuid],
    );
  }
}

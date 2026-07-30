import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/servico.dart';

class ServicoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<Servico>> listar() async {
    final db = await _db;
    final maps = await db.query(
      'servicos',
      where: 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'descricao COLLATE NOCASE',
    );
    return maps.map(Servico.fromMap).toList();
  }

  Future<void> salvar(Servico servico) async {
    final db = await _db;
    final map = servico.toMap()..remove('id');
    await db.insert('servicos', map);
  }

  Future<void> atualizar(Servico servico) async {
    final db = await _db;
    final map = servico.toMap()
      ..remove('id')
      ..['sincronizado'] = 0
      ..['atualizado_em'] = DateTime.now().toIso8601String();

    await db.update(
      'servicos',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[servico.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(Servico servico) async {
    final db = await _db;
    await db.update(
      'servicos',
      <String, Object?>{
        'excluido': 1,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[servico.uuid, _empresaUuid],
    );
  }
}

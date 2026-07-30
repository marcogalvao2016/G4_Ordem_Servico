import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/ordem_servico.dart';

class OrdemServicoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<OrdemServico>> listar() async {
    final db = await _db;
    final maps = await db.query(
      'ordens_servico',
      where: 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'numero_os DESC',
    );
    return maps.map(OrdemServico.fromMap).toList();
  }

  Future<int> proximoNumero() async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(MAX(numero_os), 0) + 1 AS proximo
      FROM ordens_servico
      WHERE empresa_uuid = ?
      ''',
      <Object?>[_empresaUuid],
    );
    return (result.first['proximo'] as int?) ?? 1;
  }

  Future<void> salvar(OrdemServico ordem) async {
    final db = await _db;
    final map = ordem.toMap()..remove('id');
    await db.insert('ordens_servico', map);
  }

  Future<void> atualizar(OrdemServico ordem) async {
    final db = await _db;
    final map = ordem.toMap()
      ..remove('id')
      ..['sincronizado'] = 0
      ..['atualizado_em'] = DateTime.now().toIso8601String();

    await db.update(
      'ordens_servico',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[ordem.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(OrdemServico ordem) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      <String, Object?>{
        'excluido': 1,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[ordem.uuid, _empresaUuid],
    );
  }
}

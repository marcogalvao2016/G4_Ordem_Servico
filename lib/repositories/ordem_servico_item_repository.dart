import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/ordem_servico_item.dart';

class OrdemServicoItemRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<OrdemServicoItem>> listarPorOrdem(String ordemUuid) async {
    final db = await _db;
    final maps = await db.query(
      'os_servicos',
      where: 'empresa_uuid = ? AND ordem_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, ordemUuid],
      orderBy: 'ordem, id',
    );
    return maps.map(OrdemServicoItem.fromMap).toList();
  }

  Future<void> substituirDaOrdem(
    String ordemUuid,
    List<OrdemServicoItem> itens,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await substituirDaOrdemTxn(txn, ordemUuid, itens);
    });
  }

  Future<void> substituirDaOrdemTxn(
    Transaction txn,
    String ordemUuid,
    List<OrdemServicoItem> itens,
  ) async {
    await txn.delete(
      'os_servicos',
      where: 'empresa_uuid = ? AND ordem_uuid = ?',
      whereArgs: <Object?>[_empresaUuid, ordemUuid],
    );

    for (var index = 0; index < itens.length; index++) {
      final map = itens[index].copyWith(ordem: index).toMap()..remove('id');
      await txn.insert('os_servicos', map);
    }
  }
}

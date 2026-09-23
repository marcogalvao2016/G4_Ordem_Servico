import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/ordem_servico_produto.dart';

class OrdemServicoProdutoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<OrdemServicoProduto>> listarPorOrdem(String ordemUuid) async {
    final db = await _db;
    final maps = await db.query(
      'os_produtos',
      where: 'empresa_uuid = ? AND ordem_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, ordemUuid],
      orderBy: 'ordem, id',
    );
    return maps.map(OrdemServicoProduto.fromMap).toList();
  }

  Future<void> substituirDaOrdem(
    String ordemUuid,
    List<OrdemServicoProduto> produtos,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'os_produtos',
        where: 'empresa_uuid = ? AND ordem_uuid = ?',
        whereArgs: <Object?>[_empresaUuid, ordemUuid],
      );

      for (var index = 0; index < produtos.length; index++) {
        final map = produtos[index].copyWith(ordem: index).toMap()..remove('id');
        await txn.insert('os_produtos', map);
      }
    });
  }
}

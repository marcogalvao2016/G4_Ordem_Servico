import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/checklist_os_item.dart';

class ChecklistOsRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<ChecklistOsItem>> listarPorOrdem(String ordemUuid) async {
    final db = await _db;
    final maps = await db.query(
      'os_checklist',
      where: 'empresa_uuid = ? AND ordem_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, ordemUuid],
      orderBy: 'ordem, id',
    );
    return maps.map(ChecklistOsItem.fromMap).toList();
  }

  Future<void> substituirDaOrdem(
    String ordemUuid,
    List<ChecklistOsItem> itens,
  ) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.delete(
        'os_checklist',
        where: 'empresa_uuid = ? AND ordem_uuid = ?',
        whereArgs: <Object?>[_empresaUuid, ordemUuid],
      );

      for (var index = 0; index < itens.length; index++) {
        final item = itens[index].copyWith(
          empresaUuid: _empresaUuid,
          ordemUuid: ordemUuid,
          ordem: index,
          atualizadoEm: DateTime.now(),
          sincronizado: false,
        );

        final map = item.toMap()..remove('id');
        await txn.insert('os_checklist', map);
      }
    });
  }
}

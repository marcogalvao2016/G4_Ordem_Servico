import 'package:sqflite/sqflite.dart';
import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/ordem_servico_foto.dart';

class OrdemServicoFotoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<OrdemServicoFoto>> listarPorOrdem(String ordemUuid) async {
    final db = await _db;
    final maps = await db.query('os_fotos',
      where: 'empresa_uuid = ? AND ordem_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, ordemUuid], orderBy: 'ordem, id');
    return maps.map(OrdemServicoFoto.fromMap).toList();
  }

  Future<void> substituirDaOrdem(String ordemUuid, List<OrdemServicoFoto> fotos) async {
    if (fotos.length > 6) throw StateError('A Ordem de Serviço permite no máximo 6 fotos.');
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('os_fotos', where: 'empresa_uuid = ? AND ordem_uuid = ?',
        whereArgs: <Object?>[_empresaUuid, ordemUuid]);
      for (var i = 0; i < fotos.length; i++) {
        final map = fotos[i].copyWith(ordem: i).toMap()..remove('id');
        await txn.insert('os_fotos', map);
      }
    });
  }
}

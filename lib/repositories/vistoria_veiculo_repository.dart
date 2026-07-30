import 'package:sqflite/sqflite.dart';
import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/vistoria_veiculo.dart';

class VistoriaVeiculoRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<VistoriaVeiculo?> buscarPorOrdem(String ordemUuid) async {
    final db=await _db;
    final rows=await db.query('os_vistoria_veiculo',where:'empresa_uuid = ? AND ordem_uuid = ?',whereArgs:[_empresaUuid,ordemUuid],limit:1);
    return rows.isEmpty?null:VistoriaVeiculo.fromMap(rows.first);
  }

  Future<void> salvar(VistoriaVeiculo vistoria) async {
    final db=await _db;
    final map=vistoria.copyWith(empresaUuid:_empresaUuid,atualizadoEm:DateTime.now(),sincronizado:false).toMap()..remove('id');
    await db.insert('os_vistoria_veiculo',map,conflictAlgorithm:ConflictAlgorithm.replace);
  }
}

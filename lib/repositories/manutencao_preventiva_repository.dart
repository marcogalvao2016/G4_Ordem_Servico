import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/manutencao_preventiva.dart';

class ManutencaoPreventivaRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<void> garantirPadroes() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM manutencoes_preventivas WHERE empresa_uuid = ? AND excluido = 0',
          <Object?>[_empresaUuid],
        )) ??
        0;
    if (count > 0) return;

    final agora = DateTime.now();
    const padroes = <(String, String, int?, int?, String)>[
      ('Troca de óleo e filtro de óleo', 'MOTOR', 10000, 12, 'Referência: 5.000 a 10.000 km. Ajuste conforme fabricante e tipo de óleo.'),
      ('Verificação do freio de mão', 'FREIOS', 10000, 12, 'Inspeção e regulagem quando necessário.'),
      ('Limpeza dos bicos injetores', 'MOTOR', 10000, null, 'Aplicar conforme recomendação do fabricante e condição de uso.'),
      ('Filtro de ar do motor', 'MOTOR', 15000, 12, 'Referência: 10.000 a 15.000 km.'),
      ('Filtro de combustível', 'MOTOR', 15000, 12, 'Referência: 10.000 a 15.000 km.'),
      ('Pastilhas e discos de freio', 'FREIOS', 15000, 12, 'Inspeção preventiva; troca conforme desgaste.'),
      ('Alinhamento e balanceamento', 'PNEUS', 10000, null, 'Também verificar após impactos, troca de pneus ou desgaste irregular.'),
      ('Rotação dos pneus', 'PNEUS', 10000, null, 'Seguir orientação do fabricante e tipo de pneu.'),
      ('Filtro do ar-condicionado (cabine)', 'AR-CONDICIONADO', 20000, 12, 'Referência: 20.000 a 40.000 km; antecipar em ambiente com poeira.'),
      ('Velas de ignição', 'MOTOR', 40000, null, 'Velas convencionais; consultar especificação do fabricante.'),
      ('Correia dentada - verificação', 'MOTOR', 40000, 12, 'Verificação preventiva; troca costuma ocorrer entre 60.000 e 100.000 km.'),
      ('Fluido de freio DOT 3/4', 'FREIOS', 40000, 24, 'Substituir por quilometragem ou tempo, o que ocorrer primeiro.'),
      ('Fluido da direção hidráulica', 'DIREÇÃO', 40000, 24, 'Quando aplicável ao veículo.'),
      ('Amortecedores e buchas de suspensão', 'SUSPENSÃO', 60000, 24, 'Inspeção; substituir conforme desgaste e segurança.'),
      ('Teste de carga da bateria', 'ELÉTRICA', 40000, 12, 'Realizar também na revisão anual.'),
      ('Correia do alternador / acessórios', 'MOTOR', 60000, 24, 'Inspecionar trincas, tensão e ruídos.'),
      ('Terminais da bateria / conexões elétricas', 'ELÉTRICA', 40000, 12, 'Verificar oxidação, aperto e integridade.'),
      ('Troca da correia dentada', 'MOTOR', 80000, 60, 'Referência entre 60.000 e 100.000 km; prevalece o manual do veículo.'),
      ('Velas iridium / platina', 'MOTOR', 80000, null, 'Maior durabilidade; seguir especificação do fabricante.'),
      ('Líquido de arrefecimento', 'ARREFECIMENTO', 60000, 24, 'Verificar especificação e período recomendado.'),
      ('Rolamentos de roda', 'SUSPENSÃO', 80000, null, 'Inspeção por ruído, folga e condição de uso.'),
      ("Bomba d'água", 'ARREFECIMENTO', 80000, null, 'Normalmente avaliada junto com a correia dentada.'),
      ('Revisão geral do sistema de freios', 'FREIOS', null, 12, 'Revisão anual independente da quilometragem.'),
      ('Verificação do sistema elétrico', 'ELÉTRICA', null, 12, 'Revisão anual independente da quilometragem.'),
      ('Teste anual da bateria', 'ELÉTRICA', null, 12, 'Revisão anual independente da quilometragem.'),
    ];

    final batch = db.batch();
    for (final item in padroes) {
      batch.insert('manutencoes_preventivas', <String, Object?>{
        'uuid': const Uuid().v4(),
        'empresa_uuid': _empresaUuid,
        'descricao': item.$1.toUpperCase(),
        'categoria': item.$2,
        'intervalo_km': item.$3,
        'intervalo_meses': item.$4,
        'observacoes': item.$5,
        'ativo': 1,
        'criado_em': agora.toIso8601String(),
        'atualizado_em': agora.toIso8601String(),
        'sincronizado': 0,
        'excluido': 0,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<ManutencaoPreventiva>> listar({bool somenteAtivos = false}) async {
    await garantirPadroes();
    final db = await _db;
    final maps = await db.query(
      'manutencoes_preventivas',
      where: somenteAtivos
          ? 'empresa_uuid = ? AND excluido = 0 AND ativo = 1'
          : 'empresa_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid],
      orderBy: 'categoria, descricao',
    );
    return maps.map(ManutencaoPreventiva.fromMap).toList();
  }

  Future<void> salvar(ManutencaoPreventiva item) async {
    final db = await _db;
    final map = item.toMap()..remove('id');
    await db.insert('manutencoes_preventivas', map);
  }

  Future<void> atualizar(ManutencaoPreventiva item) async {
    final db = await _db;
    final map = item.toMap()
      ..remove('id')
      ..['atualizado_em'] = DateTime.now().toIso8601String()
      ..['sincronizado'] = 0;
    await db.update(
      'manutencoes_preventivas',
      map,
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[item.uuid, _empresaUuid],
    );
  }

  Future<void> excluir(ManutencaoPreventiva item) async {
    final db = await _db;
    await db.update(
      'manutencoes_preventivas',
      <String, Object?>{
        'excluido': 1,
        'ativo': 0,
        'sincronizado': 0,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'uuid = ? AND empresa_uuid = ?',
      whereArgs: <Object?>[item.uuid, _empresaUuid],
    );
  }

  Future<Set<String>> listarIdsDaOrdem(String ordemUuid) async {
    final db = await _db;
    final maps = await db.query(
      'manutencao_execucoes',
      columns: <String>['manutencao_uuid'],
      where: 'empresa_uuid = ? AND ordem_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, ordemUuid],
    );
    return maps.map((e) => e['manutencao_uuid'] as String).toSet();
  }

  Future<List<ManutencaoVeiculoStatus>> listarStatusDoVeiculo(
    String itemUuid,
  ) async {
    final manutencoes = await listar(somenteAtivos: true);
    final db = await _db;
    final maps = await db.query(
      'manutencao_execucoes',
      where: 'empresa_uuid = ? AND item_uuid = ? AND excluido = 0',
      whereArgs: <Object?>[_empresaUuid, itemUuid],
      orderBy: 'data_execucao DESC, id DESC',
    );

    final ultimas = <String, ManutencaoExecucao>{};
    for (final map in maps) {
      final uuid = map['manutencao_uuid'] as String;
      if (ultimas.containsKey(uuid)) continue;
      ultimas[uuid] = ManutencaoExecucao(
        manutencaoUuid: uuid,
        dataExecucao: DateTime.parse(map['data_execucao'] as String),
        quilometragem: map['quilometragem'] as int?,
        ordemUuid: map['ordem_uuid'] as String?,
      );
    }

    return manutencoes
        .map((m) => ManutencaoVeiculoStatus(
              manutencao: m,
              ultimaExecucao: ultimas[m.uuid],
            ))
        .toList();
  }

  Future<void> substituirExecucoesDaOrdem({
    required String ordemUuid,
    required String itemUuid,
    required Set<String> manutencoesUuid,
    required int? quilometragem,
    required DateTime dataExecucao,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'manutencao_execucoes',
        <String, Object?>{
          'excluido': 1,
          'sincronizado': 0,
          'atualizado_em': DateTime.now().toIso8601String(),
        },
        where: 'empresa_uuid = ? AND ordem_uuid = ?',
        whereArgs: <Object?>[_empresaUuid, ordemUuid],
      );

      for (final manutencaoUuid in manutencoesUuid) {
        final existente = await txn.query(
          'manutencao_execucoes',
          where: 'empresa_uuid = ? AND ordem_uuid = ? AND manutencao_uuid = ?',
          whereArgs: <Object?>[_empresaUuid, ordemUuid, manutencaoUuid],
          limit: 1,
        );
        final agora = DateTime.now().toIso8601String();
        if (existente.isEmpty) {
          await txn.insert('manutencao_execucoes', <String, Object?>{
            'uuid': const Uuid().v4(),
            'empresa_uuid': _empresaUuid,
            'item_uuid': itemUuid,
            'manutencao_uuid': manutencaoUuid,
            'ordem_uuid': ordemUuid,
            'quilometragem': quilometragem,
            'data_execucao': dataExecucao.toIso8601String(),
            'observacao': null,
            'criado_em': agora,
            'atualizado_em': agora,
            'sincronizado': 0,
            'excluido': 0,
          });
        } else {
          await txn.update(
            'manutencao_execucoes',
            <String, Object?>{
              'item_uuid': itemUuid,
              'quilometragem': quilometragem,
              'data_execucao': dataExecucao.toIso8601String(),
              'atualizado_em': agora,
              'sincronizado': 0,
              'excluido': 0,
            },
            where: 'id = ?',
            whereArgs: <Object?>[existente.first['id']],
          );
        }
      }
    });
  }
}

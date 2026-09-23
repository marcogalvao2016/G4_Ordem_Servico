import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/dashboard_data.dart';

class DashboardRepository {
  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  static const _nomesMeses = <String>[
    'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
    'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
  ];

  Future<DashboardData> carregar() async {
    final db = await _db;
    final agora = DateTime.now();
    final inicioPeriodo = DateTime(agora.year, agora.month - 2, 1);
    final inicioIso = inicioPeriodo.toIso8601String();

    final mesesRaw = await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m', data_abertura) AS mes,
        COUNT(*) AS quantidade,
        COALESCE(SUM(valor_total), 0) AS valor
      FROM ordens_servico
      WHERE empresa_uuid = ?
        AND excluido = 0
        AND data_abertura >= ?
      GROUP BY strftime('%Y-%m', data_abertura)
      ORDER BY mes
      ''',
      <Object?>[_empresaUuid, inicioIso],
    );

    final porMes = <String, Map<String, Object?>>{
      for (final row in mesesRaw) row['mes'] as String: row,
    };

    final meses = <DashboardMes>[];
    for (var i = 0; i < 3; i++) {
      final data = DateTime(inicioPeriodo.year, inicioPeriodo.month + i, 1);
      final chave = '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}';
      final row = porMes[chave];
      meses.add(
        DashboardMes(
          chave: chave,
          rotulo: '${_nomesMeses[data.month - 1]}/${data.year.toString().substring(2)}',
          quantidade: (row?['quantidade'] as num? ?? 0).toInt(),
          valor: (row?['valor'] as num? ?? 0).toDouble(),
        ),
      );
    }

    final resumo = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'CONCLUIDA' THEN 1 ELSE 0 END) AS concluidas,
        SUM(CASE WHEN status NOT IN ('CONCLUIDA', 'CANCELADA') THEN 1 ELSE 0 END) AS abertas,
        COALESCE(SUM(valor_total), 0) AS valor
      FROM ordens_servico
      WHERE empresa_uuid = ?
        AND excluido = 0
        AND data_abertura >= ?
      ''',
      <Object?>[_empresaUuid, inicioIso],
    );

    final clientesRaw = await db.rawQuery(
      '''
      SELECT c.uuid, c.nome, c.telefone,
             o.numero_os, o.data_abertura
      FROM ordens_servico o
      INNER JOIN clientes c
        ON c.uuid = o.cliente_uuid
       AND c.empresa_uuid = o.empresa_uuid
      WHERE o.empresa_uuid = ?
        AND o.excluido = 0
        AND c.excluido = 0
        AND o.id = (
          SELECT o2.id
          FROM ordens_servico o2
          WHERE o2.empresa_uuid = o.empresa_uuid
            AND o2.cliente_uuid = o.cliente_uuid
            AND o2.excluido = 0
          ORDER BY o2.data_abertura DESC, o2.id DESC
          LIMIT 1
        )
      ORDER BY o.data_abertura DESC, o.id DESC
      LIMIT 5
      ''',
      <Object?>[_empresaUuid],
    );

    final itensRaw = await db.rawQuery(
      '''
      SELECT i.uuid, i.descricao, i.tipo, i.placa, i.marca, i.modelo,
             c.nome AS cliente_nome, o.numero_os, o.data_abertura
      FROM ordens_servico o
      INNER JOIN itens i
        ON i.uuid = o.item_uuid
       AND i.empresa_uuid = o.empresa_uuid
      INNER JOIN clientes c
        ON c.uuid = o.cliente_uuid
       AND c.empresa_uuid = o.empresa_uuid
      WHERE o.empresa_uuid = ?
        AND o.excluido = 0
        AND i.excluido = 0
        AND o.id = (
          SELECT o2.id
          FROM ordens_servico o2
          WHERE o2.empresa_uuid = o.empresa_uuid
            AND o2.item_uuid = o.item_uuid
            AND o2.excluido = 0
          ORDER BY o2.data_abertura DESC, o2.id DESC
          LIMIT 1
        )
      ORDER BY o.data_abertura DESC, o.id DESC
      LIMIT 5
      ''',
      <Object?>[_empresaUuid],
    );

    final r = resumo.first;
    return DashboardData(
      meses: meses,
      totalOrdens: (r['total'] as num? ?? 0).toInt(),
      ordensAbertas: (r['abertas'] as num? ?? 0).toInt(),
      ordensConcluidas: (r['concluidas'] as num? ?? 0).toInt(),
      valorPeriodo: (r['valor'] as num? ?? 0).toDouble(),
      clientesRecentes: clientesRaw.map((row) => DashboardClienteRecente(
        uuid: row['uuid'] as String,
        nome: row['nome'] as String,
        telefone: row['telefone'] as String?,
        numeroOs: (row['numero_os'] as num).toInt(),
        dataAtendimento: DateTime.parse(row['data_abertura'] as String),
      )).toList(),
      itensRecentes: itensRaw.map((row) => DashboardItemRecente(
        uuid: row['uuid'] as String,
        descricao: row['descricao'] as String,
        tipo: row['tipo'] as String,
        placa: row['placa'] as String?,
        marca: row['marca'] as String?,
        modelo: row['modelo'] as String?,
        clienteNome: row['cliente_nome'] as String,
        numeroOs: (row['numero_os'] as num).toInt(),
        dataAtendimento: DateTime.parse(row['data_abertura'] as String),
      )).toList(),
    );
  }
}

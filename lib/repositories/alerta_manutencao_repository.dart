import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../models/alerta_manutencao.dart';
import '../models/manutencao_preventiva.dart';
import 'manutencao_preventiva_repository.dart';

class AlertaManutencaoRepository {
  final _manutencaoRepository = ManutencaoPreventivaRepository();

  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<List<AlertaManutencao>> listarAlertas() async {
    await _manutencaoRepository.garantirPadroes();
    final db = await _db;
    final veiculos = await db.rawQuery('''
      SELECT
        i.uuid AS item_uuid,
        i.descricao AS item_descricao,
        i.marca,
        i.modelo,
        i.placa,
        i.criado_em AS item_criado_em,
        c.uuid AS cliente_uuid,
        c.nome AS cliente_nome,
        c.telefone AS cliente_telefone,
        (
          SELECT os.km_atual
          FROM ordens_servico os
          WHERE os.empresa_uuid = i.empresa_uuid
            AND os.item_uuid = i.uuid
            AND os.excluido = 0
            AND os.km_atual IS NOT NULL
          ORDER BY os.data_abertura DESC, os.id DESC
          LIMIT 1
        ) AS km_atual
      FROM itens i
      INNER JOIN clientes c
        ON c.uuid = i.cliente_uuid
       AND c.empresa_uuid = i.empresa_uuid
      WHERE i.empresa_uuid = ?
        AND i.excluido = 0
        AND c.excluido = 0
        AND UPPER(i.tipo) IN ('VEICULO', 'VEÍCULO', 'CARRO', 'AUTOMOVEL', 'AUTOMÓVEL', 'MOTO', 'CAMINHAO', 'CAMINHÃO', 'MAQUINA_AGRICOLA', 'MÁQUINA AGRÍCOLA')
      ORDER BY c.nome COLLATE NOCASE, i.descricao COLLATE NOCASE
    ''', <Object?>[_empresaUuid]);

    final alertas = <AlertaManutencao>[];
    final hoje = DateTime.now();

    for (final veiculo in veiculos) {
      final itemUuid = veiculo['item_uuid'] as String;
      final kmAtual = (veiculo['km_atual'] as num?)?.toInt();
      final criadoEm = DateTime.tryParse(veiculo['item_criado_em'] as String? ?? '');
      final statuses = await _manutencaoRepository.listarStatusDoVeiculo(itemUuid);

      for (final status in statuses) {
        var situacao = status.situacao(kmAtual: kmAtual, hoje: hoje);

        // Para a visão global evitamos transformar todo veículo recém-cadastrado
        // em dezenas de alertas apenas porque ainda não existe histórico.
        if (status.ultimaExecucao == null && situacao == 'VERIFICAR') {
          final intervaloKm = status.manutencao.intervaloKm;
          final intervaloMeses = status.manutencao.intervaloMeses;
          final atingiuKm = intervaloKm != null && kmAtual != null && kmAtual >= intervaloKm;
          final atingiuTempo = intervaloKm == null &&
              intervaloMeses != null &&
              criadoEm != null &&
              !_adicionarMeses(criadoEm, intervaloMeses).isAfter(hoje);
          if (!atingiuKm && !atingiuTempo) continue;
          situacao = 'VERIFICAR';
        }

        if (!const <String>{'VENCIDA', 'PROXIMA', 'VERIFICAR'}.contains(situacao)) {
          continue;
        }

        alertas.add(AlertaManutencao(
          clienteUuid: veiculo['cliente_uuid'] as String,
          clienteNome: veiculo['cliente_nome'] as String,
          clienteTelefone: veiculo['cliente_telefone'] as String?,
          itemUuid: itemUuid,
          itemDescricao: veiculo['item_descricao'] as String,
          marca: veiculo['marca'] as String?,
          modelo: veiculo['modelo'] as String?,
          placa: veiculo['placa'] as String?,
          status: status,
          kmAtual: kmAtual,
          situacao: situacao,
        ));
      }
    }

    alertas.sort((a, b) {
      final prioridade = <String, int>{'VENCIDA': 0, 'PROXIMA': 1, 'VERIFICAR': 2};
      final p = (prioridade[a.situacao] ?? 9).compareTo(prioridade[b.situacao] ?? 9);
      if (p != 0) return p;
      final c = a.clienteNome.compareTo(b.clienteNome);
      if (c != 0) return c;
      return a.manutencaoDescricao.compareTo(b.manutencaoDescricao);
    });
    return alertas;
  }



  static DateTime _adicionarMeses(DateTime data, int meses) {
    return DateTime(data.year, data.month + meses, data.day);
  }
}

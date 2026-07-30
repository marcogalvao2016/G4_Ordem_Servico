class OrdemServico {
  const OrdemServico({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.numeroOs,
    required this.clienteUuid,
    required this.itemUuid,
    this.servicoUuid,
    required this.status,
    required this.descricaoProblema,
    this.diagnostico,
    this.solucao,
    required this.valorTotal,
    required this.dataAbertura,
    this.dataConclusao,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final int numeroOs;
  final String clienteUuid;
  final String itemUuid;
  final String? servicoUuid;
  final String status;
  final String descricaoProblema;
  final String? diagnostico;
  final String? solucao;
  final double valorTotal;
  final DateTime dataAbertura;
  final DateTime? dataConclusao;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'numero_os': numeroOs,
        'cliente_uuid': clienteUuid,
        'item_uuid': itemUuid,
        'servico_uuid': servicoUuid,
        'status': status,
        'descricao_problema': descricaoProblema,
        'diagnostico': diagnostico,
        'solucao': solucao,
        'valor_total': valorTotal,
        'data_abertura': dataAbertura.toIso8601String(),
        'data_conclusao': dataConclusao?.toIso8601String(),
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory OrdemServico.fromMap(Map<String, Object?> map) {
    final conclusao = map['data_conclusao'] as String?;
    return OrdemServico(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      empresaUuid: map['empresa_uuid'] as String,
      numeroOs: map['numero_os'] as int,
      clienteUuid: map['cliente_uuid'] as String,
      itemUuid: map['item_uuid'] as String,
      servicoUuid: map['servico_uuid'] as String?,
      status: map['status'] as String,
      descricaoProblema: map['descricao_problema'] as String,
      diagnostico: map['diagnostico'] as String?,
      solucao: map['solucao'] as String?,
      valorTotal: (map['valor_total'] as num? ?? 0).toDouble(),
      dataAbertura: DateTime.parse(map['data_abertura'] as String),
      dataConclusao:
          conclusao == null || conclusao.isEmpty ? null : DateTime.parse(conclusao),
      criadoEm: DateTime.parse(map['criado_em'] as String),
      atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
      sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
      excluido: (map['excluido'] as int? ?? 0) == 1,
    );
  }
}

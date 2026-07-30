class OrdemServicoItem {
  const OrdemServicoItem({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.ordemUuid,
    required this.servicoUuid,
    required this.descricao,
    this.quantidade = 1,
    required this.valorUnitario,
    this.desconto = 0,
    this.observacao,
    this.ordem = 0,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String ordemUuid;
  final String servicoUuid;
  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double desconto;
  final String? observacao;
  final int ordem;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  double get valorTotal {
    final total = quantidade * valorUnitario - desconto;
    return total < 0 ? 0 : total;
  }

  OrdemServicoItem copyWith({
    int? id,
    String? uuid,
    String? empresaUuid,
    String? ordemUuid,
    String? servicoUuid,
    String? descricao,
    double? quantidade,
    double? valorUnitario,
    double? desconto,
    String? observacao,
    int? ordem,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    bool? sincronizado,
    bool? excluido,
  }) {
    return OrdemServicoItem(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      empresaUuid: empresaUuid ?? this.empresaUuid,
      ordemUuid: ordemUuid ?? this.ordemUuid,
      servicoUuid: servicoUuid ?? this.servicoUuid,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      desconto: desconto ?? this.desconto,
      observacao: observacao ?? this.observacao,
      ordem: ordem ?? this.ordem,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      sincronizado: sincronizado ?? this.sincronizado,
      excluido: excluido ?? this.excluido,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'ordem_uuid': ordemUuid,
        'servico_uuid': servicoUuid,
        'descricao': descricao,
        'quantidade': quantidade,
        'valor_unitario': valorUnitario,
        'desconto': desconto,
        'valor_total': valorTotal,
        'observacao': observacao,
        'ordem': ordem,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory OrdemServicoItem.fromMap(Map<String, Object?> map) {
    return OrdemServicoItem(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      empresaUuid: map['empresa_uuid'] as String,
      ordemUuid: map['ordem_uuid'] as String,
      servicoUuid: map['servico_uuid'] as String,
      descricao: map['descricao'] as String,
      quantidade: (map['quantidade'] as num? ?? 1).toDouble(),
      valorUnitario: (map['valor_unitario'] as num? ?? 0).toDouble(),
      desconto: (map['desconto'] as num? ?? 0).toDouble(),
      observacao: map['observacao'] as String?,
      ordem: map['ordem'] as int? ?? 0,
      criadoEm: DateTime.parse(map['criado_em'] as String),
      atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
      sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
      excluido: (map['excluido'] as int? ?? 0) == 1,
    );
  }
}

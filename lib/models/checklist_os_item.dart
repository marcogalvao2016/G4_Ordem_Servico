class ChecklistOsItem {
  const ChecklistOsItem({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.ordemUuid,
    required this.descricao,
    this.concluido = false,
    this.observacao,
    required this.ordem,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String ordemUuid;
  final String descricao;
  final bool concluido;
  final String? observacao;
  final int ordem;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  ChecklistOsItem copyWith({
    String? empresaUuid,
    String? ordemUuid,
    String? descricao,
    bool? concluido,
    String? observacao,
    int? ordem,
    DateTime? atualizadoEm,
    bool? sincronizado,
  }) {
    return ChecklistOsItem(
      id: id,
      uuid: uuid,
      empresaUuid: empresaUuid ?? this.empresaUuid,
      ordemUuid: ordemUuid ?? this.ordemUuid,
      descricao: descricao ?? this.descricao,
      concluido: concluido ?? this.concluido,
      observacao: observacao ?? this.observacao,
      ordem: ordem ?? this.ordem,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      sincronizado: sincronizado ?? this.sincronizado,
      excluido: excluido,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'ordem_uuid': ordemUuid,
        'descricao': descricao,
        'concluido': concluido ? 1 : 0,
        'observacao': observacao,
        'ordem': ordem,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory ChecklistOsItem.fromMap(Map<String, Object?> map) {
    return ChecklistOsItem(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      empresaUuid: map['empresa_uuid'] as String,
      ordemUuid: map['ordem_uuid'] as String,
      descricao: map['descricao'] as String,
      concluido: (map['concluido'] as int? ?? 0) == 1,
      observacao: map['observacao'] as String?,
      ordem: map['ordem'] as int? ?? 0,
      criadoEm: DateTime.parse(map['criado_em'] as String),
      atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
      sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
      excluido: (map['excluido'] as int? ?? 0) == 1,
    );
  }
}

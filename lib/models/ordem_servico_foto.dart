class OrdemServicoFoto {
  const OrdemServicoFoto({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.ordemUuid,
    required this.caminhoArquivo,
    this.descricao,
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
  final String caminhoArquivo;
  final String? descricao;
  final int ordem;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  OrdemServicoFoto copyWith({
    int? id, String? uuid, String? empresaUuid, String? ordemUuid,
    String? caminhoArquivo, String? descricao, bool limparDescricao = false,
    int? ordem, DateTime? criadoEm, DateTime? atualizadoEm,
    bool? sincronizado, bool? excluido,
  }) => OrdemServicoFoto(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    empresaUuid: empresaUuid ?? this.empresaUuid,
    ordemUuid: ordemUuid ?? this.ordemUuid,
    caminhoArquivo: caminhoArquivo ?? this.caminhoArquivo,
    descricao: limparDescricao ? null : (descricao ?? this.descricao),
    ordem: ordem ?? this.ordem,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    sincronizado: sincronizado ?? this.sincronizado,
    excluido: excluido ?? this.excluido,
  );

  factory OrdemServicoFoto.fromMap(Map<String, Object?> map) => OrdemServicoFoto(
    id: map['id'] as int?,
    uuid: map['uuid'] as String,
    empresaUuid: map['empresa_uuid'] as String,
    ordemUuid: map['ordem_uuid'] as String,
    caminhoArquivo: map['caminho_arquivo'] as String,
    descricao: map['descricao'] as String?,
    ordem: (map['ordem'] as num?)?.toInt() ?? 0,
    criadoEm: DateTime.parse(map['criado_em'] as String),
    atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
    sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
    excluido: (map['excluido'] as int? ?? 0) == 1,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id, 'uuid': uuid, 'empresa_uuid': empresaUuid,
    'ordem_uuid': ordemUuid, 'caminho_arquivo': caminhoArquivo,
    'descricao': descricao, 'ordem': ordem,
    'criado_em': criadoEm.toIso8601String(),
    'atualizado_em': atualizadoEm.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0, 'excluido': excluido ? 1 : 0,
  };
}

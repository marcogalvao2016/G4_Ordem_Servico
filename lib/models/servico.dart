class Servico {
  const Servico({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.descricao,
    required this.valorPadrao,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String descricao;
  final double valorPadrao;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'descricao': descricao,
        'valor_padrao': valorPadrao,
        'observacoes': observacoes,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory Servico.fromMap(Map<String, Object?> map) => Servico(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        descricao: map['descricao'] as String,
        valorPadrao: (map['valor_padrao'] as num? ?? 0).toDouble(),
        observacoes: map['observacoes'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

class Produto {
  const Produto({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.codigo,
    required this.descricao,
    required this.unidade,
    required this.valorVenda,
    this.ncm,
    this.csosn,
    this.cfop,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final int codigo;
  final String descricao;
  final String unidade;
  final double valorVenda;
  final String? ncm;
  final String? csosn;
  final String? cfop;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'codigo': codigo,
        'descricao': descricao,
        'unidade': unidade,
        'valor_venda': valorVenda,
        'ncm': ncm,
        'csosn': csosn,
        'cfop': cfop,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory Produto.fromMap(Map<String, Object?> map) => Produto(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        codigo: map['codigo'] as int,
        descricao: map['descricao'] as String,
        unidade: map['unidade'] as String,
        valorVenda: (map['valor_venda'] as num? ?? 0).toDouble(),
        ncm: map['ncm'] as String?,
        csosn: map['csosn'] as String?,
        cfop: map['cfop'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

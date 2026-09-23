class OrdemServicoProduto {
  const OrdemServicoProduto({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.ordemUuid,
    required this.produtoUuid,
    required this.codigoProduto,
    required this.descricao,
    required this.unidade,
    this.ncm,
    this.csosn,
    this.cfop,
    this.quantidade = 1,
    required this.valorUnitario,
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
  final String produtoUuid;
  final int codigoProduto;
  final String descricao;
  final String unidade;
  final String? ncm;
  final String? csosn;
  final String? cfop;
  final double quantidade;
  final double valorUnitario;
  final int ordem;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  double get valorTotal => quantidade * valorUnitario;

  OrdemServicoProduto copyWith({
    int? id,
    String? uuid,
    String? empresaUuid,
    String? ordemUuid,
    String? produtoUuid,
    int? codigoProduto,
    String? descricao,
    String? unidade,
    String? ncm,
    String? csosn,
    String? cfop,
    double? quantidade,
    double? valorUnitario,
    int? ordem,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    bool? sincronizado,
    bool? excluido,
  }) {
    return OrdemServicoProduto(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      empresaUuid: empresaUuid ?? this.empresaUuid,
      ordemUuid: ordemUuid ?? this.ordemUuid,
      produtoUuid: produtoUuid ?? this.produtoUuid,
      codigoProduto: codigoProduto ?? this.codigoProduto,
      descricao: descricao ?? this.descricao,
      unidade: unidade ?? this.unidade,
      ncm: ncm ?? this.ncm,
      csosn: csosn ?? this.csosn,
      cfop: cfop ?? this.cfop,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
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
        'produto_uuid': produtoUuid,
        'codigo_produto': codigoProduto,
        'descricao': descricao,
        'unidade': unidade,
        'ncm': ncm,
        'csosn': csosn,
        'cfop': cfop,
        'quantidade': quantidade,
        'valor_unitario': valorUnitario,
        'valor_total': valorTotal,
        'ordem': ordem,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory OrdemServicoProduto.fromMap(Map<String, Object?> map) =>
      OrdemServicoProduto(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        ordemUuid: map['ordem_uuid'] as String,
        produtoUuid: map['produto_uuid'] as String,
        codigoProduto: map['codigo_produto'] as int,
        descricao: map['descricao'] as String,
        unidade: map['unidade'] as String,
        ncm: map['ncm'] as String?,
        csosn: map['csosn'] as String?,
        cfop: map['cfop'] as String?,
        quantidade: (map['quantidade'] as num? ?? 1).toDouble(),
        valorUnitario: (map['valor_unitario'] as num? ?? 0).toDouble(),
        ordem: map['ordem'] as int? ?? 0,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

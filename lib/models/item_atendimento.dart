class ItemAtendimento {
  const ItemAtendimento({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.clienteUuid,
    required this.tipo,
    required this.descricao,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.placa,
    this.ano,
    this.cor,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String clienteUuid;
  final String tipo;
  final String descricao;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String? placa;
  final String? ano;
  final String? cor;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'cliente_uuid': clienteUuid,
        'tipo': tipo,
        'descricao': descricao,
        'marca': marca,
        'modelo': modelo,
        'numero_serie': numeroSerie,
        'placa': placa,
        'ano': ano,
        'cor': cor,
        'observacoes': observacoes,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory ItemAtendimento.fromMap(Map<String, Object?> map) =>
      ItemAtendimento(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        clienteUuid: map['cliente_uuid'] as String,
        tipo: map['tipo'] as String,
        descricao: map['descricao'] as String,
        marca: map['marca'] as String?,
        modelo: map['modelo'] as String?,
        numeroSerie: map['numero_serie'] as String?,
        placa: map['placa'] as String?,
        ano: map['ano'] as String?,
        cor: map['cor'] as String?,
        observacoes: map['observacoes'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

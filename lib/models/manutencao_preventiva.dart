class ManutencaoPreventiva {
  const ManutencaoPreventiva({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.descricao,
    required this.categoria,
    this.intervaloKm,
    this.intervaloMeses,
    this.observacoes,
    this.ativo = true,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String descricao;
  final String categoria;
  final int? intervaloKm;
  final int? intervaloMeses;
  final String? observacoes;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  ManutencaoPreventiva copyWith({
    int? id,
    String? uuid,
    String? empresaUuid,
    String? descricao,
    String? categoria,
    int? intervaloKm,
    bool limparIntervaloKm = false,
    int? intervaloMeses,
    bool limparIntervaloMeses = false,
    String? observacoes,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    bool? sincronizado,
    bool? excluido,
  }) {
    return ManutencaoPreventiva(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      empresaUuid: empresaUuid ?? this.empresaUuid,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      intervaloKm: limparIntervaloKm ? null : (intervaloKm ?? this.intervaloKm),
      intervaloMeses: limparIntervaloMeses
          ? null
          : (intervaloMeses ?? this.intervaloMeses),
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
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
        'descricao': descricao,
        'categoria': categoria,
        'intervalo_km': intervaloKm,
        'intervalo_meses': intervaloMeses,
        'observacoes': observacoes,
        'ativo': ativo ? 1 : 0,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory ManutencaoPreventiva.fromMap(Map<String, Object?> map) =>
      ManutencaoPreventiva(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        descricao: map['descricao'] as String,
        categoria: map['categoria'] as String? ?? 'GERAL',
        intervaloKm: map['intervalo_km'] as int?,
        intervaloMeses: map['intervalo_meses'] as int?,
        observacoes: map['observacoes'] as String?,
        ativo: (map['ativo'] as int? ?? 1) == 1,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

class ManutencaoExecucao {
  const ManutencaoExecucao({
    required this.manutencaoUuid,
    required this.dataExecucao,
    this.quilometragem,
    this.ordemUuid,
  });

  final String manutencaoUuid;
  final DateTime dataExecucao;
  final int? quilometragem;
  final String? ordemUuid;
}

class ManutencaoVeiculoStatus {
  const ManutencaoVeiculoStatus({
    required this.manutencao,
    this.ultimaExecucao,
  });

  final ManutencaoPreventiva manutencao;
  final ManutencaoExecucao? ultimaExecucao;

  int? proximaKm() {
    final intervalo = manutencao.intervaloKm;
    final ultima = ultimaExecucao?.quilometragem;
    if (intervalo == null || ultima == null) return null;
    return ultima + intervalo;
  }

  DateTime? proximaData() {
    final meses = manutencao.intervaloMeses;
    final ultima = ultimaExecucao?.dataExecucao;
    if (meses == null || ultima == null) return null;
    return DateTime(ultima.year, ultima.month + meses, ultima.day);
  }

  String situacao({int? kmAtual, DateTime? hoje}) {
    final dataHoje = hoje ?? DateTime.now();
    final execucao = ultimaExecucao;
    if (execucao == null) {
      final intervalo = manutencao.intervaloKm;
      if (intervalo != null && kmAtual != null && kmAtual >= intervalo) {
        return 'VERIFICAR';
      }
      if (manutencao.intervaloMeses != null) return 'VERIFICAR';
      return 'SEM_HISTORICO';
    }

    final proximaKmValor = proximaKm();
    final proximaDataValor = proximaData();
    final vencidaKm = proximaKmValor != null &&
        kmAtual != null &&
        kmAtual >= proximaKmValor;
    final vencidaData = proximaDataValor != null &&
        !dataHoje.isBefore(proximaDataValor);
    if (vencidaKm || vencidaData) return 'VENCIDA';

    bool proxima = false;
    final intervaloKm = manutencao.intervaloKm;
    if (proximaKmValor != null && kmAtual != null && intervaloKm != null) {
      final restante = proximaKmValor - kmAtual;
      final margem = (intervaloKm * 0.15).round().clamp(500, 2000);
      if (restante <= margem) proxima = true;
    }
    if (proximaDataValor != null) {
      final dias = proximaDataValor.difference(dataHoje).inDays;
      if (dias <= 30) proxima = true;
    }
    return proxima ? 'PROXIMA' : 'EM_DIA';
  }
}

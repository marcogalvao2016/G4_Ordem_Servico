class ConfiguracoesGerais {
  const ConfiguracoesGerais({
    required this.empresaUuid,
    this.usarManutencaoPreventiva = true,
    this.usarStatus = true,
    this.usarDiagnostico = true,
    this.usarSolucaoAplicada = true,
    this.usarFotosOs = true,
    this.usarFichaVistoria = true,
    this.usarChecklist = true,
  });

  final String empresaUuid;
  final bool usarManutencaoPreventiva;
  final bool usarStatus;
  final bool usarDiagnostico;
  final bool usarSolucaoAplicada;
  final bool usarFotosOs;
  final bool usarFichaVistoria;
  final bool usarChecklist;

  ConfiguracoesGerais copyWith({
    bool? usarManutencaoPreventiva,
    bool? usarStatus,
    bool? usarDiagnostico,
    bool? usarSolucaoAplicada,
    bool? usarFotosOs,
    bool? usarFichaVistoria,
    bool? usarChecklist,
  }) => ConfiguracoesGerais(
        empresaUuid: empresaUuid,
        usarManutencaoPreventiva: usarManutencaoPreventiva ?? this.usarManutencaoPreventiva,
        usarStatus: usarStatus ?? this.usarStatus,
        usarDiagnostico: usarDiagnostico ?? this.usarDiagnostico,
        usarSolucaoAplicada: usarSolucaoAplicada ?? this.usarSolucaoAplicada,
        usarFotosOs: usarFotosOs ?? this.usarFotosOs,
        usarFichaVistoria: usarFichaVistoria ?? this.usarFichaVistoria,
        usarChecklist: usarChecklist ?? this.usarChecklist,
      );

  Map<String, Object?> toMap() => <String, Object?>{
        'empresa_uuid': empresaUuid,
        'usar_manutencao_preventiva': usarManutencaoPreventiva ? 1 : 0,
        'usar_status': usarStatus ? 1 : 0,
        'usar_diagnostico': usarDiagnostico ? 1 : 0,
        'usar_solucao_aplicada': usarSolucaoAplicada ? 1 : 0,
        'usar_fotos_os': usarFotosOs ? 1 : 0,
        'usar_ficha_vistoria': usarFichaVistoria ? 1 : 0,
        'usar_checklist': usarChecklist ? 1 : 0,
      };

  factory ConfiguracoesGerais.fromMap(Map<String, Object?> map) => ConfiguracoesGerais(
        empresaUuid: map['empresa_uuid'] as String,
        usarManutencaoPreventiva: (map['usar_manutencao_preventiva'] as int? ?? 1) == 1,
        usarStatus: (map['usar_status'] as int? ?? 1) == 1,
        usarDiagnostico: (map['usar_diagnostico'] as int? ?? 1) == 1,
        usarSolucaoAplicada: (map['usar_solucao_aplicada'] as int? ?? 1) == 1,
        usarFotosOs: (map['usar_fotos_os'] as int? ?? 1) == 1,
        usarFichaVistoria: (map['usar_ficha_vistoria'] as int? ?? 1) == 1,
        usarChecklist: (map['usar_checklist'] as int? ?? 1) == 1,
      );
}

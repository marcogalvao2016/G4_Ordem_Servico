import 'dart:convert';

class VistoriaVeiculo {
  const VistoriaVeiculo({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.ordemUuid,
    this.nomeMotorista = '',
    this.local = '',
    this.destino = '',
    this.km = '',
    this.tiposAtendimento = const <String>[],
    this.motivos = const <String>[],
    this.outroMotivo = '',
    this.danos = const <Map<String, String>>[],
    this.pneus = const <String, String>{},
    this.combustivel = 50,
    this.acessorios = const <String, String>{},
    this.proprietarioOrientado = false,
    this.patioCiente = false,
    this.observacoes = '',
    this.seguradoNome = '',
    this.seguradoRg = '',
    this.seguradoAssinatura = '',
    this.destinatarioNome = '',
    this.destinatarioRg = '',
    this.destinatarioAssinatura = '',
    this.prestadorNome = '',
    this.prestadorRg = '',
    this.prestadorAssinatura = '',
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String ordemUuid;
  final String nomeMotorista;
  final String local;
  final String destino;
  final String km;
  final List<String> tiposAtendimento;
  final List<String> motivos;
  final String outroMotivo;
  final List<Map<String, String>> danos;
  final Map<String, String> pneus;
  final int combustivel;
  final Map<String, String> acessorios;
  final bool proprietarioOrientado;
  final bool patioCiente;
  final String observacoes;
  final String seguradoNome;
  final String seguradoRg;
  final String seguradoAssinatura;
  final String destinatarioNome;
  final String destinatarioRg;
  final String destinatarioAssinatura;
  final String prestadorNome;
  final String prestadorRg;
  final String prestadorAssinatura;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;

  VistoriaVeiculo copyWith({
    String? empresaUuid,
    String? ordemUuid,
    String? nomeMotorista,
    String? local,
    String? destino,
    String? km,
    List<String>? tiposAtendimento,
    List<String>? motivos,
    String? outroMotivo,
    List<Map<String, String>>? danos,
    Map<String, String>? pneus,
    int? combustivel,
    Map<String, String>? acessorios,
    bool? proprietarioOrientado,
    bool? patioCiente,
    String? observacoes,
    String? seguradoNome,
    String? seguradoRg,
    String? seguradoAssinatura,
    String? destinatarioNome,
    String? destinatarioRg,
    String? destinatarioAssinatura,
    String? prestadorNome,
    String? prestadorRg,
    String? prestadorAssinatura,
    DateTime? atualizadoEm,
    bool? sincronizado,
  }) => VistoriaVeiculo(
    id: id,
    uuid: uuid,
    empresaUuid: empresaUuid ?? this.empresaUuid,
    ordemUuid: ordemUuid ?? this.ordemUuid,
    nomeMotorista: nomeMotorista ?? this.nomeMotorista,
    local: local ?? this.local,
    destino: destino ?? this.destino,
    km: km ?? this.km,
    tiposAtendimento: tiposAtendimento ?? this.tiposAtendimento,
    motivos: motivos ?? this.motivos,
    outroMotivo: outroMotivo ?? this.outroMotivo,
    danos: danos ?? this.danos,
    pneus: pneus ?? this.pneus,
    combustivel: combustivel ?? this.combustivel,
    acessorios: acessorios ?? this.acessorios,
    proprietarioOrientado: proprietarioOrientado ?? this.proprietarioOrientado,
    patioCiente: patioCiente ?? this.patioCiente,
    observacoes: observacoes ?? this.observacoes,
    seguradoNome: seguradoNome ?? this.seguradoNome,
    seguradoRg: seguradoRg ?? this.seguradoRg,
    seguradoAssinatura: seguradoAssinatura ?? this.seguradoAssinatura,
    destinatarioNome: destinatarioNome ?? this.destinatarioNome,
    destinatarioRg: destinatarioRg ?? this.destinatarioRg,
    destinatarioAssinatura: destinatarioAssinatura ?? this.destinatarioAssinatura,
    prestadorNome: prestadorNome ?? this.prestadorNome,
    prestadorRg: prestadorRg ?? this.prestadorRg,
    prestadorAssinatura: prestadorAssinatura ?? this.prestadorAssinatura,
    criadoEm: criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    sincronizado: sincronizado ?? this.sincronizado,
  );

  Map<String,Object?> toMap()=>{
    'id':id,'uuid':uuid,'empresa_uuid':empresaUuid,'ordem_uuid':ordemUuid,
    'nome_motorista':nomeMotorista,'local':local,'destino':destino,'km':km,
    'tipos_atendimento_json':jsonEncode(tiposAtendimento),
    'motivos_json':jsonEncode(motivos),'outro_motivo':outroMotivo,
    'danos_json':jsonEncode(danos),'pneus_json':jsonEncode(pneus),
    'combustivel':combustivel,'acessorios_json':jsonEncode(acessorios),
    'proprietario_orientado':proprietarioOrientado?1:0,'patio_ciente':patioCiente?1:0,
    'observacoes':observacoes,'segurado_nome':seguradoNome,'segurado_rg':seguradoRg,
    'segurado_assinatura':seguradoAssinatura,'destinatario_nome':destinatarioNome,
    'destinatario_rg':destinatarioRg,'destinatario_assinatura':destinatarioAssinatura,
    'prestador_nome':prestadorNome,'prestador_rg':prestadorRg,
    'prestador_assinatura':prestadorAssinatura,'criado_em':criadoEm.toIso8601String(),
    'atualizado_em':atualizadoEm.toIso8601String(),'sincronizado':sincronizado?1:0,
  };

  factory VistoriaVeiculo.fromMap(Map<String,Object?> m){
    List<String> list(String k)=>List<String>.from(jsonDecode((m[k]??'[]') as String));
    Map<String,String> map(String k)=>Map<String,String>.from(jsonDecode((m[k]??'{}') as String));
    final rawDanos=List<dynamic>.from(jsonDecode((m['danos_json']??'[]') as String));
    return VistoriaVeiculo(
      id:m['id'] as int?,uuid:m['uuid'] as String,empresaUuid:m['empresa_uuid'] as String,
      ordemUuid:m['ordem_uuid'] as String,nomeMotorista:(m['nome_motorista']??'') as String,
      local:(m['local']??'') as String,destino:(m['destino']??'') as String,km:(m['km']??'') as String,
      tiposAtendimento:list('tipos_atendimento_json'),motivos:list('motivos_json'),
      outroMotivo:(m['outro_motivo']??'') as String,
      danos:rawDanos.map((e)=>Map<String,String>.from(e as Map)).toList(),
      pneus:map('pneus_json'),combustivel:(m['combustivel'] as int?)??50,
      acessorios:map('acessorios_json'),proprietarioOrientado:(m['proprietario_orientado'] as int? ?? 0)==1,
      patioCiente:(m['patio_ciente'] as int? ?? 0)==1,observacoes:(m['observacoes']??'') as String,
      seguradoNome:(m['segurado_nome']??'') as String,seguradoRg:(m['segurado_rg']??'') as String,
      seguradoAssinatura:(m['segurado_assinatura']??'') as String,
      destinatarioNome:(m['destinatario_nome']??'') as String,destinatarioRg:(m['destinatario_rg']??'') as String,
      destinatarioAssinatura:(m['destinatario_assinatura']??'') as String,
      prestadorNome:(m['prestador_nome']??'') as String,prestadorRg:(m['prestador_rg']??'') as String,
      prestadorAssinatura:(m['prestador_assinatura']??'') as String,
      criadoEm:DateTime.parse(m['criado_em'] as String),atualizadoEm:DateTime.parse(m['atualizado_em'] as String),
      sincronizado:(m['sincronizado'] as int? ?? 0)==1,
    );
  }
}

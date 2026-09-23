class Empresa {
  const Empresa({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.nome,
    this.cnpj,
    this.inscricaoEstadual,
    this.celular,
    this.email,
    this.endereco,
    this.bairro,
    this.cep,
    this.cidade,
    this.uf,
    this.logoPath,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String nome;
  final String? cnpj;
  final String? inscricaoEstadual;
  final String? celular;
  final String? email;
  final String? endereco;
  final String? bairro;
  final String? cep;
  final String? cidade;
  final String? uf;
  final String? logoPath;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'nome': nome,
        'cnpj': cnpj,
        'inscricao_estadual': inscricaoEstadual,
        'celular': celular,
        'email': email,
        'endereco': endereco,
        'bairro': bairro,
        'cep': cep,
        'cidade': cidade,
        'uf': uf,
        'logo_path': logoPath,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
      };

  factory Empresa.fromMap(Map<String, Object?> map) => Empresa(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        nome: map['nome'] as String,
        cnpj: map['cnpj'] as String?,
        inscricaoEstadual: map['inscricao_estadual'] as String?,
        celular: map['celular'] as String?,
        email: map['email'] as String?,
        endereco: map['endereco'] as String?,
        bairro: map['bairro'] as String?,
        cep: map['cep'] as String?,
        cidade: map['cidade'] as String?,
        uf: map['uf'] as String?,
        logoPath: map['logo_path'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
      );
}

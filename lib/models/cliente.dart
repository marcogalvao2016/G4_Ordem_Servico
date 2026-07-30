class Cliente {
  const Cliente({
    this.id,
    required this.uuid,
    required this.empresaUuid,
    required this.nome,
    this.tipoPessoa = 'F',
    this.cpfCnpj,
    this.telefone,
    this.email,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
    this.sincronizado = false,
    this.excluido = false,
  });

  final int? id;
  final String uuid;
  final String empresaUuid;
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool sincronizado;
  final bool excluido;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'uuid': uuid,
        'empresa_uuid': empresaUuid,
        'nome': nome,
        'tipo_pessoa': tipoPessoa,
        'cpf_cnpj': cpfCnpj,
        'telefone': telefone,
        'email': email,
        'cep': cep,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'observacoes': observacoes,
        'criado_em': criadoEm.toIso8601String(),
        'atualizado_em': atualizadoEm.toIso8601String(),
        'sincronizado': sincronizado ? 1 : 0,
        'excluido': excluido ? 1 : 0,
      };

  factory Cliente.fromMap(Map<String, Object?> map) => Cliente(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        empresaUuid: map['empresa_uuid'] as String,
        nome: map['nome'] as String,
        tipoPessoa: map['tipo_pessoa'] as String? ?? 'F',
        cpfCnpj: map['cpf_cnpj'] as String?,
        telefone: map['telefone'] as String?,
        email: map['email'] as String?,
        cep: map['cep'] as String?,
        logradouro: map['logradouro'] as String?,
        numero: map['numero'] as String?,
        complemento: map['complemento'] as String?,
        bairro: map['bairro'] as String?,
        cidade: map['cidade'] as String?,
        uf: map['uf'] as String?,
        observacoes: map['observacoes'] as String?,
        criadoEm: DateTime.parse(map['criado_em'] as String),
        atualizadoEm: DateTime.parse(map['atualizado_em'] as String),
        sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
        excluido: (map['excluido'] as int? ?? 0) == 1,
      );
}

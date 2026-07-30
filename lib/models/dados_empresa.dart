class DadosEmpresa {
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String inscricaoEstadual;
  final String situacaoCadastral;
  final String telefone;
  final String email;
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  const DadosEmpresa({
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.inscricaoEstadual,
    required this.situacaoCadastral,
    required this.telefone,
    required this.email,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory DadosEmpresa.fromJson(Map<String, dynamic> json) {
    final estabelecimento =
        (json['estabelecimento'] as Map<String, dynamic>?) ?? const {};
    final estado =
        (estabelecimento['estado'] as Map<String, dynamic>?) ?? const {};
    final cidade =
        (estabelecimento['cidade'] as Map<String, dynamic>?) ?? const {};
    final uf = estado['sigla']?.toString() ?? '';

    String inscricaoEstadual = '';
    final inscricoes = estabelecimento['inscricoes_estaduais'];
    if (inscricoes is List) {
      final candidatas = inscricoes.whereType<Map<String, dynamic>>().toList();

      Map<String, dynamic>? selecionada;
      for (final inscricao in candidatas) {
        final ieEstado = inscricao['estado'] as Map<String, dynamic>?;
        final mesmaUf = ieEstado?['sigla']?.toString() == uf;
        final ativa = inscricao['ativo'] == true;
        if (mesmaUf && ativa) {
          selecionada = inscricao;
          break;
        }
      }

      selecionada ??= candidatas.cast<Map<String, dynamic>?>().firstWhere(
            (inscricao) => inscricao?['ativo'] == true,
            orElse: () => null,
          );
      selecionada ??= candidatas.isNotEmpty ? candidatas.first : null;
      inscricaoEstadual =
          selecionada?['inscricao_estadual']?.toString() ?? '';
    }

    final ddd = estabelecimento['ddd1']?.toString() ?? '';
    final telefone = estabelecimento['telefone1']?.toString() ?? '';

    return DadosEmpresa(
      cnpj: estabelecimento['cnpj']?.toString() ?? '',
      razaoSocial: json['razao_social']?.toString() ?? '',
      nomeFantasia: estabelecimento['nome_fantasia']?.toString() ?? '',
      inscricaoEstadual: inscricaoEstadual,
      situacaoCadastral:
          estabelecimento['situacao_cadastral']?.toString() ?? '',
      telefone: ddd.isEmpty ? telefone : '($ddd) $telefone',
      email: estabelecimento['email']?.toString() ?? '',
      cep: estabelecimento['cep']?.toString() ?? '',
      logradouro: [
        estabelecimento['tipo_logradouro']?.toString() ?? '',
        estabelecimento['logradouro']?.toString() ?? '',
      ].where((parte) => parte.trim().isNotEmpty).join(' '),
      numero: estabelecimento['numero']?.toString() ?? '',
      complemento: estabelecimento['complemento']?.toString() ?? '',
      bairro: estabelecimento['bairro']?.toString() ?? '',
      cidade: cidade['nome']?.toString() ?? '',
      uf: uf,
    );
  }
}

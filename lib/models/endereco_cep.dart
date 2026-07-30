class EnderecoCep {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final String codigoIbge;

  const EnderecoCep({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.codigoIbge,
  });

  factory EnderecoCep.fromJson(Map<String, dynamic> json) {
    return EnderecoCep(
      cep: json['cep']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
      complemento: json['complemento']?.toString() ?? '',
      bairro: json['bairro']?.toString() ?? '',
      cidade: json['localidade']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
      codigoIbge: json['ibge']?.toString() ?? '',
    );
  }
}

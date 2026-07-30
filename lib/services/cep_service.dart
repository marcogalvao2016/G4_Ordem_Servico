import 'dart:convert';

import 'package:http/http.dart' as http;

class CepException implements Exception {
  const CepException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CepResult {
  const CepResult({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;
}

class CepService {
  static const Duration _timeout = Duration(seconds: 12);

  Future<CepResult> consultar(String cepInformado) async {
    final cep = cepInformado.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      throw const CepException('Informe um CEP com 8 dígitos.');
    }

    final uri = Uri.https('viacep.com.br', '/ws/$cep/json/');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CepException(
          'O ViaCEP retornou o código ${response.statusCode}.',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const CepException('Resposta inválida recebida do ViaCEP.');
      }

      if (data['erro'] == true) {
        throw const CepException('CEP não encontrado.');
      }

      return CepResult(
        cep: (data['cep'] ?? '').toString(),
        logradouro: (data['logradouro'] ?? '').toString(),
        complemento: (data['complemento'] ?? '').toString(),
        bairro: (data['bairro'] ?? '').toString(),
        cidade: (data['localidade'] ?? '').toString(),
        uf: (data['uf'] ?? '').toString(),
      );
    } on CepException {
      rethrow;
    } on http.ClientException {
      throw const CepException(
        'Não foi possível acessar o ViaCEP. Verifique a internet.',
      );
    } on FormatException {
      throw const CepException('O ViaCEP retornou uma resposta inválida.');
    } catch (error) {
      throw CepException('Falha ao consultar o CEP: $error');
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class CnpjException implements Exception {
  const CnpjException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CnpjResult {
  const CnpjResult({
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
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

  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String telefone;
  final String email;
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;
}

class CnpjService {
  static const Duration _timeout = Duration(seconds: 15);

  Future<CnpjResult> consultar(String cnpjInformado) async {
    final cnpj = cnpjInformado.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpj.length != 14) {
      throw const CnpjException('Informe um CNPJ com 14 dígitos.');
    }

    final uri = Uri.https(
      'brasilapi.com.br',
      '/api/cnpj/v1/$cnpj',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 404) {
        throw const CnpjException('CNPJ não encontrado.');
      }

      if (response.statusCode != 200) {
        throw CnpjException(
          'A consulta de CNPJ retornou o código ${response.statusCode}.',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const CnpjException(
          'Resposta inválida recebida na consulta de CNPJ.',
        );
      }

      return CnpjResult(
        cnpj: (data['cnpj'] ?? cnpj).toString(),
        razaoSocial: (data['razao_social'] ?? '').toString(),
        nomeFantasia: (data['nome_fantasia'] ?? '').toString(),
        telefone: _montarTelefone(data),
        email: (data['email'] ?? '').toString(),
        cep: (data['cep'] ?? '').toString(),
        logradouro: _montarLogradouro(data),
        numero: (data['numero'] ?? '').toString(),
        complemento: (data['complemento'] ?? '').toString(),
        bairro: (data['bairro'] ?? '').toString(),
        cidade: (data['municipio'] ?? '').toString(),
        uf: (data['uf'] ?? '').toString(),
      );
    } on CnpjException {
      rethrow;
    } on http.ClientException {
      throw const CnpjException(
        'Não foi possível consultar o CNPJ. Verifique a internet.',
      );
    } on FormatException {
      throw const CnpjException(
        'A consulta de CNPJ retornou uma resposta inválida.',
      );
    } catch (error) {
      throw CnpjException('Falha ao consultar o CNPJ: $error');
    }
  }

  String _montarLogradouro(Map<String, dynamic> data) {
    final descricao = (data['descricao_tipo_de_logradouro'] ?? '')
        .toString()
        .trim();
    final logradouro = (data['logradouro'] ?? '').toString().trim();

    if (descricao.isEmpty) {
      return logradouro;
    }

    if (logradouro.toUpperCase().startsWith(descricao.toUpperCase())) {
      return logradouro;
    }

    return '$descricao $logradouro'.trim();
  }

  String _montarTelefone(Map<String, dynamic> data) {
    final ddd1 = (data['ddd_telefone_1'] ?? '').toString().trim();
    final telefone1 = (data['telefone_1'] ?? '').toString().trim();

    if (telefone1.isEmpty) {
      return '';
    }

    if (ddd1.isEmpty) {
      return telefone1;
    }

    return '($ddd1) $telefone1';
  }
}

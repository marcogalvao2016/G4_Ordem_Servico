// Testes unitários básicos do G4 OS.
//
// Não dependem de SQLite, SharedPreferences nem rede, portanto rodam
// com `flutter test` em qualquer máquina de desenvolvimento.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:g4_os/core/utils/formatters.dart';
import 'package:g4_os/core/utils/uppercase_text_formatter.dart';

void main() {
  group('formatCurrency', () {
    test('formata valor com vírgula decimal', () {
      expect(formatCurrency(10), 'R\$ 10,00');
      expect(formatCurrency(1234.5), 'R\$ 1234,50');
      expect(formatCurrency(0), 'R\$ 0,00');
    });
  });

  group('parseCurrency', () {
    test('converte texto monetário para double', () {
      expect(parseCurrency('R\$ 10,00'), 10.0);
      expect(parseCurrency('1.234,56'), 1234.56);
      expect(parseCurrency('0,99'), 0.99);
    });

    test('retorna zero para texto inválido', () {
      expect(parseCurrency(''), 0);
      expect(parseCurrency('abc'), 0);
    });

    test('é inverso de formatCurrency', () {
      const valor = 987.65;
      expect(parseCurrency(formatCurrency(valor)), valor);
    });
  });

  group('UpperCaseTextFormatter', () {
    test('converte para maiúsculas preservando o cursor', () {
      const formatter = UpperCaseTextFormatter();
      const antigo = TextEditingValue(text: 'joã');
      const novo = TextEditingValue(
        text: 'joão silva',
        selection: TextSelection.collapsed(offset: 10),
      );

      final resultado = formatter.formatEditUpdate(antigo, novo);

      expect(resultado.text, 'JOÃO SILVA');
      expect(resultado.selection.baseOffset, 10);
    });
  });
}

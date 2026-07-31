import 'package:flutter/services.dart';

/// Mantém campos cadastrais em letras maiúsculas sem alterar a posição do cursor.
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

const upperCaseTextFormatter = UpperCaseTextFormatter();

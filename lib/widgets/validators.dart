String? validarObrigatorio(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo é obrigatório.';
  }
  return null;
}

import 'package:flutter/material.dart';

import '../../models/servico.dart';
import '../../widgets/cadastro_base_page.dart';
import '../../widgets/validators.dart';

class CadastroServicoPage extends StatefulWidget {
  const CadastroServicoPage({super.key});

  @override
  State<CadastroServicoPage> createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _valor = TextEditingController();
  final _observacao = TextEditingController();

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    _observacao.dispose();
    super.dispose();
  }

  double? _converterValor(String texto) {
    var valor = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (valor.contains(',') && valor.contains('.')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    } else {
      valor = valor.replaceAll(',', '.');
    }
    return double.tryParse(valor);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Servico(
        descricao: _descricao.text.trim(),
        valor: _converterValor(_valor.text)!,
        observacao: _observacao.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBasePage(
      titulo: 'Novo serviço',
      onSalvar: _salvar,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _descricao,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Descrição do serviço',
                prefixIcon: Icon(Icons.build_outlined),
                hintText: 'Ex.: Troca de óleo',
              ),
              validator: validarObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.attach_money_outlined),
                hintText: '0,00',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor do serviço.';
                }
                final convertido = _converterValor(value);
                if (convertido == null || convertido < 0) {
                  return 'Informe um valor válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacao,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

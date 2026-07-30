import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/dados_empresa.dart';
import '../../models/endereco_cep.dart';
import '../../services/api_exception.dart';
import '../../services/cep_service.dart';
import '../../services/cnpj_service.dart';
import '../../widgets/cadastro_base_page.dart';
import '../../widgets/validators.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _nomeFantasia = TextEditingController();
  final _cpfCnpj = TextEditingController();
  final _inscricaoEstadual = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _cep = TextEditingController();
  final _endereco = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _uf = TextEditingController();

  final _cnpjService = CnpjService();
  final _cepService = CepService();

  bool _consultandoCnpj = false;
  bool _consultandoCep = false;
  String _situacaoCadastral = '';

  @override
  void dispose() {
    _nome.dispose();
    _nomeFantasia.dispose();
    _cpfCnpj.dispose();
    _inscricaoEstadual.dispose();
    _telefone.dispose();
    _email.dispose();
    _cep.dispose();
    _endereco.dispose();
    _numero.dispose();
    _complemento.dispose();
    _bairro.dispose();
    _cidade.dispose();
    _uf.dispose();
    super.dispose();
  }

  String _somenteNumeros(String valor) => valor.replaceAll(RegExp(r'\D'), '');

  bool get _documentoEhCnpj => _somenteNumeros(_cpfCnpj.text).length == 14;

  Future<void> _consultarCnpj() async {
    FocusScope.of(context).unfocus();
    if (!_documentoEhCnpj) {
      _mostrarMensagem('Digite um CNPJ com 14 dígitos para consultar.', erro: true);
      return;
    }

    setState(() => _consultandoCnpj = true);
    try {
      final empresa = await _cnpjService.consultar(_cpfCnpj.text);
      if (!mounted) return;
      _preencherEmpresa(empresa);
      _mostrarMensagem('Dados da empresa preenchidos automaticamente.');
    } on ApiException catch (e) {
      if (mounted) _mostrarMensagem(e.message, erro: true);
    } finally {
      if (mounted) setState(() => _consultandoCnpj = false);
    }
  }

  void _preencherEmpresa(DadosEmpresa empresa) {
    setState(() {
      _cpfCnpj.text = empresa.cnpj;
      _nome.text = empresa.razaoSocial;
      _nomeFantasia.text = empresa.nomeFantasia;
      _inscricaoEstadual.text = empresa.inscricaoEstadual;
      _telefone.text = empresa.telefone;
      _email.text = empresa.email;
      _cep.text = empresa.cep;
      _endereco.text = empresa.logradouro;
      _numero.text = empresa.numero;
      _complemento.text = empresa.complemento;
      _bairro.text = empresa.bairro;
      _cidade.text = empresa.cidade;
      _uf.text = empresa.uf;
      _situacaoCadastral = empresa.situacaoCadastral;
    });
  }

  Future<void> _consultarCep() async {
    FocusScope.of(context).unfocus();
    if (_somenteNumeros(_cep.text).length != 8) {
      _mostrarMensagem('Digite um CEP com 8 dígitos para consultar.', erro: true);
      return;
    }

    setState(() => _consultandoCep = true);
    try {
      final endereco = await _cepService.consultar(_cep.text);
      if (!mounted) return;
      _preencherEndereco(endereco);
      _mostrarMensagem('Endereço preenchido automaticamente.');
    } on ApiException catch (e) {
      if (mounted) _mostrarMensagem(e.message, erro: true);
    } finally {
      if (mounted) setState(() => _consultandoCep = false);
    }
  }

  void _preencherEndereco(EnderecoCep endereco) {
    setState(() {
      _cep.text = endereco.cep;
      _endereco.text = endereco.logradouro;
      if (_complemento.text.trim().isEmpty) {
        _complemento.text = endereco.complemento;
      }
      _bairro.text = endereco.bairro;
      _cidade.text = endereco.cidade;
      _uf.text = endereco.uf;
    });
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: erro ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Cliente(
        nome: _nome.text.trim(),
        nomeFantasia: _nomeFantasia.text.trim(),
        cpfCnpj: _cpfCnpj.text.trim(),
        inscricaoEstadual: _inscricaoEstadual.text.trim(),
        telefone: _telefone.text.trim(),
        email: _email.text.trim(),
        cep: _cep.text.trim(),
        endereco: _endereco.text.trim(),
        numero: _numero.text.trim(),
        complemento: _complemento.text.trim(),
        bairro: _bairro.text.trim(),
        cidade: _cidade.text.trim(),
        uf: _uf.text.trim().toUpperCase(),
      ),
    );
  }

  InputDecoration _decoracaoConsulta({
    required String label,
    required IconData icon,
    required bool carregando,
    required VoidCallback consultar,
    required String tooltip,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: carregando
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton(
              tooltip: tooltip,
              onPressed: consultar,
              icon: const Icon(Icons.search),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroBasePage(
      titulo: 'Novo cliente',
      onSalvar: _salvar,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Identificação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cpfCnpj,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) {
                if (_documentoEhCnpj) _consultarCnpj();
              },
              decoration: _decoracaoConsulta(
                label: 'CPF ou CNPJ',
                icon: Icons.badge_outlined,
                carregando: _consultandoCnpj,
                consultar: _consultarCnpj,
                tooltip: 'Consultar CNPJ',
                hintText: 'Para CNPJ, toque na lupa',
              ),
              validator: validarObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome ou razão social',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: validarObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeFantasia,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome fantasia',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inscricaoEstadual,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Inscrição Estadual',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
            ),
            if (_situacaoCadastral.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Situação cadastral: $_situacaoCadastral'),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Contato',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: validarObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Endereço',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cep,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _consultarCep(),
              decoration: _decoracaoConsulta(
                label: 'CEP',
                icon: Icons.location_on_outlined,
                carregando: _consultandoCep,
                consultar: _consultarCep,
                tooltip: 'Consultar CEP',
                hintText: 'Digite o CEP e toque na lupa',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endereco,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _numero,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _complemento,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bairro,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                prefixIcon: Icon(Icons.holiday_village_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cidade,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: validarObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _uf,
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'UF',
                prefixIcon: Icon(Icons.map_outlined),
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().length != 2
                  ? 'Informe a UF com duas letras.'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

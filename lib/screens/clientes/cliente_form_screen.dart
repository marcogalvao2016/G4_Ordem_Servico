import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../models/cliente.dart';
import '../../repositories/cliente_repository.dart';
import '../../services/cep_service.dart';
import '../../services/cnpj_service.dart';

class ClienteFormScreen extends StatefulWidget {
  const ClienteFormScreen({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ClienteRepository();
  final _cepService = CepService();
  final _cnpjService = CnpjService();

  late final TextEditingController _nome;
  late final TextEditingController _cpfCnpj;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _cep;
  late final TextEditingController _logradouro;
  late final TextEditingController _numero;
  late final TextEditingController _complemento;
  late final TextEditingController _bairro;
  late final TextEditingController _cidade;
  late final TextEditingController _uf;
  late final TextEditingController _observacoes;

  final _numeroFocus = FocusNode();

  String _tipoPessoa = 'F';
  bool _salvando = false;
  bool _consultandoCep = false;
  bool _consultandoCnpj = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;

    _tipoPessoa = c?.tipoPessoa ?? 'F';
    _nome = TextEditingController(text: c?.nome);
    _cpfCnpj = TextEditingController(text: c?.cpfCnpj);
    _telefone = TextEditingController(text: c?.telefone);
    _email = TextEditingController(text: c?.email);
    _cep = TextEditingController(text: c?.cep);
    _logradouro = TextEditingController(text: c?.logradouro);
    _numero = TextEditingController(text: c?.numero);
    _complemento = TextEditingController(text: c?.complemento);
    _bairro = TextEditingController(text: c?.bairro);
    _cidade = TextEditingController(text: c?.cidade);
    _uf = TextEditingController(text: c?.uf);
    _observacoes = TextEditingController(text: c?.observacoes);
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _nome,
      _cpfCnpj,
      _telefone,
      _email,
      _cep,
      _logradouro,
      _numero,
      _complemento,
      _bairro,
      _cidade,
      _uf,
      _observacoes,
    ]) {
      controller.dispose();
    }

    _numeroFocus.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _consultarCep() async {
    if (_consultandoCep) return;

    FocusScope.of(context).unfocus();
    setState(() => _consultandoCep = true);

    try {
      final endereco = await _cepService.consultar(_cep.text);

      _cep.text = endereco.cep;
      _logradouro.text = endereco.logradouro;
      _bairro.text = endereco.bairro;
      _cidade.text = endereco.cidade;
      _uf.text = endereco.uf.toUpperCase();

      if (_complemento.text.trim().isEmpty &&
          endereco.complemento.trim().isNotEmpty) {
        _complemento.text = endereco.complemento;
      }

      _mostrarMensagem('CEP localizado.');
      _numeroFocus.requestFocus();
    } on CepException catch (error) {
      _mostrarMensagem(error.message);
    } catch (error) {
      _mostrarMensagem('Não foi possível consultar o CEP: $error');
    } finally {
      if (mounted) {
        setState(() => _consultandoCep = false);
      }
    }
  }

  Future<void> _consultarCnpj() async {
    if (_consultandoCnpj) return;

    if (_tipoPessoa != 'J') {
      _mostrarMensagem('Selecione Pessoa jurídica para consultar CNPJ.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _consultandoCnpj = true);

    try {
      final empresa = await _cnpjService.consultar(_cpfCnpj.text);

      _cpfCnpj.text = empresa.cnpj;

      if (empresa.razaoSocial.trim().isNotEmpty) {
        _nome.text = empresa.razaoSocial;
      }

      if (empresa.telefone.trim().isNotEmpty) {
        _telefone.text = empresa.telefone;
      }

      if (empresa.email.trim().isNotEmpty) {
        _email.text = empresa.email;
      }

      _cep.text = empresa.cep;
      _logradouro.text = empresa.logradouro;
      _numero.text = empresa.numero;
      _complemento.text = empresa.complemento;
      _bairro.text = empresa.bairro;
      _cidade.text = empresa.cidade;
      _uf.text = empresa.uf.toUpperCase();

      final fantasia = empresa.nomeFantasia.trim();
      final mensagem = fantasia.isEmpty
          ? 'Dados do CNPJ preenchidos.'
          : 'Dados do CNPJ preenchidos. Fantasia: $fantasia';

      _mostrarMensagem(mensagem);
    } on CnpjException catch (error) {
      _mostrarMensagem(error.message);
    } catch (error) {
      _mostrarMensagem('Não foi possível consultar o CNPJ: $error');
    } finally {
      if (mounted) {
        setState(() => _consultandoCnpj = false);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      final now = DateTime.now();
      final original = widget.cliente;

      final cliente = Cliente(
        id: original?.id,
        uuid: original?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        nome: _nome.text.trim(),
        tipoPessoa: _tipoPessoa,
        cpfCnpj: _cpfCnpj.text.trim(),
        telefone: _telefone.text.trim(),
        email: _email.text.trim(),
        cep: _cep.text.trim(),
        logradouro: _logradouro.text.trim(),
        numero: _numero.text.trim(),
        complemento: _complemento.text.trim(),
        bairro: _bairro.text.trim(),
        cidade: _cidade.text.trim(),
        uf: _uf.text.trim().toUpperCase(),
        observacoes: _observacoes.text.trim(),
        criadoEm: original?.criadoEm ?? now,
        atualizadoEm: now,
      );

      if (original == null) {
        await _repository.salvar(cliente);
      } else {
        await _repository.atualizar(cliente);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      _mostrarMensagem('Não foi possível salvar: $error');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = _salvando || _consultandoCep || _consultandoCnpj;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Novo cliente' : 'Editar cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment(value: 'F', label: Text('Pessoa física')),
                ButtonSegment(value: 'J', label: Text('Pessoa jurídica')),
              ],
              selected: <String>{_tipoPessoa},
              onSelectionChanged: bloqueado
                  ? null
                  : (value) {
                      setState(() => _tipoPessoa = value.first);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText:
                    _tipoPessoa == 'J' ? 'Razão social *' : 'Nome completo *',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Informe o nome.'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cpfCnpj,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _tipoPessoa == 'J' ? 'CNPJ' : 'CPF',
                suffixIcon: _tipoPessoa == 'J'
                    ? IconButton(
                        tooltip: 'Consultar CNPJ',
                        onPressed: bloqueado ? null : _consultarCnpj,
                        icon: _consultandoCnpj
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                      )
                    : null,
              ),
              onFieldSubmitted: (_) {
                if (_tipoPessoa == 'J') {
                  _consultarCnpj();
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefone,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cep,
              decoration: InputDecoration(
                labelText: 'CEP',
                suffixIcon: IconButton(
                  tooltip: 'Consultar CEP',
                  onPressed: bloqueado ? null : _consultarCep,
                  icon: _consultandoCep
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_searching_outlined),
                ),
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => _consultarCep(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _logradouro,
              decoration: const InputDecoration(labelText: 'Logradouro'),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _numero,
                    focusNode: _numeroFocus,
                    decoration: const InputDecoration(labelText: 'Número'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bairro,
                    decoration: const InputDecoration(labelText: 'Bairro'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _complemento,
              decoration: const InputDecoration(labelText: 'Complemento'),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cidade,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _uf,
                    maxLength: 2,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'UF',
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Observações'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: bloqueado ? null : _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(_salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

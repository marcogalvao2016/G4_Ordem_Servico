import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/uppercase_text_formatter.dart';
import '../../models/empresa.dart';
import '../../repositories/empresa_repository.dart';
import '../../services/cep_service.dart';
import '../../services/cnpj_service.dart';
import '../configuracoes/configuracoes_gerais_screen.dart';

class EmpresaFormScreen extends StatefulWidget {
  const EmpresaFormScreen({super.key});

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EmpresaRepository();
  final _cepService = CepService();
  final _cnpjService = CnpjService();
  final _imagePicker = ImagePicker();

  final _nome = TextEditingController();
  final _cnpj = TextEditingController();
  final _ie = TextEditingController();
  final _celular = TextEditingController();
  final _email = TextEditingController();
  final _endereco = TextEditingController();
  final _bairro = TextEditingController();
  final _cep = TextEditingController();
  final _cidade = TextEditingController();
  final _uf = TextEditingController();

  Empresa? _empresa;
  bool _carregando = true;
  bool _salvando = false;
  bool _consultando = false;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final empresa = await _repository.obter();
    if (!mounted) return;
    _empresa = empresa;
    if (empresa != null) {
      _nome.text = empresa.nome;
      _cnpj.text = empresa.cnpj ?? '';
      _ie.text = empresa.inscricaoEstadual ?? '';
      _celular.text = empresa.celular ?? '';
      _email.text = empresa.email ?? '';
      _endereco.text = empresa.endereco ?? '';
      _bairro.text = empresa.bairro ?? '';
      _cep.text = empresa.cep ?? '';
      _cidade.text = empresa.cidade ?? '';
      _uf.text = empresa.uf ?? '';
      _logoPath = empresa.logoPath;
    }
    setState(() => _carregando = false);
  }

  Future<void> _consultarCnpj() async {
    if (_consultando || _cnpj.text.trim().isEmpty) return;
    setState(() => _consultando = true);
    try {
      final dados = await _cnpjService.consultar(_cnpj.text);
      _cnpj.text = dados.cnpj;
      _nome.text = dados.nomeFantasia.trim().isNotEmpty
          ? dados.nomeFantasia
          : dados.razaoSocial;
      // A BrasilAPI não retorna inscrição estadual neste endpoint; mantenha o valor informado pelo usuário.
      _celular.text = dados.telefone;
      _email.text = dados.email;
      _cep.text = dados.cep;
      _endereco.text = [dados.logradouro, dados.numero, dados.complemento]
          .where((e) => e.trim().isNotEmpty)
          .join(', ');
      _bairro.text = dados.bairro;
      _cidade.text = dados.cidade;
      _uf.text = dados.uf;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível consultar o CNPJ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _consultando = false);
    }
  }

  Future<void> _consultarCep() async {
    if (_consultando || _cep.text.trim().isEmpty) return;
    setState(() => _consultando = true);
    try {
      final dados = await _cepService.consultar(_cep.text);
      _cep.text = dados.cep;
      if (_endereco.text.trim().isEmpty) _endereco.text = dados.logradouro;
      _bairro.text = dados.bairro;
      _cidade.text = dados.cidade;
      _uf.text = dados.uf;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível consultar o CEP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _consultando = false);
    }
  }


  Future<void> _selecionarLogo() async {
    if (_salvando || _consultando) return;
    final XFile? imagem = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (imagem == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final empresaUuid = SessionManager.instance.requireEmpresaUuid();
    final pasta = Directory(p.join(dir.path, 'empresa_logo', empresaUuid));
    await pasta.create(recursive: true);

    final extOriginal = p.extension(imagem.path).toLowerCase();
    final ext = extOriginal.isEmpty ? '.jpg' : extOriginal;
    if (!<String>{'.jpg', '.jpeg', '.png'}.contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um logo em formato JPG ou PNG.')),
        );
      }
      return;
    }
    final destino = p.join(pasta.path, 'logo$ext');

    for (final arquivo in pasta.listSync().whereType<File>()) {
      try {
        await arquivo.delete();
      } catch (_) {}
    }
    await File(imagem.path).copy(destino);

    if (!mounted) return;
    setState(() => _logoPath = destino);
  }

  void _removerLogo() {
    if (_salvando || _consultando) return;
    setState(() => _logoPath = null);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final now = DateTime.now();
      final original = _empresa;
      await _repository.salvar(Empresa(
        id: original?.id,
        uuid: original?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        nome: _nome.text.trim().toUpperCase(),
        cnpj: _cnpj.text.trim().toUpperCase(),
        inscricaoEstadual: _ie.text.trim().toUpperCase(),
        celular: _celular.text.trim().toUpperCase(),
        email: _email.text.trim(),
        endereco: _endereco.text.trim().toUpperCase(),
        bairro: _bairro.text.trim().toUpperCase(),
        cep: _cep.text.trim().toUpperCase(),
        cidade: _cidade.text.trim().toUpperCase(),
        uf: _uf.text.trim().toUpperCase(),
        logoPath: _logoPath,
        criadoEm: original?.criadoEm ?? now,
        atualizadoEm: now,
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar a empresa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_nome, _cnpj, _ie, _celular, _email, _endereco, _bairro, _cep, _cidade, _uf]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bloqueado = _salvando || _consultando;
    InputDecoration decor(String label, {Widget? suffix}) =>
        InputDecoration(labelText: label, suffixIcon: suffix);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro da empresa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Dados utilizados nos impressos e documentos da empresa.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Logo da empresa', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 180,
                        height: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _logoPath != null && File(_logoPath!).existsSync()
                            ? Image.file(File(_logoPath!), fit: BoxFit.contain)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.image_outlined, size: 38),
                                  SizedBox(height: 4),
                                  Text('Nenhum logo selecionado'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: bloqueado ? null : _selecionarLogo,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(_logoPath == null ? 'Selecionar logo' : 'Trocar logo'),
                        ),
                        if (_logoPath != null)
                          TextButton.icon(
                            onPressed: bloqueado ? null : _removerLogo,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remover logo'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'O logo será salvo no aparelho e utilizado no Pedido em PDF.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
              decoration: decor('Nome da empresa *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome da empresa.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cnpj,
              keyboardType: TextInputType.number,
              decoration: decor('CNPJ', suffix: IconButton(
                tooltip: 'Consultar CNPJ',
                onPressed: bloqueado ? null : _consultarCnpj,
                icon: const Icon(Icons.search),
              )),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _ie, inputFormatters: const [upperCaseTextFormatter], decoration: decor('Inscrição estadual')),
            const SizedBox(height: 12),
            TextFormField(controller: _celular, keyboardType: TextInputType.phone, decoration: decor('Contato / celular')),
            const SizedBox(height: 12),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: decor('E-mail')),
            const SizedBox(height: 12),
            TextFormField(controller: _endereco, inputFormatters: const [upperCaseTextFormatter], decoration: decor('Endereço')),
            const SizedBox(height: 12),
            TextFormField(controller: _bairro, inputFormatters: const [upperCaseTextFormatter], decoration: decor('Bairro')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cep,
              keyboardType: TextInputType.number,
              decoration: decor('CEP', suffix: IconButton(
                tooltip: 'Consultar CEP',
                onPressed: bloqueado ? null : _consultarCep,
                icon: const Icon(Icons.location_searching),
              )),
            ),
            const SizedBox(height: 12),
            Row(children: <Widget>[
              Expanded(child: TextFormField(controller: _cidade, inputFormatters: const [upperCaseTextFormatter], decoration: decor('Cidade'))),
              const SizedBox(width: 12),
              SizedBox(width: 90, child: TextFormField(controller: _uf, inputFormatters: const [upperCaseTextFormatter], maxLength: 2, decoration: decor('UF'))),
            ]),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: bloqueado
                  ? null
                  : () => Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConfiguracoesGeraisScreen(),
                        ),
                      ),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Configurações'),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: bloqueado ? null : _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(_salvando ? 'Salvando...' : 'Salvar empresa'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../models/cliente.dart';
import '../../models/item_atendimento.dart';
import '../../repositories/cliente_repository.dart';
import '../../repositories/item_repository.dart';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, this.item});

  final ItemAtendimento? item;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ItemRepository();
  final _clienteRepository = ClienteRepository();

  late final TextEditingController _descricao;
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _numeroSerie;
  late final TextEditingController _placa;
  late final TextEditingController _ano;
  late final TextEditingController _cor;
  late final TextEditingController _observacoes;

  String _tipo = 'VEICULO';
  String? _clienteUuid;
  List<Cliente> _clientes = <Cliente>[];
  bool _carregando = true;
  bool _salvando = false;

  static const tipos = <String>[
    'VEICULO',
    'MOTO',
    'CAMINHAO',
    'MAQUINA_AGRICOLA',
    'EQUIPAMENTO',
    'COMPUTADOR',
    'AR_CONDICIONADO',
    'OUTRO',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _tipo = item?.tipo ?? 'VEICULO';
    _clienteUuid = item?.clienteUuid;
    _descricao = TextEditingController(text: item?.descricao);
    _marca = TextEditingController(text: item?.marca);
    _modelo = TextEditingController(text: item?.modelo);
    _numeroSerie = TextEditingController(text: item?.numeroSerie);
    _placa = TextEditingController(text: item?.placa);
    _ano = TextEditingController(text: item?.ano);
    _cor = TextEditingController(text: item?.cor);
    _observacoes = TextEditingController(text: item?.observacoes);
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _clienteRepository.listar();
    if (!mounted) return;
    setState(() {
      _clientes = clientes;
      if (_clienteUuid == null && clientes.isNotEmpty) {
        _clienteUuid = clientes.first.uuid;
      }
      _carregando = false;
    });
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _descricao,
      _marca,
      _modelo,
      _numeroSerie,
      _placa,
      _ano,
      _cor,
      _observacoes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final now = DateTime.now();
      final original = widget.item;
      final item = ItemAtendimento(
        id: original?.id,
        uuid: original?.uuid ?? const Uuid().v4(),
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        clienteUuid: _clienteUuid!,
        tipo: _tipo,
        descricao: _descricao.text.trim(),
        marca: _marca.text.trim(),
        modelo: _modelo.text.trim(),
        numeroSerie: _numeroSerie.text.trim(),
        placa: _placa.text.trim().toUpperCase(),
        ano: _ano.text.trim(),
        cor: _cor.text.trim(),
        observacoes: _observacoes.text.trim(),
        criadoEm: original?.criadoEm ?? now,
        atualizadoEm: now,
      );

      if (original == null) {
        await _repository.salvar(item);
      } else {
        await _repository.atualizar(item);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Novo item' : 'Editar item'),
      ),
      body: _clientes.isEmpty
          ? const Center(
              child: Text('Cadastre ao menos um cliente antes de criar um item.'),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: _clienteUuid,
                    decoration: const InputDecoration(labelText: 'Cliente *'),
                    items: _clientes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.uuid,
                            child: Text(c.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _clienteUuid = value),
                    validator: (value) =>
                        value == null ? 'Selecione o cliente.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    decoration: const InputDecoration(labelText: 'Tipo *'),
                    items: tipos
                        .map(
                          (tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _tipo = value!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descricao,
                    decoration: const InputDecoration(labelText: 'Descrição *'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a descrição.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _marca,
                    decoration: const InputDecoration(labelText: 'Marca'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _modelo,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _numeroSerie,
                    decoration:
                        const InputDecoration(labelText: 'Número de série / Chassi'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _placa,
                          decoration: const InputDecoration(labelText: 'Placa'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _ano,
                          decoration: const InputDecoration(labelText: 'Ano'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cor,
                    decoration: const InputDecoration(labelText: 'Cor'),
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
                    onPressed: _salvando ? null : _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
    );
  }
}

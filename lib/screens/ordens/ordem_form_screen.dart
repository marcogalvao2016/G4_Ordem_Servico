import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/formatters.dart';
import '../../models/checklist_os_item.dart';
import '../../models/cliente.dart';
import '../../models/item_atendimento.dart';
import '../../models/ordem_servico.dart';
import '../../models/servico.dart';
import '../../models/vistoria_veiculo.dart';
import '../../repositories/checklist_os_repository.dart';
import '../../repositories/cliente_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/ordem_servico_repository.dart';
import '../../repositories/servico_repository.dart';
import '../../repositories/vistoria_veiculo_repository.dart';
import 'vistoria_veiculo_screen.dart';

class OrdemFormScreen extends StatefulWidget {
  const OrdemFormScreen({super.key, this.ordem});

  final OrdemServico? ordem;

  @override
  State<OrdemFormScreen> createState() => _OrdemFormScreenState();
}

class _OrdemFormScreenState extends State<OrdemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = OrdemServicoRepository();
  final _checklistRepository = ChecklistOsRepository();
  final _clienteRepository = ClienteRepository();
  final _itemRepository = ItemRepository();
  final _servicoRepository = ServicoRepository();
  final _vistoriaRepository = VistoriaVeiculoRepository();

  final _problema = TextEditingController();
  final _diagnostico = TextEditingController();
  final _solucao = TextEditingController();
  final _valor = TextEditingController();

  late final String _ordemUuid;

  List<Cliente> _clientes = <Cliente>[];
  List<ItemAtendimento> _itens = <ItemAtendimento>[];
  List<Servico> _servicos = <Servico>[];
  List<ChecklistOsItem> _checklist = <ChecklistOsItem>[];
  VistoriaVeiculo? _vistoria;

  String? _clienteUuid;
  String? _itemUuid;
  String? _servicoUuid;
  String _status = 'ABERTA';
  int _numeroOs = 0;
  bool _carregando = true;
  bool _salvando = false;

  static const statuses = <String>[
    'ABERTA',
    'EM_ANALISE',
    'AGUARDANDO_APROVACAO',
    'EM_EXECUCAO',
    'CONCLUIDA',
    'CANCELADA',
  ];

  @override
  void initState() {
    super.initState();

    final o = widget.ordem;
    _ordemUuid = o?.uuid ?? const Uuid().v4();
    _problema.text = o?.descricaoProblema ?? '';
    _diagnostico.text = o?.diagnostico ?? '';
    _solucao.text = o?.solucao ?? '';
    _valor.text =
        o == null ? '' : o.valorTotal.toStringAsFixed(2).replaceAll('.', ',');
    _clienteUuid = o?.clienteUuid;
    _itemUuid = o?.itemUuid;
    _servicoUuid = o?.servicoUuid;
    _status = o?.status ?? 'ABERTA';
    _numeroOs = o?.numeroOs ?? 0;

    _carregar();
  }

  Future<void> _carregar() async {
    final clientes = await _clienteRepository.listar();
    final servicos = await _servicoRepository.listar();
    final checklist = widget.ordem == null
        ? <ChecklistOsItem>[]
        : await _checklistRepository.listarPorOrdem(_ordemUuid);
    final vistoriaExistente = widget.ordem == null
        ? null
        : await _vistoriaRepository.buscarPorOrdem(_ordemUuid);
    final agora = DateTime.now();
    final vistoria = vistoriaExistente ?? VistoriaVeiculo(
      uuid: const Uuid().v4(),
      empresaUuid: SessionManager.instance.requireEmpresaUuid(),
      ordemUuid: _ordemUuid,
      criadoEm: agora,
      atualizadoEm: agora,
    );

    if (_clienteUuid == null && clientes.isNotEmpty) {
      _clienteUuid = clientes.first.uuid;
    }

    final itens = _clienteUuid == null
        ? <ItemAtendimento>[]
        : await _itemRepository.listarPorCliente(_clienteUuid!);

    if (_itemUuid == null && itens.isNotEmpty) {
      _itemUuid = itens.first.uuid;
    }

    if (_numeroOs == 0) {
      _numeroOs = await _repository.proximoNumero();
    }

    if (!mounted) return;

    setState(() {
      _clientes = clientes;
      _servicos = servicos;
      _itens = itens;
      _checklist = checklist;
      _vistoria = vistoria;
      _carregando = false;
    });
  }

  Future<void> _trocarCliente(String? clienteUuid) async {
    setState(() {
      _clienteUuid = clienteUuid;
      _itemUuid = null;
    });

    if (clienteUuid == null) return;

    final itens = await _itemRepository.listarPorCliente(clienteUuid);

    if (!mounted) return;

    setState(() {
      _itens = itens;
      if (itens.isNotEmpty) {
        _itemUuid = itens.first.uuid;
      }
    });
  }

  void _trocarServico(String? servicoUuid) {
    setState(() {
      _servicoUuid = servicoUuid;
      final selecionados =
          _servicos.where((servico) => servico.uuid == servicoUuid).toList();

      if (selecionados.isNotEmpty) {
        _valor.text = selecionados.first.valorPadrao
            .toStringAsFixed(2)
            .replaceAll('.', ',');
      }
    });
  }

  Future<void> _adicionarChecklist() async {
    final descricao = TextEditingController();
    final observacao = TextEditingController();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar ao checklist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: descricao,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Ex.: Testar funcionamento',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observacao,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (descricao.text.trim().isEmpty) return;
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    final descricaoInformada = descricao.text.trim();
    final observacaoInformada = observacao.text.trim();

    await WidgetsBinding.instance.endOfFrame;
    descricao.dispose();
    observacao.dispose();

    if (!mounted) return;

    if (confirmou == true) {
      final agora = DateTime.now();

      setState(() {
        _checklist.add(
          ChecklistOsItem(
            uuid: const Uuid().v4(),
            empresaUuid: SessionManager.instance.requireEmpresaUuid(),
            ordemUuid: _ordemUuid,
            descricao: descricaoInformada,
            observacao: observacaoInformada,
            ordem: _checklist.length,
            criadoEm: agora,
            atualizadoEm: agora,
          ),
        );
      });
    }
  }

  Future<void> _editarObservacao(int index) async {
    final controller = TextEditingController(
      text: _checklist[index].observacao ?? '',
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_checklist[index].descricao),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Observação',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    final observacaoInformada = controller.text.trim();

    await WidgetsBinding.instance.endOfFrame;
    controller.dispose();

    if (!mounted) return;

    if (confirmou == true && index < _checklist.length) {
      setState(() {
        _checklist[index] = _checklist[index].copyWith(
          observacao: observacaoInformada,
          atualizadoEm: DateTime.now(),
          sincronizado: false,
        );
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final agora = DateTime.now();
      final original = widget.ordem;
      final concluida = _status == 'CONCLUIDA';

      final ordem = OrdemServico(
        id: original?.id,
        uuid: _ordemUuid,
        empresaUuid: SessionManager.instance.requireEmpresaUuid(),
        numeroOs: _numeroOs,
        clienteUuid: _clienteUuid!,
        itemUuid: _itemUuid!,
        servicoUuid: _servicoUuid,
        status: _status,
        descricaoProblema: _problema.text.trim(),
        diagnostico: _diagnostico.text.trim(),
        solucao: _solucao.text.trim(),
        valorTotal: parseCurrency(_valor.text),
        dataAbertura: original?.dataAbertura ?? agora,
        dataConclusao:
            concluida ? (original?.dataConclusao ?? agora) : null,
        criadoEm: original?.criadoEm ?? agora,
        atualizadoEm: agora,
      );

      if (original == null) {
        await _repository.salvar(ordem);
      } else {
        await _repository.atualizar(ordem);
      }

      await _checklistRepository.substituirDaOrdem(
        _ordemUuid,
        _checklist,
      );
      if (_vistoria != null) {
        await _vistoriaRepository.salvar(_vistoria!);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  void dispose() {
    _problema.dispose();
    _diagnostico.dispose();
    _solucao.dispose();
    _valor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final podeCadastrar = _clientes.isNotEmpty && _itens.isNotEmpty;
    final concluidos =
        _checklist.where((item) => item.concluido).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ordem == null ? 'Nova OS' : 'Editar OS'),
      ),
      body: !podeCadastrar
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Para abrir uma OS, cadastre um cliente e ao menos um item '
                  'vinculado a ele.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    'Número da OS: $_numeroOs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _clienteUuid,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                    ),
                    items: _clientes
                        .map(
                          (cliente) => DropdownMenuItem<String>(
                            value: cliente.uuid,
                            child: Text(cliente.nome),
                          ),
                        )
                        .toList(),
                    onChanged: _trocarCliente,
                    validator: (value) =>
                        value == null ? 'Selecione o cliente.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _itemUuid,
                    decoration: const InputDecoration(
                      labelText: 'Item *',
                    ),
                    items: _itens
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.uuid,
                            child: Text(item.descricao),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _itemUuid = value);
                    },
                    validator: (value) =>
                        value == null ? 'Selecione o item.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _servicoUuid,
                    decoration: const InputDecoration(
                      labelText: 'Serviço',
                    ),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Sem serviço definido'),
                      ),
                      ..._servicos.map(
                        (servico) => DropdownMenuItem<String?>(
                          value: servico.uuid,
                          child: Text(servico.descricao),
                        ),
                      ),
                    ],
                    onChanged: _trocarServico,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                    ),
                    items: statuses
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _problema,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Problema relatado *',
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe o problema relatado.'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diagnostico,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Diagnóstico',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _solucao,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Solução aplicada',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _valor,
                    decoration: const InputDecoration(
                      labelText: 'Valor total',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Ficha de vistoria do veículo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_vistoria != null)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.fact_check_outlined),
                        ),
                        title: const Text('Abrir ficha de vistoria'),
                        subtitle: Text(
                          _vistoria!.atualizadoEm == _vistoria!.criadoEm
                              ? 'Ainda não preenchida'
                              : 'Vistoria iniciada • toque para continuar',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final itensSelecionados = _itens
                              .where((e) => e.uuid == _itemUuid)
                              .toList();
                          final resultado = await Navigator.push<VistoriaVeiculo>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VistoriaVeiculoScreen(
                                numeroOs: _numeroOs,
                                initial: _vistoria!,
                                item: itensSelecionados.isEmpty
                                    ? null
                                    : itensSelecionados.first,
                              ),
                            ),
                          );
                          if (!mounted || resultado == null) return;
                          setState(() => _vistoria = resultado);
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Checklist ($concluidos/${_checklist.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            _salvando ? null : _adicionarChecklist,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  if (_checklist.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nenhum item no checklist. Toque em Adicionar.',
                        ),
                      ),
                    ),
                  ...List<Widget>.generate(
                    _checklist.length,
                    (index) {
                      final item = _checklist[index];

                      return Card(
                        child: Column(
                          children: <Widget>[
                            CheckboxListTile(
                              value: item.concluido,
                              title: Text(
                                item.descricao,
                                style: TextStyle(
                                  decoration: item.concluido
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle:
                                  (item.observacao ?? '').trim().isEmpty
                                      ? null
                                      : Text(item.observacao!),
                              onChanged: (value) {
                                setState(() {
                                  _checklist[index] = item.copyWith(
                                    concluido: value ?? false,
                                    atualizadoEm: DateTime.now(),
                                    sincronizado: false,
                                  );
                                });
                              },
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                            ),
                            ButtonBar(
                              children: <Widget>[
                                TextButton.icon(
                                  onPressed: () =>
                                      _editarObservacao(index),
                                  icon: const Icon(Icons.notes_outlined),
                                  label: const Text('Observação'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _checklist.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remover'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

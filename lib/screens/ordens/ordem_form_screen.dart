import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/uppercase_text_formatter.dart';
import 'package:uuid/uuid.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/formatters.dart';
import '../../models/checklist_os_item.dart';
import '../../models/cliente.dart';
import '../../models/configuracoes_gerais.dart';
import '../../models/empresa.dart';
import '../../models/item_atendimento.dart';
import '../../models/ordem_servico.dart';
import '../../models/ordem_servico_item.dart';
import '../../models/ordem_servico_produto.dart';
import '../../models/ordem_servico_foto.dart';
import '../../models/produto.dart';
import '../../models/servico.dart';
import '../../models/vistoria_veiculo.dart';
import '../../repositories/checklist_os_repository.dart';
import '../../repositories/cliente_repository.dart';
import '../../repositories/configuracoes_gerais_repository.dart';
import '../../repositories/empresa_repository.dart';
import '../../repositories/item_repository.dart';
import '../../repositories/manutencao_preventiva_repository.dart';
import '../../repositories/ordem_servico_repository.dart';
import '../../repositories/ordem_servico_item_repository.dart';
import '../../repositories/ordem_servico_produto_repository.dart';
import '../../repositories/ordem_servico_foto_repository.dart';
import '../../repositories/produto_repository.dart';
import '../../repositories/servico_repository.dart';
import '../../repositories/vistoria_veiculo_repository.dart';
import '../../services/ordem_servico_pdf_service.dart';
import '../../services/pedido_pdf_service.dart';
import '../../services/relatorio_fotografico_pdf_service.dart';
import '../../services/vistoria_veiculo_pdf_service.dart';
import 'vistoria_veiculo_screen.dart';
import 'os_fotos_screen.dart';
import '../manutencoes/plano_manutencao_veiculo_screen.dart';

class OrdemFormScreen extends StatefulWidget {
  const OrdemFormScreen({super.key, this.ordem});

  final OrdemServico? ordem;

  @override
  State<OrdemFormScreen> createState() => _OrdemFormScreenState();
}

class _OrdemFormScreenState extends State<OrdemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = OrdemServicoRepository();
  final _ordemItemRepository = OrdemServicoItemRepository();
  final _ordemProdutoRepository = OrdemServicoProdutoRepository();
  final _ordemFotoRepository = OrdemServicoFotoRepository();
  final _checklistRepository = ChecklistOsRepository();
  final _clienteRepository = ClienteRepository();
  final _configuracoesRepository = ConfiguracoesGeraisRepository();
  final _empresaRepository = EmpresaRepository();
  final _itemRepository = ItemRepository();
  final _manutencaoRepository = ManutencaoPreventivaRepository();
  final _servicoRepository = ServicoRepository();
  final _produtoRepository = ProdutoRepository();
  final _vistoriaRepository = VistoriaVeiculoRepository();
  final _pdfService = const OrdemServicoPdfService();
  final _pedidoPdfService = const PedidoPdfService();
  final _relatorioFotograficoPdfService = const RelatorioFotograficoPdfService();
  final _vistoriaPdfService = const VistoriaVeiculoPdfService();

  final _problema = TextEditingController();
  final _diagnostico = TextEditingController();
  final _solucao = TextEditingController();
  final _valor = TextEditingController();
  final _kmAtual = TextEditingController();

  late final String _ordemUuid;

  List<Cliente> _clientes = <Cliente>[];
  List<ItemAtendimento> _itens = <ItemAtendimento>[];
  List<Servico> _servicos = <Servico>[];
  List<OrdemServicoItem> _servicosDaOrdem = <OrdemServicoItem>[];
  List<Produto> _produtos = <Produto>[];
  List<OrdemServicoProduto> _produtosDaOrdem = <OrdemServicoProduto>[];
  List<OrdemServicoFoto> _fotosDaOrdem = <OrdemServicoFoto>[];
  List<ChecklistOsItem> _checklist = <ChecklistOsItem>[];
  VistoriaVeiculo? _vistoria;
  ConfiguracoesGerais? _configuracoes;
  Set<String> _manutencoesExecutadas = <String>{};

  String? _clienteUuid;
  String? _itemUuid;
  String _status = 'ABERTA';
  int _numeroOs = 0;
  bool _carregando = true;
  bool _salvando = false;
  bool _gerandoPdf = false;

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
    _kmAtual.text = o?.kmAtual?.toString() ?? '';
    _clienteUuid = o?.clienteUuid;
    _itemUuid = o?.itemUuid;
    _status = o?.status ?? 'ABERTA';
    _numeroOs = o?.numeroOs ?? 0;

    _carregar();
  }

  Future<void> _carregar() async {
    final configuracoes = await _configuracoesRepository.obter();
    final clientes = await _clienteRepository.listar();
    final servicos = await _servicoRepository.listar();
    final produtos = await _produtoRepository.listar();
    final servicosDaOrdem = widget.ordem == null
        ? <OrdemServicoItem>[]
        : await _ordemItemRepository.listarPorOrdem(_ordemUuid);
    final produtosDaOrdem = widget.ordem == null
        ? <OrdemServicoProduto>[]
        : await _ordemProdutoRepository.listarPorOrdem(_ordemUuid);
    final fotosDaOrdem = widget.ordem == null
        ? <OrdemServicoFoto>[]
        : await _ordemFotoRepository.listarPorOrdem(_ordemUuid);
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

    await _manutencaoRepository.garantirPadroes();
    final manutencoesExecutadas = widget.ordem == null
        ? <String>{}
        : await _manutencaoRepository.listarIdsDaOrdem(_ordemUuid);

    if (!mounted) return;

    setState(() {
      _configuracoes = configuracoes;
      if (!configuracoes.usarStatus) {
        _status = 'CONCLUIDA';
      }
      _clientes = clientes;
      _servicos = servicos;
      _servicosDaOrdem = servicosDaOrdem;
      _produtos = produtos;
      _produtosDaOrdem = produtosDaOrdem;
      _fotosDaOrdem = fotosDaOrdem;
      _atualizarValorTotal();
      _itens = itens;
      _checklist = checklist;
      _vistoria = vistoria;
      _manutencoesExecutadas = manutencoesExecutadas;
      _carregando = false;
    });
  }

  Future<void> _trocarCliente(String? clienteUuid) async {
    setState(() {
      _clienteUuid = clienteUuid;
      _itemUuid = null;
      _manutencoesExecutadas = <String>{};
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

  bool get _itemSelecionadoEhVeiculo {
    final itemUuid = _itemUuid;
    if (itemUuid == null) return false;
    final encontrados = _itens.where((e) => e.uuid == itemUuid).toList();
    if (encontrados.isEmpty) return false;
    return const <String>{'VEICULO', 'MOTO', 'CAMINHAO', 'MAQUINA_AGRICOLA'}
        .contains(encontrados.first.tipo);
  }

  double get _totalServicos => _servicosDaOrdem.fold<double>(
        0,
        (soma, item) => soma + item.valorTotal,
      );

  double get _totalProdutos => _produtosDaOrdem.fold<double>(
        0,
        (soma, item) => soma + item.valorTotal,
      );

  void _atualizarValorTotal() {
    final total = _totalServicos + _totalProdutos;
    _valor.text = total.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _adicionarServico() async {
    if (_servicos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um serviço antes de adicioná-lo à OS.')),
      );
      return;
    }

    String servicoUuid = _servicos.first.uuid;
    final quantidade = TextEditingController(text: '1');
    final valorUnitario = TextEditingController(
      text: _servicos.first.valorPadrao.toStringAsFixed(2).replaceAll('.', ','),
    );
    final desconto = TextEditingController(text: '0,00');
    final observacao = TextEditingController();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final selecionado = _servicos.firstWhere(
            (item) => item.uuid == servicoUuid,
          );
          return AlertDialog(
            title: const Text('Adicionar serviço'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: servicoUuid,
                    decoration: const InputDecoration(labelText: 'Serviço *'),
                    items: _servicos
                        .map(
                          (servico) => DropdownMenuItem<String>(
                            value: servico.uuid,
                            child: Text(servico.descricao),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => servicoUuid = value);
                      final novo = _servicos.firstWhere((e) => e.uuid == value);
                      valorUnitario.text = novo.valorPadrao
                          .toStringAsFixed(2)
                          .replaceAll('.', ',');
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                          controller: quantidade,
                          decoration: const InputDecoration(labelText: 'Quantidade'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                          controller: valorUnitario,
                          decoration: const InputDecoration(
                            labelText: 'Valor unitário',
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                    controller: desconto,
                    decoration: const InputDecoration(
                      labelText: 'Desconto',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                    controller: observacao,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Observação'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Serviço selecionado: ${selecionado.descricao}',
                      style: Theme.of(context).textTheme.bodySmall,
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
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );

    final qtd = parseCurrency(quantidade.text);
    final unitario = parseCurrency(valorUnitario.text);
    final valorDesconto = parseCurrency(desconto.text);
    final textoObservacao = observacao.text.trim().toUpperCase();

    await WidgetsBinding.instance.endOfFrame;
    quantidade.dispose();
    valorUnitario.dispose();
    desconto.dispose();
    observacao.dispose();

    if (!mounted || confirmou != true) return;
    if (qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quantidade deve ser maior que zero.')),
      );
      return;
    }

    final servico = _servicos.firstWhere((e) => e.uuid == servicoUuid);
    final agora = DateTime.now();
    setState(() {
      _servicosDaOrdem.add(
        OrdemServicoItem(
          uuid: const Uuid().v4(),
          empresaUuid: SessionManager.instance.requireEmpresaUuid(),
          ordemUuid: _ordemUuid,
          servicoUuid: servico.uuid,
          descricao: servico.descricao,
          quantidade: qtd,
          valorUnitario: unitario,
          desconto: valorDesconto,
          observacao: textoObservacao,
          ordem: _servicosDaOrdem.length,
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );
      _atualizarValorTotal();
    });
  }

  Future<void> _editarServico(int index) async {
    final atual = _servicosDaOrdem[index];
    final quantidade = TextEditingController(
      text: atual.quantidade.toStringAsFixed(2).replaceAll('.', ','),
    );
    final valorUnitario = TextEditingController(
      text: atual.valorUnitario.toStringAsFixed(2).replaceAll('.', ','),
    );
    final desconto = TextEditingController(
      text: atual.desconto.toStringAsFixed(2).replaceAll('.', ','),
    );
    final observacao = TextEditingController(text: atual.observacao ?? '');

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(atual.descricao),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                controller: quantidade,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                controller: valorUnitario,
                decoration: const InputDecoration(
                  labelText: 'Valor unitário',
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                controller: desconto,
                decoration: const InputDecoration(
                  labelText: 'Desconto',
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                controller: observacao,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Observação'),
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
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    final qtd = parseCurrency(quantidade.text);
    final unitario = parseCurrency(valorUnitario.text);
    final valorDesconto = parseCurrency(desconto.text);
    final textoObservacao = observacao.text.trim().toUpperCase();

    await WidgetsBinding.instance.endOfFrame;
    quantidade.dispose();
    valorUnitario.dispose();
    desconto.dispose();
    observacao.dispose();

    if (!mounted || confirmou != true || qtd <= 0) return;
    setState(() {
      _servicosDaOrdem[index] = atual.copyWith(
        quantidade: qtd,
        valorUnitario: unitario,
        desconto: valorDesconto,
        observacao: textoObservacao,
        atualizadoEm: DateTime.now(),
        sincronizado: false,
      );
      _atualizarValorTotal();
    });
  }

  Future<void> _adicionarProduto() async {
    if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um produto antes de adicioná-lo à OS.')),
      );
      return;
    }

    String produtoUuid = _produtos.first.uuid;
    final quantidade = TextEditingController(text: '1');
    final valorUnitario = TextEditingController(
      text: _produtos.first.valorVenda.toStringAsFixed(2).replaceAll('.', ','),
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final selecionado = _produtos.firstWhere((e) => e.uuid == produtoUuid);
          return AlertDialog(
            title: const Text('Adicionar produto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: produtoUuid,
                    decoration: const InputDecoration(labelText: 'Produto *'),
                    items: _produtos.map((produto) => DropdownMenuItem<String>(
                      value: produto.uuid,
                      child: Text('${produto.codigo} - ${produto.descricao}'),
                    )).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => produtoUuid = value);
                      final novo = _produtos.firstWhere((e) => e.uuid == value);
                      valorUnitario.text = novo.valorVenda.toStringAsFixed(2).replaceAll('.', ',');
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: quantidade,
                          decoration: InputDecoration(labelText: 'Quantidade (${selecionado.unidade})'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: valorUnitario,
                          decoration: const InputDecoration(labelText: 'Valor unitário', prefixText: 'R\$ '),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NCM: ${selecionado.ncm ?? '-'} • CSOSN: ${selecionado.csosn ?? '-'} • CFOP: ${selecionado.cfop ?? '-'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Adicionar')),
            ],
          );
        },
      ),
    );

    final qtd = parseCurrency(quantidade.text);
    final unitario = parseCurrency(valorUnitario.text);
    quantidade.dispose();
    valorUnitario.dispose();

    if (!mounted || confirmou != true) return;
    if (qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quantidade deve ser maior que zero.')),
      );
      return;
    }

    final produto = _produtos.firstWhere((e) => e.uuid == produtoUuid);
    final agora = DateTime.now();
    setState(() {
      _produtosDaOrdem.add(
        OrdemServicoProduto(
          uuid: const Uuid().v4(),
          empresaUuid: SessionManager.instance.requireEmpresaUuid(),
          ordemUuid: _ordemUuid,
          produtoUuid: produto.uuid,
          codigoProduto: produto.codigo,
          descricao: produto.descricao,
          unidade: produto.unidade,
          ncm: produto.ncm,
          csosn: produto.csosn,
          cfop: produto.cfop,
          quantidade: qtd,
          valorUnitario: unitario,
          ordem: _produtosDaOrdem.length,
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );
      _atualizarValorTotal();
    });
  }

  Future<void> _editarProduto(int index) async {
    final atual = _produtosDaOrdem[index];
    final quantidade = TextEditingController(
      text: atual.quantidade.toStringAsFixed(2).replaceAll('.', ','),
    );
    final valorUnitario = TextEditingController(
      text: atual.valorUnitario.toStringAsFixed(2).replaceAll('.', ','),
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(atual.descricao),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: quantidade,
                decoration: InputDecoration(labelText: 'Quantidade (${atual.unidade})'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorUnitario,
                decoration: const InputDecoration(labelText: 'Valor unitário', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirmar')),
        ],
      ),
    );

    final qtd = parseCurrency(quantidade.text);
    final unitario = parseCurrency(valorUnitario.text);
    quantidade.dispose();
    valorUnitario.dispose();

    if (!mounted || confirmou != true || qtd <= 0) return;
    setState(() {
      _produtosDaOrdem[index] = atual.copyWith(
        quantidade: qtd,
        valorUnitario: unitario,
        atualizadoEm: DateTime.now(),
        sincronizado: false,
      );
      _atualizarValorTotal();
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
                TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                  controller: descricao,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Ex.: Testar funcionamento',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
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
                if (descricao.text.trim().toUpperCase().isEmpty) return;
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    final descricaoInformada = descricao.text.trim().toUpperCase();
    final observacaoInformada = observacao.text.trim().toUpperCase();

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
          content: TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
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

    final observacaoInformada = controller.text.trim().toUpperCase();

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

  Future<void> _abrirPlanoManutencao() async {
    final itemUuid = _itemUuid;
    if (itemUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o veículo/item da OS.')),
      );
      return;
    }
    final selecionados = _itens.where((e) => e.uuid == itemUuid).toList();
    if (selecionados.isEmpty) return;

    final resultado = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => PlanoManutencaoVeiculoScreen(
          item: selecionados.first,
          kmAtual: int.tryParse(_kmAtual.text.trim()),
          executadasNestaOrdem: _manutencoesExecutadas,
        ),
      ),
    );
    if (!mounted || resultado == null) return;
    setState(() => _manutencoesExecutadas = resultado);
  }

  OrdemServico _montarOrdemAtual() {
    final agora = DateTime.now();
    final original = widget.ordem;
    final configuracoes = _configuracoes;
    final statusEfetivo = configuracoes?.usarStatus == false ? 'CONCLUIDA' : _status;
    final concluida = statusEfetivo == 'CONCLUIDA';

    return OrdemServico(
      id: original?.id,
      uuid: _ordemUuid,
      empresaUuid: SessionManager.instance.requireEmpresaUuid(),
      numeroOs: _numeroOs,
      clienteUuid: _clienteUuid!,
      itemUuid: _itemUuid!,
      servicoUuid: null,
      status: statusEfetivo,
      descricaoProblema: _problema.text.trim().toUpperCase(),
      diagnostico: configuracoes?.usarDiagnostico == false
          ? (original?.diagnostico ?? '')
          : _diagnostico.text.trim().toUpperCase(),
      solucao: configuracoes?.usarSolucaoAplicada == false
          ? (original?.solucao ?? '')
          : _solucao.text.trim().toUpperCase(),
      valorTotal: _totalServicos + _totalProdutos,
      kmAtual: int.tryParse(_kmAtual.text.trim()),
      dataAbertura: original?.dataAbertura ?? agora,
      dataConclusao: concluida ? (original?.dataConclusao ?? agora) : null,
      criadoEm: original?.criadoEm ?? agora,
      atualizadoEm: agora,
    );
  }

  Future<void> _gerarPdf({required bool compartilhar}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_servicosDaOrdem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um serviço à OS.')),
      );
      return;
    }

    final clientes = _clientes.where((e) => e.uuid == _clienteUuid).toList();
    final itens = _itens.where((e) => e.uuid == _itemUuid).toList();
    if (clientes.isEmpty || itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o cliente e o item da OS.')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);
    try {
      final ordem = _montarOrdemAtual();
      if (compartilhar) {
        await _pdfService.compartilhar(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          servicos: List<OrdemServicoItem>.unmodifiable(_servicosDaOrdem),
          produtos: List<OrdemServicoProduto>.unmodifiable(_produtosDaOrdem),
          checklist: List<ChecklistOsItem>.unmodifiable(_checklist),
          configuracoes: _configuracoes,
        );
      } else {
        await _pdfService.imprimir(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          servicos: List<OrdemServicoItem>.unmodifiable(_servicosDaOrdem),
          produtos: List<OrdemServicoProduto>.unmodifiable(_produtosDaOrdem),
          checklist: List<ChecklistOsItem>.unmodifiable(_checklist),
          configuracoes: _configuracoes,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível gerar o PDF: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _gerarPedidoPdf({required bool compartilhar}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    final clientes = _clientes.where((e) => e.uuid == _clienteUuid).toList();
    final itens = _itens.where((e) => e.uuid == _itemUuid).toList();
    if (clientes.isEmpty || itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o cliente e o item da OS.')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);
    try {
      final Empresa? empresa = await _empresaRepository.obter();
      if (empresa == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastre os dados da empresa na tela inicial antes de gerar o pedido.'),
            ),
          );
        }
        return;
      }

      final ordem = _montarOrdemAtual();
      if (compartilhar) {
        await _pedidoPdfService.compartilhar(
          empresa: empresa,
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          servicos: List<OrdemServicoItem>.unmodifiable(_servicosDaOrdem),
          produtos: List<OrdemServicoProduto>.unmodifiable(_produtosDaOrdem),
        );
      } else {
        await _pedidoPdfService.imprimir(
          empresa: empresa,
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          servicos: List<OrdemServicoItem>.unmodifiable(_servicosDaOrdem),
          produtos: List<OrdemServicoProduto>.unmodifiable(_produtosDaOrdem),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível gerar o pedido: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _gerarRelatorioFotografico({required bool compartilhar}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_fotosDaOrdem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos uma foto à Ordem de Serviço.')),
      );
      return;
    }

    final clientes = _clientes.where((e) => e.uuid == _clienteUuid).toList();
    final itens = _itens.where((e) => e.uuid == _itemUuid).toList();
    if (clientes.isEmpty || itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o cliente e o item da OS.')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);
    try {
      final ordem = _montarOrdemAtual();
      final empresa = await _empresaRepository.obter();
      final fotos = List<OrdemServicoFoto>.unmodifiable(_fotosDaOrdem);

      if (compartilhar) {
        await _relatorioFotograficoPdfService.compartilhar(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          fotos: fotos,
          empresa: empresa,
        );
      } else {
        await _relatorioFotograficoPdfService.imprimir(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          fotos: fotos,
          empresa: empresa,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível gerar o relatório fotográfico: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _gerarPdfVistoria({required bool compartilhar}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final vistoria = _vistoria;
    final clientes = _clientes.where((e) => e.uuid == _clienteUuid).toList();
    final itens = _itens.where((e) => e.uuid == _itemUuid).toList();

    if (vistoria == null || clientes.isEmpty || itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha a vistoria e selecione cliente e item.')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);
    try {
      final ordem = _montarOrdemAtual();
      if (compartilhar) {
        await _vistoriaPdfService.compartilhar(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          vistoria: vistoria,
        );
      } else {
        await _vistoriaPdfService.imprimir(
          ordem: ordem,
          cliente: clientes.first,
          item: itens.first,
          vistoria: vistoria,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível gerar a vistoria: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _abrirGaleriaFotos() async {
    final resultado = await Navigator.push<List<OrdemServicoFoto>>(
      context,
      MaterialPageRoute(
        builder: (_) => OsFotosScreen(
          ordemUuid: _ordemUuid,
          fotos: List<OrdemServicoFoto>.of(_fotosDaOrdem),
        ),
      ),
    );
    if (!mounted || resultado == null) return;

    setState(() => _fotosDaOrdem = resultado);

    // Para OS já gravada, persiste as fotos assim que a galeria é fechada.
    // Em uma OS nova, a persistência continua ocorrendo junto com o Salvar da OS,
    // evitando criar registros órfãos antes da própria ordem existir.
    if (widget.ordem != null) {
      try {
        await _ordemFotoRepository.substituirDaOrdem(
          _ordemUuid,
          _fotosDaOrdem,
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível salvar as fotos: $error')),
          );
        }
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_servicosDaOrdem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um serviço à OS.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final original = widget.ordem;
      final ordem = _montarOrdemAtual();

      if (original == null) {
        await _repository.salvar(ordem);
      } else {
        await _repository.atualizar(ordem);
      }

      if (_configuracoes?.usarManutencaoPreventiva != false) {
        await _manutencaoRepository.substituirExecucoesDaOrdem(
          ordemUuid: _ordemUuid,
          itemUuid: _itemUuid!,
          manutencoesUuid: _manutencoesExecutadas,
          quilometragem: int.tryParse(_kmAtual.text.trim()),
          dataExecucao: DateTime.now(),
        );
      }

      await _ordemItemRepository.substituirDaOrdem(
        _ordemUuid,
        _servicosDaOrdem,
      );

      await _ordemProdutoRepository.substituirDaOrdem(
        _ordemUuid,
        _produtosDaOrdem,
      );

      await _ordemFotoRepository.substituirDaOrdem(
        _ordemUuid,
        _fotosDaOrdem,
      );

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
    _kmAtual.dispose();
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
                      setState(() {
                        _itemUuid = value;
                        _manutencoesExecutadas = <String>{};
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecione o item.' : null,
                  ),
                  if (_itemSelecionadoEhVeiculo) ...<Widget>[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _kmAtual,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Quilometragem atual',
                        suffixText: 'km',
                        prefixIcon: Icon(Icons.speed_outlined),
                      ),
                      validator: (value) {
                        final texto = (value ?? '').trim();
                        if (texto.isEmpty) return null;
                        final km = int.tryParse(texto);
                        if (km == null || km < 0) return 'Informe uma quilometragem válida.';
                        return null;
                      },
                    ),
                    if (_configuracoes?.usarManutencaoPreventiva != false) ...<Widget>[
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.car_repair_outlined)),
                          title: const Text('Manutenção preventiva'),
                          subtitle: Text(
                            _manutencoesExecutadas.isEmpty
                                ? 'Consultar plano do veículo e registrar manutenções executadas'
                                : '${_manutencoesExecutadas.length} manutenção(ões) marcada(s) como executada(s) nesta OS',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _salvando ? null : _abrirPlanoManutencao,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                  ] else
                    const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Serviços da OS (${_servicosDaOrdem.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _salvando ? null : _adicionarServico,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_servicosDaOrdem.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nenhum serviço adicionado à Ordem de Serviço.'),
                      ),
                    ),
                  ...List<Widget>.generate(_servicosDaOrdem.length, (index) {
                    final item = _servicosDaOrdem[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(item.descricao),
                        subtitle: Text(
                          '${item.quantidade.toStringAsFixed(2)} × R\$ ${item.valorUnitario.toStringAsFixed(2)}'
                          '${item.desconto > 0 ? ' • desconto R\$ ${item.desconto.toStringAsFixed(2)}' : ''}'
                          '${(item.observacao ?? '').isNotEmpty ? '\n${item.observacao}' : ''}',
                        ),
                        isThreeLine: (item.observacao ?? '').isNotEmpty,
                        trailing: SizedBox(
                          width: 118,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'R\$ ${item.valorTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (acao) {
                                  if (acao == 'editar') {
                                    _editarServico(index);
                                  } else if (acao == 'remover') {
                                    setState(() {
                                      _servicosDaOrdem.removeAt(index);
                                      _atualizarValorTotal();
                                    });
                                  }
                                },
                                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                                  PopupMenuItem(value: 'remover', child: Text('Remover')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Produtos da OS (${_produtosDaOrdem.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _salvando ? null : _adicionarProduto,
                        icon: const Icon(Icons.add_shopping_cart_outlined),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_produtosDaOrdem.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nenhum produto/peça lançado na Ordem de Serviço.'),
                      ),
                    ),
                  ...List<Widget>.generate(_produtosDaOrdem.length, (index) {
                    final produto = _produtosDaOrdem[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                        title: Text('${produto.codigoProduto} - ${produto.descricao}'),
                        subtitle: Text(
                          '${produto.quantidade.toStringAsFixed(2)} ${produto.unidade} × R\$ ${produto.valorUnitario.toStringAsFixed(2)}'
                          '\nNCM ${produto.ncm ?? '-'} • CSOSN ${produto.csosn ?? '-'} • CFOP ${produto.cfop ?? '-'}',
                        ),
                        isThreeLine: true,
                        trailing: SizedBox(
                          width: 118,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'R\$ ${produto.valorTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (acao) {
                                  if (acao == 'editar') {
                                    _editarProduto(index);
                                  } else if (acao == 'remover') {
                                    setState(() {
                                      _produtosDaOrdem.removeAt(index);
                                      _atualizarValorTotal();
                                    });
                                  }
                                },
                                itemBuilder: (_) => const <PopupMenuEntry<String>>[
                                  PopupMenuItem(value: 'editar', child: Text('Editar quantidade/valor')),
                                  PopupMenuItem(value: 'remover', child: Text('Remover')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_configuracoes?.usarStatus != false) ...<Widget>[
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
                  ],
                  const SizedBox(height: 12),
                  TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
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
                  if (_configuracoes?.usarDiagnostico != false) ...<Widget>[
                    const SizedBox(height: 12),
                    TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
                      controller: _diagnostico,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Diagnóstico',
                      ),
                    ),
                  ],
                  if (_configuracoes?.usarSolucaoAplicada != false) ...<Widget>[
                    const SizedBox(height: 12),
                    TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter],
                      controller: _solucao,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Solução aplicada',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text('Subtotal serviços'),
                              Text('R\$ ${_totalServicos.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text('Subtotal produtos'),
                              Text('R\$ ${_totalProdutos.toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                    controller: _valor,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Valor total da Ordem de Serviço',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 24),
                  if (_configuracoes?.usarFotosOs != false)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.photo_library_outlined),
                      ),
                      title: const Text('Fotos da Ordem de Serviço'),
                      subtitle: Text(
                        _fotosDaOrdem.isEmpty
                            ? 'Nenhuma foto adicionada • limite de 6 fotos'
                            : '${_fotosDaOrdem.length}/6 fotos • toque para abrir a galeria',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (_fotosDaOrdem.isNotEmpty)
                            Text('${_fotosDaOrdem.length}/6'),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: _salvando ? null : _abrirGaleriaFotos,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_configuracoes?.usarFichaVistoria != false) ...<Widget>[
                    Text(
                      'Ficha de vistoria do veículo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_configuracoes?.usarFichaVistoria != false && _vistoria != null)
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: <Widget>[
                          ListTile(
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
                              setState(() {
                                _vistoria = resultado;
                                if (_kmAtual.text.trim().isEmpty && resultado.km.trim().isNotEmpty) {
                                  _kmAtual.text = resultado.km.replaceAll(RegExp(r'[^0-9]'), '');
                                }
                              });
                            },
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _salvando || _gerandoPdf
                                        ? null
                                        : () => _gerarPdfVistoria(compartilhar: false),
                                    icon: const Icon(Icons.print_outlined),
                                    label: const Text('Imprimir vistoria'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: _salvando || _gerandoPdf
                                        ? null
                                        : () => _gerarPdfVistoria(compartilhar: true),
                                    icon: const Icon(Icons.share_outlined),
                                    label: const Text('Compartilhar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_configuracoes?.usarChecklist != false) ...<Widget>[
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
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf
                            ? null
                            : () => _gerarPdf(compartilhar: false),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Imprimir PDF'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf
                            ? null
                            : () => _gerarPdf(compartilhar: true),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartilhar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf
                            ? null
                            : () => _gerarPedidoPdf(compartilhar: false),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Pedido'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf
                            ? null
                            : () => _gerarPedidoPdf(compartilhar: true),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartilhar pedido'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf || _fotosDaOrdem.isEmpty
                            ? null
                            : () => _gerarRelatorioFotografico(compartilhar: false),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Relatório fotográfico'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salvando || _gerandoPdf || _fotosDaOrdem.isEmpty
                            ? null
                            : () => _gerarRelatorioFotografico(compartilhar: true),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Compartilhar relatório'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _salvando || _gerandoPdf ? null : _salvar,
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

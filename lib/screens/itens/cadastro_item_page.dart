import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/item_atendimento.dart';

class CadastroItemPage extends StatefulWidget {
  final ItemAtendimento? item;

  const CadastroItemPage({
    super.key,
    this.item,
  });

  @override
  State<CadastroItemPage> createState() => _CadastroItemPageState();
}

class _CadastroItemPageState extends State<CadastroItemPage> {
  final _formKey = GlobalKey<FormState>();

  static const _tipos = <String>[
    'Carro',
    'Caminhão',
    'Moto',
    'Máquina agrícola',
    'Equipamento',
    'Computador',
    'Ar-condicionado',
    'Outro',
  ];

  late String _tipo;

  late final TextEditingController _clienteController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _identificacaoController;
  late final TextEditingController _numeroSerieController;
  late final TextEditingController _patrimonioController;
  late final TextEditingController _placaController;
  late final TextEditingController _renavamController;
  late final TextEditingController _chassiController;
  late final TextEditingController _anoController;
  late final TextEditingController _corController;
  late final TextEditingController _quilometragemController;
  late final TextEditingController _horimetroController;
  late final TextEditingController _processadorController;
  late final TextEditingController _memoriaController;
  late final TextEditingController _armazenamentoController;
  late final TextEditingController _btusController;
  late final TextEditingController _tipoGasController;
  late final TextEditingController _observacoesController;

  bool get _ehVeiculo => const {'Carro', 'Caminhão', 'Moto'}.contains(_tipo);
  bool get _ehMaquina => _tipo == 'Máquina agrícola';
  bool get _ehComputador => _tipo == 'Computador';
  bool get _ehArCondicionado => _tipo == 'Ar-condicionado';

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    _tipo = _tipos.contains(item?.tipo) ? item!.tipo : _tipos.first;

    _clienteController = TextEditingController(text: item?.cliente ?? '');
    _descricaoController = TextEditingController(text: item?.descricao ?? '');
    _marcaController = TextEditingController(text: item?.marca ?? '');
    _modeloController = TextEditingController(text: item?.modelo ?? '');
    _identificacaoController =
        TextEditingController(text: item?.identificacao ?? '');
    _numeroSerieController =
        TextEditingController(text: item?.numeroSerie ?? '');
    _patrimonioController = TextEditingController(text: item?.patrimonio ?? '');
    _placaController = TextEditingController(text: item?.placa ?? '');
    _renavamController = TextEditingController(text: item?.renavam ?? '');
    _chassiController = TextEditingController(text: item?.chassi ?? '');
    _anoController = TextEditingController(text: item?.ano ?? '');
    _corController = TextEditingController(text: item?.cor ?? '');
    _quilometragemController =
        TextEditingController(text: item?.quilometragem ?? '');
    _horimetroController = TextEditingController(text: item?.horimetro ?? '');
    _processadorController =
        TextEditingController(text: item?.processador ?? '');
    _memoriaController = TextEditingController(text: item?.memoria ?? '');
    _armazenamentoController =
        TextEditingController(text: item?.armazenamento ?? '');
    _btusController = TextEditingController(text: item?.btus ?? '');
    _tipoGasController = TextEditingController(text: item?.tipoGas ?? '');
    _observacoesController =
        TextEditingController(text: item?.observacoes ?? '');
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _descricaoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _identificacaoController.dispose();
    _numeroSerieController.dispose();
    _patrimonioController.dispose();
    _placaController.dispose();
    _renavamController.dispose();
    _chassiController.dispose();
    _anoController.dispose();
    _corController.dispose();
    _quilometragemController.dispose();
    _horimetroController.dispose();
    _processadorController.dispose();
    _memoriaController.dispose();
    _armazenamentoController.dispose();
    _btusController.dispose();
    _tipoGasController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final item = ItemAtendimento(
      cliente: _clienteController.text.trim(),
      tipo: _tipo,
      descricao: _descricaoController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      identificacao: _identificacaoController.text.trim(),
      numeroSerie: _numeroSerieController.text.trim(),
      patrimonio: _patrimonioController.text.trim(),
      placa: _placaController.text.trim().toUpperCase(),
      renavam: _renavamController.text.trim(),
      chassi: _chassiController.text.trim().toUpperCase(),
      ano: _anoController.text.trim(),
      cor: _corController.text.trim(),
      quilometragem: _quilometragemController.text.trim(),
      horimetro: _horimetroController.text.trim(),
      processador: _processadorController.text.trim(),
      memoria: _memoriaController.text.trim(),
      armazenamento: _armazenamentoController.text.trim(),
      btus: _btusController.text.trim(),
      tipoGas: _tipoGasController.text.trim(),
      observacoes: _observacoesController.text.trim(),
    );

    Navigator.pop(context, item);
  }

  InputDecoration _decoracao(
    String label, {
    IconData? icon,
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixText: suffix,
      border: const OutlineInputBorder(),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    IconData? icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: _decoracao(
          label,
          icon: icon,
          hint: hint,
          suffix: suffix,
        ),
        validator: validator,
      ),
    );
  }

  Widget _tituloSecao(String titulo, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _camposEspecificos() {
    if (_ehVeiculo) {
      return [
        _tituloSecao('Dados do veículo', Icons.directions_car),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campo(
                _placaController,
                'Placa',
                icon: Icons.pin,
                hint: 'ABC1D23',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(7),
                  UpperCaseTextFormatter(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                _anoController,
                'Ano',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
        _campo(
          _renavamController,
          'RENAVAM',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        _campo(
          _chassiController,
          'Chassi',
          icon: Icons.confirmation_number_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(17),
            UpperCaseTextFormatter(),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campo(
                _corController,
                'Cor',
                icon: Icons.palette_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                _quilometragemController,
                'Quilometragem',
                icon: Icons.speed,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: 'km',
              ),
            ),
          ],
        ),
      ];
    }

    if (_ehMaquina) {
      return [
        _tituloSecao('Dados da máquina', Icons.agriculture),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campo(
                _anoController,
                'Ano',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                _horimetroController,
                'Horímetro',
                icon: Icons.timer_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                suffix: 'h',
              ),
            ),
          ],
        ),
        _campo(
          _chassiController,
          'Chassi / estrutura',
          icon: Icons.confirmation_number_outlined,
          inputFormatters: [
            UpperCaseTextFormatter(),
          ],
        ),
      ];
    }

    if (_ehComputador) {
      return [
        _tituloSecao('Configuração do computador', Icons.computer),
        _campo(
          _processadorController,
          'Processador',
          icon: Icons.memory,
          hint: 'Ex.: Intel Core i5',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campo(
                _memoriaController,
                'Memória',
                icon: Icons.developer_board_outlined,
                hint: 'Ex.: 8 GB',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                _armazenamentoController,
                'Armazenamento',
                icon: Icons.storage,
                hint: 'Ex.: SSD 512 GB',
              ),
            ),
          ],
        ),
      ];
    }

    if (_ehArCondicionado) {
      return [
        _tituloSecao('Dados do ar-condicionado', Icons.ac_unit),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campo(
                _btusController,
                'Capacidade',
                icon: Icons.thermostat,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: 'BTUs',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                _tipoGasController,
                'Tipo de gás',
                icon: Icons.air,
                hint: 'Ex.: R-410A',
              ),
            ),
          ],
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar item' : 'Novo item'),
        actions: [
          IconButton(
            onPressed: _salvar,
            tooltip: 'Salvar',
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tituloSecao('Proprietário e classificação', Icons.person),
              _campo(
                _clienteController,
                'Cliente / proprietário',
                icon: Icons.person_outline,
                hint: 'Informe o nome do cliente',
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o cliente proprietário';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: _decoracao(
                    'Tipo do item',
                    icon: Icons.category_outlined,
                  ),
                  items: _tipos
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor == null) return;
                    setState(() => _tipo = valor);
                  },
                ),
              ),
              _tituloSecao('Identificação', Icons.inventory_2_outlined),
              _campo(
                _descricaoController,
                'Descrição ou apelido',
                icon: Icons.label_outline,
                hint: 'Ex.: Gol do João, Notebook recepção',
                validator: (valor) {
                  final descricao = valor?.trim() ?? '';
                  final marca = _marcaController.text.trim();
                  final modelo = _modeloController.text.trim();

                  if (descricao.isEmpty && marca.isEmpty && modelo.isEmpty) {
                    return 'Informe a descrição ou a marca/modelo';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _campo(
                      _marcaController,
                      'Marca',
                      icon: Icons.business_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(
                      _modeloController,
                      'Modelo',
                      icon: Icons.view_in_ar_outlined,
                    ),
                  ),
                ],
              ),
              _campo(
                _identificacaoController,
                'Identificação interna',
                icon: Icons.qr_code,
                hint: 'Código ou identificação usada pelo cliente',
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _campo(
                      _numeroSerieController,
                      'Número de série',
                      icon: Icons.numbers,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(
                      _patrimonioController,
                      'Patrimônio',
                      icon: Icons.sell_outlined,
                    ),
                  ),
                ],
              ),
              ..._camposEspecificos(),
              _tituloSecao('Informações adicionais', Icons.notes),
              _campo(
                _observacoesController,
                'Observações',
                icon: Icons.notes,
                hint: 'Características, acessórios entregues e outras informações',
                maxLines: 4,
              ),
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(editando ? 'Salvar alterações' : 'Cadastrar item'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
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

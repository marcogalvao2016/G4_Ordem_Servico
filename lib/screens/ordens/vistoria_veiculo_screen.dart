import 'package:flutter/material.dart';

import '../../models/item_atendimento.dart';
import '../../models/vistoria_veiculo.dart';
import '../../widgets/vehicle_damage_map.dart';

class VistoriaVeiculoScreen extends StatefulWidget {
  const VistoriaVeiculoScreen({
    super.key,
    required this.numeroOs,
    required this.initial,
    required this.item,
  });

  final int numeroOs;
  final VistoriaVeiculo initial;
  final ItemAtendimento? item;

  @override
  State<VistoriaVeiculoScreen> createState() => _VistoriaVeiculoScreenState();
}

class _VistoriaVeiculoScreenState extends State<VistoriaVeiculoScreen> {
  late VistoriaVeiculo _vistoria;
  int _etapa = 0;

  late final TextEditingController _motorista;
  late final TextEditingController _local;
  late final TextEditingController _destino;
  late final TextEditingController _km;
  late final TextEditingController _outroMotivo;
  late final TextEditingController _observacoes;
  late final TextEditingController _seguradoNome;
  late final TextEditingController _seguradoRg;
  late final TextEditingController _destinatarioNome;
  late final TextEditingController _destinatarioRg;
  late final TextEditingController _prestadorNome;
  late final TextEditingController _prestadorRg;

  static const _tipos = <String>[
    'Remoção',
    'Socorro mecânico',
    'Troca de pneu',
    'Carga de bateria',
    'Chaveiro',
    'Outro',
  ];

  static const _motivos = <String>[
    'Pane mecânica',
    'Pane elétrica',
    'Colisão',
    'Pneu',
    'Bateria',
    'Falta de combustível',
    'Superaquecimento',
    'Freios',
    'Suspensão',
    'Outro',
  ];

  static const _pneus = <String, String>{
    'dianteiro_esquerdo': 'Dianteiro esquerdo',
    'dianteiro_direito': 'Dianteiro direito',
    'traseiro_esquerdo': 'Traseiro esquerdo',
    'traseiro_direito': 'Traseiro direito',
    'estepe': 'Estepe',
  };

  static const _gruposAcessorios = <String, List<String>>{
    'Segurança': ['Triângulo', 'Macaco', 'Chave de roda', 'Extintor', 'Estepe'],
    'Interior': ['Rádio', 'Manual', 'Documentos', 'Tapetes', 'Acendedor'],
    'Elétrica': ['Faróis', 'Lanternas', 'Luz de freio', 'Pisca-alerta', 'Buzina'],
    'Exterior': ['Retrovisores', 'Para-choques', 'Rodas', 'Calotas', 'Antena'],
  };

  @override
  void initState() {
    super.initState();
    _vistoria = widget.initial;
    _motorista = TextEditingController(text: _vistoria.nomeMotorista);
    _local = TextEditingController(text: _vistoria.local);
    _destino = TextEditingController(text: _vistoria.destino);
    _km = TextEditingController(text: _vistoria.km);
    _outroMotivo = TextEditingController(text: _vistoria.outroMotivo);
    _observacoes = TextEditingController(text: _vistoria.observacoes);
    _seguradoNome = TextEditingController(text: _vistoria.seguradoNome);
    _seguradoRg = TextEditingController(text: _vistoria.seguradoRg);
    _destinatarioNome = TextEditingController(text: _vistoria.destinatarioNome);
    _destinatarioRg = TextEditingController(text: _vistoria.destinatarioRg);
    _prestadorNome = TextEditingController(text: _vistoria.prestadorNome);
    _prestadorRg = TextEditingController(text: _vistoria.prestadorRg);
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _motorista,
      _local,
      _destino,
      _km,
      _outroMotivo,
      _observacoes,
      _seguradoNome,
      _seguradoRg,
      _destinatarioNome,
      _destinatarioRg,
      _prestadorNome,
      _prestadorRg,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _alterar(VistoriaVeiculo value) {
    setState(() {
      _vistoria = value.copyWith(
        atualizadoEm: DateTime.now(),
        sincronizado: false,
      );
    });
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: const OutlineInputBorder(),
      );

  Future<void> _adicionarDano({String areaInicial = 'Frente'}) async {
    String area = areaInicial;
    String tipo = 'Risco';
    final detalhe = TextEditingController();

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar dano ou avaria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: area,
                  decoration: _dec('Região do veículo'),
                  items: const [
                    'Frente', 'Traseira', 'Lateral esquerda', 'Lateral direita',
                    'Capô', 'Teto', 'Porta dianteira esquerda',
                    'Porta dianteira direita', 'Porta traseira esquerda',
                    'Porta traseira direita', 'Para-brisa', 'Interior', 'Outro'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => area = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: _dec('Tipo de dano'),
                  items: const ['Risco', 'Amassado', 'Quebrado', 'Trincado', 'Pintura', 'Ferrugem', 'Ausente', 'Outro']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => tipo = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: detalhe, decoration: _dec('Detalhes')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await WidgetsBinding.instance.endOfFrame;
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final value = <String, String>{
                  'area': area,
                  'tipo': tipo,
                  'detalhe': detalhe.text.trim(),
                };
                FocusManager.instance.primaryFocus?.unfocus();
                await WidgetsBinding.instance.endOfFrame;
                if (context.mounted) Navigator.of(context).pop(value);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );

    await WidgetsBinding.instance.endOfFrame;
    detalhe.dispose();
    if (!mounted || resultado == null) return;
    _alterar(_vistoria.copyWith(danos: [..._vistoria.danos, resultado]));
  }

  int get _itensPreenchidos {
    var total = 0;
    if (_vistoria.nomeMotorista.trim().isNotEmpty) total++;
    if (_vistoria.local.trim().isNotEmpty) total++;
    if (_vistoria.destino.trim().isNotEmpty) total++;
    if (_vistoria.km.trim().isNotEmpty) total++;
    if (_vistoria.tiposAtendimento.isNotEmpty) total++;
    if (_vistoria.motivos.isNotEmpty) total++;
    if (_vistoria.pneus.length >= 4) total++;
    if (_vistoria.acessorios.isNotEmpty) total++;
    if (_vistoria.observacoes.trim().isNotEmpty) total++;
    return total;
  }

  Widget _cabecalhoEtapa(String titulo, String subtitulo, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(subtitulo, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _identificacao() {
    final item = widget.item;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _cabecalhoEtapa('Identificação', 'Dados do atendimento e do veículo.', Icons.badge_outlined),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OS ${widget.numeroOs}', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                Text('Veículo: ${item?.descricao ?? 'Não selecionado'}'),
                Text('Marca/Modelo: ${item?.marca ?? '-'} / ${item?.modelo ?? '-'}'),
                Text('Ano: ${item?.ano ?? '-'}  •  Cor: ${item?.cor ?? '-'}'),
                Text('Placa: ${item?.placa ?? '-'}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _motorista,
          decoration: _dec('Motorista', icon: Icons.person_outline),
          onChanged: (value) => _alterar(_vistoria.copyWith(nomeMotorista: value)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _local,
          decoration: _dec('Local de origem', icon: Icons.trip_origin),
          onChanged: (value) => _alterar(_vistoria.copyWith(local: value)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _destino,
          decoration: _dec('Destino', icon: Icons.location_on_outlined),
          onChanged: (value) => _alterar(_vistoria.copyWith(destino: value)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _km,
          keyboardType: TextInputType.number,
          decoration: _dec('Quilometragem', icon: Icons.speed),
          onChanged: (value) => _alterar(_vistoria.copyWith(km: value)),
        ),
      ],
    );
  }

  Widget _atendimento() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalhoEtapa('Atendimento', 'Informe o serviço e o motivo da chamada.', Icons.support_agent),
          Text('Tipo de atendimento', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tipos.map((item) {
              final selected = _vistoria.tiposAtendimento.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (value) {
                  final lista = [..._vistoria.tiposAtendimento];
                  value ? lista.add(item) : lista.remove(item);
                  _alterar(_vistoria.copyWith(tiposAtendimento: lista));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Motivo da chamada', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _motivos.map((item) {
              final selected = _vistoria.motivos.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (value) {
                  final lista = [..._vistoria.motivos];
                  value ? lista.add(item) : lista.remove(item);
                  _alterar(_vistoria.copyWith(motivos: lista));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _outroMotivo,
            minLines: 2,
            maxLines: 4,
            decoration: _dec('Complemento / outro motivo'),
            onChanged: (value) => _alterar(_vistoria.copyWith(outroMotivo: value)),
          ),
        ],
      );

  Widget _avarias() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalhoEtapa('Estado externo', 'Registre danos existentes antes do atendimento.', Icons.directions_car_outlined),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Toque em uma região do veículo para registrar a avaria.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  VehicleDamageMap(
                    danos: _vistoria.danos,
                    onRegionTap: (area) => _adicionarDano(areaInicial: area),
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _MapLegend(color: Colors.grey, label: 'Não verificado'),
                      _MapLegend(color: Colors.amber, label: 'Observação'),
                      _MapLegend(color: Colors.red, label: 'Avaria relevante'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _adicionarDano(),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Adicionar por lista de regiões'),
          ),
          const SizedBox(height: 8),
          if (_vistoria.danos.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma avaria registrada.'))),
          ...List.generate(_vistoria.danos.length, (index) {
            final dano = _vistoria.danos[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.warning_amber_rounded)),
                title: Text('${dano['area']} — ${dano['tipo']}'),
                subtitle: (dano['detalhe'] ?? '').isEmpty ? null : Text(dano['detalhe']!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final lista = [..._vistoria.danos]..removeAt(index);
                    _alterar(_vistoria.copyWith(danos: lista));
                  },
                ),
              ),
            );
          }),
        ],
      );

  Widget _pneusCombustivel() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalhoEtapa('Pneus e combustível', 'Verifique cada pneu e o nível do tanque.', Icons.tire_repair_outlined),
          ..._pneus.entries.map((entry) => Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.tire_repair_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.value)),
                      DropdownButton<String>(
                        value: _vistoria.pneus[entry.key],
                        hint: const Text('Verificar'),
                        items: const ['Bom', 'Regular', 'Ruim', 'Ausente', 'Não verificado']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          _alterar(_vistoria.copyWith(pneus: {..._vistoria.pneus, entry.key: value}));
                        },
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Text('Combustível: ${_vistoria.combustivel}%', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _vistoria.combustivel.toDouble(),
            min: 0,
            max: 100,
            divisions: 4,
            label: '${_vistoria.combustivel}%',
            onChanged: (value) => _alterar(_vistoria.copyWith(combustivel: value.round())),
          ),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Vazio'), Text('1/4'), Text('1/2'), Text('3/4'), Text('Cheio')]),
        ],
      );

  Widget _acessorios() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalhoEtapa('Acessórios', 'Marque a situação de cada item.', Icons.inventory_2_outlined),
          const Text('OK = presente e em bom estado • Ausente = não localizado • Avariado = incompleto ou danificado'),
          const SizedBox(height: 12),
          ..._gruposAcessorios.entries.map((grupo) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  initiallyExpanded: grupo.key == 'Segurança',
                  title: Text(grupo.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: grupo.value.map((item) {
                    final situacao = _vistoria.acessorios[item] ?? 'Não verificado';
                    return ListTile(
                      title: Text(item),
                      subtitle: Text(situacao),
                      trailing: PopupMenuButton<String>(
                        initialValue: situacao,
                        onSelected: (value) => _alterar(_vistoria.copyWith(acessorios: {..._vistoria.acessorios, item: value})),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'OK', child: Text('OK')),
                          PopupMenuItem(value: 'Ausente', child: Text('Ausente')),
                          PopupMenuItem(value: 'Avariado', child: Text('Avariado')),
                          PopupMenuItem(value: 'Não verificado', child: Text('Não verificado')),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      );

  Widget _finalizacao() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalhoEtapa('Finalização', 'Declarações, observações e responsáveis.', Icons.fact_check_outlined),
          CheckboxListTile(
            value: _vistoria.proprietarioOrientado,
            contentPadding: EdgeInsets.zero,
            title: const Text('O proprietário foi orientado a retirar os pertences do veículo.'),
            onChanged: (value) => _alterar(_vistoria.copyWith(proprietarioOrientado: value ?? false)),
          ),
          CheckboxListTile(
            value: _vistoria.patioCiente,
            contentPadding: EdgeInsets.zero,
            title: const Text('Ciente de que a permanência no pátio poderá gerar cobrança de diárias.'),
            onChanged: (value) => _alterar(_vistoria.copyWith(patioCiente: value ?? false)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observacoes,
            minLines: 3,
            maxLines: 6,
            decoration: _dec('Observações gerais'),
            onChanged: (value) => _alterar(_vistoria.copyWith(observacoes: value)),
          ),
          const SizedBox(height: 20),
          Text('Segurado ou beneficiário', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _seguradoNome, decoration: _dec('Nome'), onChanged: (v) => _alterar(_vistoria.copyWith(seguradoNome: v))),
          const SizedBox(height: 8),
          TextField(controller: _seguradoRg, decoration: _dec('RG'), onChanged: (v) => _alterar(_vistoria.copyWith(seguradoRg: v))),
          const SizedBox(height: 20),
          Text('Destinatário', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _destinatarioNome, decoration: _dec('Nome'), onChanged: (v) => _alterar(_vistoria.copyWith(destinatarioNome: v))),
          const SizedBox(height: 8),
          TextField(controller: _destinatarioRg, decoration: _dec('RG'), onChanged: (v) => _alterar(_vistoria.copyWith(destinatarioRg: v))),
          const SizedBox(height: 20),
          Text('Prestador', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _prestadorNome, decoration: _dec('Nome'), onChanged: (v) => _alterar(_vistoria.copyWith(prestadorNome: v))),
          const SizedBox(height: 8),
          TextField(controller: _prestadorRg, decoration: _dec('RG'), onChanged: (v) => _alterar(_vistoria.copyWith(prestadorRg: v))),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Progresso atual: $_itensPreenchidos de 9 grupos principais preenchidos.')),
                ],
              ),
            ),
          ),
        ],
      );

  List<Widget> get _paginas => [
        _identificacao(),
        _atendimento(),
        _avarias(),
        _pneusCombustivel(),
        _acessorios(),
        _finalizacao(),
      ];

  Future<void> _fecharTeclado() async {
    FocusManager.instance.primaryFocus?.unfocus();

    // Aguarda o Flutter concluir as notificações de foco e a retirada do
    // teclado antes de trocar ou remover a árvore atual de widgets.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _mudarEtapa(int novaEtapa) async {
    if (novaEtapa == _etapa) return;

    await _fecharTeclado();
    if (!mounted) return;

    setState(() => _etapa = novaEtapa);
  }

  Future<void> _concluir() async {
    await _fecharTeclado();
    if (!mounted) return;

    Navigator.of(context).pop(_vistoria);
  }

  @override
  Widget build(BuildContext context) {
    const titulos = ['Identificação', 'Atendimento', 'Avarias', 'Pneus', 'Acessórios', 'Finalização'];
    final progresso = (_etapa + 1) / titulos.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vistoria • OS ${widget.numeroOs}'),
        actions: [
          TextButton.icon(
            onPressed: _concluir,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(children: [Expanded(child: Text('${_etapa + 1}/${titulos.length} • ${titulos[_etapa]}')), Text('${(progresso * 100).round()}%')]),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progresso),
              ],
            ),
          ),
        ),
      ),
      body: KeyedSubtree(
        key: ValueKey<int>(_etapa),
        child: _paginas[_etapa],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _etapa == 0 ? null : () => _mudarEtapa(_etapa - 1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _etapa == titulos.length - 1
                      ? _concluir
                      : () => _mudarEtapa(_etapa + 1),
                  icon: Icon(_etapa == titulos.length - 1 ? Icons.check : Icons.arrow_forward),
                  label: Text(_etapa == titulos.length - 1 ? 'Concluir' : 'Próximo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

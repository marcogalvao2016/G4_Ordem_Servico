import 'package:flutter/material.dart';

import '../../models/configuracoes_gerais.dart';
import '../../repositories/configuracoes_gerais_repository.dart';

class ConfiguracoesGeraisScreen extends StatefulWidget {
  const ConfiguracoesGeraisScreen({super.key});

  @override
  State<ConfiguracoesGeraisScreen> createState() => _ConfiguracoesGeraisScreenState();
}

class _ConfiguracoesGeraisScreenState extends State<ConfiguracoesGeraisScreen> {
  final _repository = ConfiguracoesGeraisRepository();
  ConfiguracoesGerais? _config;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final config = await _repository.obter();
    if (!mounted) return;
    setState(() {
      _config = config;
      _carregando = false;
    });
  }

  void _alterar(ConfiguracoesGerais Function(ConfiguracoesGerais atual) alterar) {
    final atual = _config;
    if (atual == null || _salvando) return;
    setState(() => _config = alterar(atual));
  }

  Future<void> _salvar() async {
    final config = _config;
    if (config == null) return;
    setState(() => _salvando = true);
    try {
      await _repository.salvar(config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas. Elas serão mantidas ao reiniciar o app.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar as configurações: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _opcao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: CircleAvatar(child: Icon(icone)),
        title: Text(titulo),
        subtitle: Text(descricao),
        value: valor,
        onChanged: _salvando ? null : onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando || _config == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = _config!;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações gerais')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Escolha quais recursos serão exibidos na Ordem de Serviço.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _opcao(
            titulo: 'Manutenção Preventiva',
            descricao: 'Exibe o acesso ao plano e às manutenções executadas na OS.',
            icone: Icons.car_repair_outlined,
            valor: c.usarManutencaoPreventiva,
            onChanged: (v) => _alterar((a) => a.copyWith(usarManutencaoPreventiva: v)),
          ),
          _opcao(
            titulo: 'Status',
            descricao: 'Se desativado, o Status não aparece e toda OS salva será CONCLUÍDA.',
            icone: Icons.flag_outlined,
            valor: c.usarStatus,
            onChanged: (v) => _alterar((a) => a.copyWith(usarStatus: v)),
          ),
          _opcao(
            titulo: 'Diagnóstico',
            descricao: 'Exibe o campo Diagnóstico na Ordem de Serviço.',
            icone: Icons.search_outlined,
            valor: c.usarDiagnostico,
            onChanged: (v) => _alterar((a) => a.copyWith(usarDiagnostico: v)),
          ),
          _opcao(
            titulo: 'Solução aplicada',
            descricao: 'Exibe o campo Solução aplicada na Ordem de Serviço.',
            icone: Icons.build_outlined,
            valor: c.usarSolucaoAplicada,
            onChanged: (v) => _alterar((a) => a.copyWith(usarSolucaoAplicada: v)),
          ),
          _opcao(
            titulo: 'Fotos da Ordem de Serviço',
            descricao: 'Exibe a galeria de fotos da OS.',
            icone: Icons.photo_library_outlined,
            valor: c.usarFotosOs,
            onChanged: (v) => _alterar((a) => a.copyWith(usarFotosOs: v)),
          ),
          _opcao(
            titulo: 'Ficha de vistoria',
            descricao: 'Exibe a ficha de vistoria do veículo e seus comandos.',
            icone: Icons.fact_check_outlined,
            valor: c.usarFichaVistoria,
            onChanged: (v) => _alterar((a) => a.copyWith(usarFichaVistoria: v)),
          ),
          _opcao(
            titulo: 'Checklist',
            descricao: 'Exibe o checklist da Ordem de Serviço.',
            icone: Icons.checklist_outlined,
            valor: c.usarChecklist,
            onChanged: (v) => _alterar((a) => a.copyWith(usarChecklist: v)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _salvando ? null : _salvar,
            icon: const Icon(Icons.save_outlined),
            label: Text(_salvando ? 'Salvando...' : 'Salvar configurações'),
          ),
        ],
      ),
    );
  }
}

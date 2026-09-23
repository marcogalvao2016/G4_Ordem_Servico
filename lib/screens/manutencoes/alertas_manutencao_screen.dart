import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/alerta_manutencao.dart';
import '../../repositories/alerta_manutencao_repository.dart';

class AlertasManutencaoScreen extends StatefulWidget {
  const AlertasManutencaoScreen({super.key});

  @override
  State<AlertasManutencaoScreen> createState() => _AlertasManutencaoScreenState();
}

class _AlertasManutencaoScreenState extends State<AlertasManutencaoScreen> {
  final _repository = AlertaManutencaoRepository();
  List<AlertaManutencao> _alertas = <AlertaManutencao>[];
  bool _carregando = true;
  String _filtro = 'TODAS';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (mounted) setState(() => _carregando = true);
    final alertas = await _repository.listarAlertas();
    if (!mounted) return;
    setState(() {
      _alertas = alertas;
      _carregando = false;
    });
  }

  List<AlertaManutencao> get _filtrados {
    if (_filtro == 'TODAS') return _alertas;
    return _alertas.where((a) => a.situacao == _filtro).toList();
  }

  int _quantidade(String situacao) =>
      _alertas.where((a) => a.situacao == situacao).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Alertas de manutenção'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _ResumoAlertas(
                    vencidas: _quantidade('VENCIDA'),
                    proximas: _quantidade('PROXIMA'),
                    verificar: _quantidade('VERIFICAR'),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _chip('TODAS', 'Todas (${_alertas.length})'),
                        const SizedBox(width: 8),
                        _chip('VENCIDA', 'Vencidas (${_quantidade('VENCIDA')})'),
                        const SizedBox(width: 8),
                        _chip('PROXIMA', 'Próximas (${_quantidade('PROXIMA')})'),
                        const SizedBox(width: 8),
                        _chip('VERIFICAR', 'A verificar (${_quantidade('VERIFICAR')})'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_filtrados.isEmpty)
                    const _SemAlertas()
                  else
                    ..._filtrados.map((alerta) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AlertaCard(
                            alerta: alerta,
                            onContatar: () => _mostrarMensagem(alerta),
                          ),
                        )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _chip(String valor, String rotulo) {
    return ChoiceChip(
      label: Text(rotulo),
      selected: _filtro == valor,
      onSelected: (_) => setState(() => _filtro = valor),
    );
  }

  Future<void> _mostrarMensagem(AlertaManutencao alerta) async {
    final mensagem = _mensagemCliente(alerta);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mensagem sugerida ao cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if ((alerta.clienteTelefone ?? '').trim().isNotEmpty) ...<Widget>[
                Text(
                  'Telefone: ${alerta.clienteTelefone}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
              ],
              SelectableText(mensagem),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: mensagem));
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mensagem copiada. Pronta para enviar ao cliente.')),
              );
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copiar mensagem'),
          ),
        ],
      ),
    );
  }

  String _mensagemCliente(AlertaManutencao alerta) {
    final primeiroNome = alerta.clienteNome.trim().split(RegExp(r'\s+')).first;
    final veiculo = alerta.identificacaoVeiculo;
    final manutencao = _tituloNormal(alerta.manutencaoDescricao);

    if (alerta.situacao == 'VENCIDA') {
      return 'Olá, $primeiroNome! Tudo bem? Aqui é da oficina. '
          'Verificamos em nosso histórico que o seu $veiculo está no período recomendado para $manutencao. '
          '${alerta.resumoPrazo()}. Se desejar, podemos agendar uma verificação para você.';
    }
    if (alerta.situacao == 'PROXIMA') {
      return 'Olá, $primeiroNome! Tudo bem? Aqui é da oficina. '
          'Acompanhando o histórico do seu $veiculo, identificamos que está se aproximando o período de $manutencao. '
          '${alerta.resumoPrazo()}. Se desejar, podemos deixar uma revisão programada.';
    }
    return 'Olá, $primeiroNome! Tudo bem? Aqui é da oficina. '
        'Ao revisar o histórico do seu $veiculo, vimos que é importante verificar $manutencao. '
        'Não encontramos um registro recente dessa manutenção. Se você quiser, podemos conferir e orientar o melhor momento para realizá-la.';
  }

  String _tituloNormal(String valor) {
    if (valor.isEmpty) return valor;
    final baixo = valor.toLowerCase();
    return baixo[0].toUpperCase() + baixo.substring(1);
  }
}

class _ResumoAlertas extends StatelessWidget {
  const _ResumoAlertas({
    required this.vencidas,
    required this.proximas,
    required this.verificar,
  });

  final int vencidas;
  final int proximas;
  final int verificar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF8A2D2D), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.notifications_active_outlined, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MANUTENÇÕES QUE PRECISAM DE ATENÇÃO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$vencidas vencidas  •  $proximas próximas  •  $verificar a verificar',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'O G4 OS usa o histórico das manutenções, a última quilometragem conhecida e os intervalos cadastrados.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  const _AlertaCard({required this.alerta, required this.onContatar});

  final AlertaManutencao alerta;
  final VoidCallback onContatar;

  @override
  Widget build(BuildContext context) {
    final cor = _corSituacao(alerta.situacao);
    final ultima = alerta.status.ultimaExecucao;
    final subtitulos = <String>[
      alerta.identificacaoVeiculo,
      if (alerta.kmAtual != null) 'Última km conhecida: ${alerta.kmAtual} km',
      if (ultima != null)
        'Última execução: ${_data(ultima.dataExecucao)}${ultima.quilometragem == null ? '' : ' • ${ultima.quilometragem} km'}',
      alerta.resumoPrazo(),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cor.withValues(alpha: .28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: cor.withValues(alpha: .12),
                  child: Icon(_iconeSituacao(alerta.situacao), color: cor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(alerta.clienteNome, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(alerta.itemDescricao, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _rotuloSituacao(alerta.situacao),
                    style: TextStyle(color: cor, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: 26),
            Text(alerta.manutencaoDescricao, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            ...subtitulos.map((texto) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(texto),
                )),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onContatar,
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Contatar cliente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemAlertas extends StatelessWidget {
  const _SemAlertas();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(Icons.task_alt_outlined, size: 46, color: Color(0xFF16805D)),
            SizedBox(height: 10),
            Text(
              'Nenhuma manutenção requer atenção agora.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Os alertas aparecerão automaticamente conforme o histórico real de manutenções e a quilometragem registrada nas ordens de serviço.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Color _corSituacao(String situacao) {
  switch (situacao) {
    case 'VENCIDA':
      return const Color(0xFFB3261E);
    case 'PROXIMA':
      return const Color(0xFFD97706);
    case 'VERIFICAR':
      return const Color(0xFF3157A4);
    default:
      return Colors.grey;
  }
}

IconData _iconeSituacao(String situacao) {
  switch (situacao) {
    case 'VENCIDA':
      return Icons.error_outline;
    case 'PROXIMA':
      return Icons.schedule_outlined;
    case 'VERIFICAR':
      return Icons.help_outline;
    default:
      return Icons.notifications_none;
  }
}

String _rotuloSituacao(String situacao) {
  switch (situacao) {
    case 'VENCIDA':
      return 'VENCIDA';
    case 'PROXIMA':
      return 'PRÓXIMA';
    case 'VERIFICAR':
      return 'VERIFICAR';
    default:
      return situacao;
  }
}

String _data(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

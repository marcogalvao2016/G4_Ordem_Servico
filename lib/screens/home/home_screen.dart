import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/formatters.dart';
import '../../models/alerta_manutencao.dart';
import '../../models/dashboard_data.dart';
import '../../repositories/alerta_manutencao_repository.dart';
import '../../repositories/dashboard_repository.dart';
import '../clientes/clientes_screen.dart';
import '../empresa/empresa_form_screen.dart';
import '../itens/itens_screen.dart';
import '../login/login_screen.dart';
import '../manutencoes/alertas_manutencao_screen.dart';
import '../manutencoes/manutencoes_preventivas_screen.dart';
import '../ordens/ordens_screen.dart';
import '../produtos/produtos_screen.dart';
import '../servicos/servicos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dashboardRepository = DashboardRepository();
  final _alertaRepository = AlertaManutencaoRepository();
  late Future<DashboardData> _dashboardFuture;
  late Future<List<AlertaManutencao>> _alertasFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardRepository.carregar();
    _alertasFuture = _alertaRepository.listarAlertas();
  }

  void _atualizarDashboard() {
    setState(() {
      _dashboardFuture = _dashboardRepository.carregar();
      _alertasFuture = _alertaRepository.listarAlertas();
    });
  }

  Future<void> _abrirModulo(WidgetBuilder builder) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: builder),
    );
    if (mounted) _atualizarDashboard();
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await SessionManager.instance.clear();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance;
    final colorScheme = Theme.of(context).colorScheme;

    final modules = <_Module>[
      _Module(
        title: 'Clientes',
        subtitle: 'Cadastro e histórico',
        icon: Icons.people_alt_outlined,
        color: const Color(0xFF3157A4),
        builder: (_) => const ClientesScreen(),
      ),
      _Module(
        title: 'Itens',
        subtitle: 'Veículos e equipamentos',
        icon: Icons.directions_car_outlined,
        color: const Color(0xFF0F8B8D),
        builder: (_) => const ItensScreen(),
      ),
      _Module(
        title: 'Serviços',
        subtitle: 'Catálogo e valores',
        icon: Icons.build_outlined,
        color: const Color(0xFF7B4EA3),
        builder: (_) => const ServicosScreen(),
      ),
      _Module(
        title: 'Produtos',
        subtitle: 'Peças, óleos e acessórios',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF2E7D32),
        builder: (_) => const ProdutosScreen(),
      ),
      _Module(
        title: 'Manutenções',
        subtitle: 'Planos preventivos e intervalos',
        icon: Icons.car_repair_outlined,
        color: const Color(0xFF00695C),
        builder: (_) => const ManutencoesPreventivasScreen(),
      ),
      _Module(
        title: 'Ordens de Serviço',
        subtitle: 'Atendimentos e vistorias',
        icon: Icons.assignment_outlined,
        color: const Color(0xFFD97706),
        builder: (_) => const OrdensScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('G4 OS'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: <Widget>[
          IconButton(
            tooltip: 'Atualizar dashboard',
            onPressed: _atualizarDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _atualizarDashboard(),
        child: FutureBuilder<DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _WelcomeHeader(
                  usuario: session.usuarioNome ?? 'USUÁRIO',
                  perfil: session.perfil ?? '',
                  onEmpresa: () => _abrirModulo((_) => const EmpresaFormScreen()),
                ),
                const SizedBox(height: 14),
                FutureBuilder<List<AlertaManutencao>>(
                  future: _alertasFuture,
                  builder: (context, alertaSnapshot) {
                    if (alertaSnapshot.connectionState == ConnectionState.waiting) {
                      return const _AlertasHomeLoading();
                    }
                    if (alertaSnapshot.hasError) {
                      return _AlertasHomeError(onRetry: _atualizarDashboard);
                    }
                    return _AlertasHomeCard(
                      alertas: alertaSnapshot.data ?? const <AlertaManutencao>[],
                      onTap: () => _abrirModulo((_) => const AlertasManutencaoScreen()),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Acesso rápido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 2
                            : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: modules.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: columns == 1 ? 3.2 : 1.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return _ModuleCard(
                          module: module,
                          onTap: () => _abrirModulo(module.builder),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 22),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  _ErrorCard(
                    message: 'Não foi possível carregar o dashboard: ${snapshot.error}',
                    onRetry: _atualizarDashboard,
                  )
                else if (snapshot.hasData) ...<Widget>[
                  _ResumoCards(data: snapshot.data!),
                  const SizedBox(height: 18),
                  _OrdensTresMeses(data: snapshot.data!),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _ClientesRecentes(
                                clientes: snapshot.data!.clientesRecentes,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ItensRecentes(
                                itens: snapshot.data!.itensRecentes,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: <Widget>[
                          _ClientesRecentes(
                            clientes: snapshot.data!.clientesRecentes,
                          ),
                          const SizedBox(height: 16),
                          _ItensRecentes(
                            itens: snapshot.data!.itensRecentes,
                          ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}


class _AlertasHomeCard extends StatelessWidget {
  const _AlertasHomeCard({required this.alertas, required this.onTap});

  final List<AlertaManutencao> alertas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vencidas = alertas.where((a) => a.situacao == 'VENCIDA').length;
    final proximas = alertas.where((a) => a.situacao == 'PROXIMA').length;
    final verificar = alertas.where((a) => a.situacao == 'VERIFICAR').length;
    final temAlertas = alertas.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: temAlertas
                        ? const Color(0xFFFFE8E4)
                        : const Color(0xFFE6F4EA),
                    child: Icon(
                      temAlertas ? Icons.notifications_active_outlined : Icons.task_alt_outlined,
                      color: temAlertas ? const Color(0xFFB3261E) : const Color(0xFF16805D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'ALERTAS DE MANUTENÇÃO PREVENTIVA',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          temAlertas
                              ? '$vencidas vencidas • $proximas próximas • $verificar a verificar'
                              : 'Nenhuma manutenção exige atenção agora',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (temAlertas) ...<Widget>[
                const Divider(height: 24),
                ...alertas.take(3).map((alerta) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: _corAlertaHome(alerta.situacao),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: '${alerta.clienteNome} • ${alerta.itemDescricao}\n',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  TextSpan(
                                    text: '${alerta.manutencaoDescricao} — ${alerta.resumoPrazo()}',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (alertas.length > 3)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '+ ${alertas.length - 3} outros alertas',
                      style: const TextStyle(color: Color(0xFF3157A4), fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertasHomeLoading extends StatelessWidget {
  const _AlertasHomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Expanded(child: Text('Verificando manutenções preventivas...')),
          ],
        ),
      ),
    );
  }
}

class _AlertasHomeError extends StatelessWidget {
  const _AlertasHomeError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: const Text('Não foi possível verificar os alertas de manutenção.'),
        trailing: IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
      ),
    );
  }
}

Color _corAlertaHome(String situacao) {
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

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.usuario,
    required this.perfil,
    required this.onEmpresa,
  });

  final String usuario;
  final String perfil;
  final VoidCallback onEmpresa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF263B80), Color(0xFF4C6BC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33263B80),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'BEM-VINDO AO G4 OS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (perfil.trim().isNotEmpty)
                  Text(
                    perfil.toUpperCase(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: onEmpresa,
                    icon: const Icon(Icons.business_outlined, size: 18),
                    label: const Text('Cadastrar empresa'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF263B80),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.analytics_outlined, color: Colors.white, size: 38),
        ],
      ),
    );
  }
}

class _ResumoCards extends StatelessWidget {
  const _ResumoCards({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final cards = <_SummaryInfo>[
      _SummaryInfo('OS NO PERÍODO', '${data.totalOrdens}', Icons.assignment_outlined, const Color(0xFF3157A4)),
      _SummaryInfo('EM ANDAMENTO', '${data.ordensAbertas}', Icons.pending_actions_outlined, const Color(0xFFD97706)),
      _SummaryInfo('CONCLUÍDAS', '${data.ordensConcluidas}', Icons.task_alt_outlined, const Color(0xFF16805D)),
      _SummaryInfo('VALOR TOTAL', formatCurrency(data.valorPeriodo), Icons.payments_outlined, const Color(0xFF7B4EA3)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 4 ? 1.8 : 1.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, index) => _SummaryCard(info: cards[index]),
        );
      },
    );
  }
}

class _OrdensTresMeses extends StatelessWidget {
  const _OrdensTresMeses({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.meses.fold<int>(1, (max, mes) => mes.quantidade > max ? mes.quantidade : max);

    return _SectionCard(
      title: 'ORDENS DOS ÚLTIMOS 3 MESES',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: data.meses.map((mes) {
          final progress = mes.quantidade / maxValue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 72,
                  child: Text(
                    mes.rotulo,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 16,
                      backgroundColor: const Color(0xFFE4E9F3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4C6BC7)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${mes.quantidade} OS',
                    style: const TextStyle(
                      color: Color(0xFF3157A4),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ClientesRecentes extends StatelessWidget {
  const _ClientesRecentes({required this.clientes});

  final List<DashboardClienteRecente> clientes;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ÚLTIMOS CLIENTES ATENDIDOS',
      icon: Icons.people_alt_outlined,
      child: clientes.isEmpty
          ? const _EmptyDashboard(text: 'AINDA NÃO HÁ CLIENTES ATENDIDOS.')
          : Column(
              children: clientes.map((cliente) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE8EEFF),
                  child: Text(
                    cliente.nome.isEmpty ? '?' : cliente.nome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF3157A4), fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(cliente.nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('OS ${cliente.numeroOs.toString().padLeft(6, '0')} • ${_formatDate(cliente.dataAtendimento)}'),
                trailing: const Icon(Icons.chevron_right),
              )).toList(),
            ),
    );
  }
}

class _ItensRecentes extends StatelessWidget {
  const _ItensRecentes({required this.itens});

  final List<DashboardItemRecente> itens;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ÚLTIMOS VEÍCULOS / ITENS',
      icon: Icons.directions_car_outlined,
      child: itens.isEmpty
          ? const _EmptyDashboard(text: 'AINDA NÃO HÁ VEÍCULOS ATENDIDOS.')
          : Column(
              children: itens.map((item) {
                final identificacao = <String>[
                  if ((item.placa ?? '').trim().isNotEmpty) item.placa!,
                  if ((item.marca ?? '').trim().isNotEmpty) item.marca!,
                  if ((item.modelo ?? '').trim().isNotEmpty) item.modelo!,
                ].join(' • ');
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE1F4F2),
                    child: Icon(Icons.directions_car_outlined, color: Color(0xFF0F8B8D)),
                  ),
                  title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    '${identificacao.isEmpty ? item.tipo : identificacao}\n${item.clienteNome} • OS ${item.numeroOs.toString().padLeft(6, '0')}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                );
              }).toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x120E1B3D), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: const Color(0xFF3157A4)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .2)),
              ),
            ],
          ),
          const Divider(height: 28),
          child,
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final _Module module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(module.icon, color: module.color, size: 29),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(module.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(module.subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: module.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.info});

  final _SummaryInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: info.color, width: 5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x100E1B3D), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(info.icon, color: info.color),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(info.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: info.color)),
          ),
          const SizedBox(height: 3),
          Text(info.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('TENTAR NOVAMENTE')),
        ],
      ),
    ),
  );
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Center(child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700))),
  );
}

class _Module {
  const _Module({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _SummaryInfo {
  const _SummaryInfo(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

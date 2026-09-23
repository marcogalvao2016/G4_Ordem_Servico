class DashboardMes {
  const DashboardMes({
    required this.chave,
    required this.rotulo,
    required this.quantidade,
    required this.valor,
  });

  final String chave;
  final String rotulo;
  final int quantidade;
  final double valor;
}

class DashboardClienteRecente {
  const DashboardClienteRecente({
    required this.uuid,
    required this.nome,
    this.telefone,
    required this.numeroOs,
    required this.dataAtendimento,
  });

  final String uuid;
  final String nome;
  final String? telefone;
  final int numeroOs;
  final DateTime dataAtendimento;
}

class DashboardItemRecente {
  const DashboardItemRecente({
    required this.uuid,
    required this.descricao,
    required this.tipo,
    this.placa,
    this.marca,
    this.modelo,
    required this.clienteNome,
    required this.numeroOs,
    required this.dataAtendimento,
  });

  final String uuid;
  final String descricao;
  final String tipo;
  final String? placa;
  final String? marca;
  final String? modelo;
  final String clienteNome;
  final int numeroOs;
  final DateTime dataAtendimento;
}

class DashboardData {
  const DashboardData({
    required this.meses,
    required this.clientesRecentes,
    required this.itensRecentes,
    required this.totalOrdens,
    required this.ordensAbertas,
    required this.ordensConcluidas,
    required this.valorPeriodo,
  });

  final List<DashboardMes> meses;
  final List<DashboardClienteRecente> clientesRecentes;
  final List<DashboardItemRecente> itensRecentes;
  final int totalOrdens;
  final int ordensAbertas;
  final int ordensConcluidas;
  final double valorPeriodo;
}

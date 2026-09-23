import 'manutencao_preventiva.dart';

class AlertaManutencao {
  const AlertaManutencao({
    required this.clienteUuid,
    required this.clienteNome,
    this.clienteTelefone,
    required this.itemUuid,
    required this.itemDescricao,
    this.marca,
    this.modelo,
    this.placa,
    required this.status,
    required this.kmAtual,
    required this.situacao,
  });

  final String clienteUuid;
  final String clienteNome;
  final String? clienteTelefone;
  final String itemUuid;
  final String itemDescricao;
  final String? marca;
  final String? modelo;
  final String? placa;
  final ManutencaoVeiculoStatus status;
  final int? kmAtual;
  final String situacao;

  String get manutencaoDescricao => status.manutencao.descricao;

  int? get proximaKm => status.proximaKm();
  DateTime? get proximaData => status.proximaData();

  int? get kmVencidos {
    final proxima = proximaKm;
    if (proxima == null || kmAtual == null || kmAtual! < proxima) return null;
    return kmAtual! - proxima;
  }

  int? get kmRestantes {
    final proxima = proximaKm;
    if (proxima == null || kmAtual == null || kmAtual! >= proxima) return null;
    return proxima - kmAtual!;
  }

  String get identificacaoVeiculo {
    final partes = <String>[
      if ((marca ?? '').trim().isNotEmpty) marca!.trim(),
      if ((modelo ?? '').trim().isNotEmpty) modelo!.trim(),
      if ((placa ?? '').trim().isNotEmpty) placa!.trim(),
    ];
    if (partes.isNotEmpty) return partes.join(' • ');
    return itemDescricao;
  }

  String resumoPrazo({DateTime? hoje}) {
    final dataHoje = hoje ?? DateTime.now();
    if (situacao == 'VENCIDA') {
      if (kmVencidos != null && kmVencidos! > 0) {
        return 'Vencida há ${kmVencidos!} km';
      }
      final data = proximaData;
      if (data != null && !dataHoje.isBefore(data)) {
        final dias = dataHoje.difference(data).inDays;
        return dias == 0 ? 'Vence hoje' : 'Vencida há $dias dias';
      }
      return 'Manutenção vencida';
    }

    if (situacao == 'PROXIMA') {
      if (kmRestantes != null) return 'Faltam ${kmRestantes!} km';
      final data = proximaData;
      if (data != null) {
        final dias = data.difference(dataHoje).inDays;
        if (dias <= 0) return 'Vence hoje';
        return 'Prazo em $dias dias';
      }
      return 'Próxima do vencimento';
    }

    if (situacao == 'VERIFICAR') {
      return 'Sem histórico suficiente — verificar com o cliente';
    }
    return situacao;
  }
}

class ChecklistStageTemplate {
  const ChecklistStageTemplate({
    required this.id,
    required this.titulo,
    required this.descricao,
  });

  final String id;
  final String titulo;
  final String descricao;
}

class ChecklistAccessoryGroup {
  const ChecklistAccessoryGroup({
    required this.nome,
    required this.itens,
  });

  final String nome;
  final List<String> itens;
}

class ChecklistTemplate {
  const ChecklistTemplate({
    required this.uuid,
    required this.nome,
    required this.segmento,
    required this.etapas,
    required this.tiposAtendimento,
    required this.motivos,
    required this.pneus,
    required this.gruposAcessorios,
  });

  final String uuid;
  final String nome;
  final String segmento;
  final List<ChecklistStageTemplate> etapas;
  final List<String> tiposAtendimento;
  final List<String> motivos;
  final Map<String, String> pneus;
  final List<ChecklistAccessoryGroup> gruposAcessorios;
}

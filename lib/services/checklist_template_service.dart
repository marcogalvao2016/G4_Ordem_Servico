import '../models/checklist_template.dart';

class ChecklistTemplateService {
  ChecklistTemplateService._();

  static const ChecklistTemplate veiculoLeve = ChecklistTemplate(
    uuid: 'template-veiculo-leve-v1',
    nome: 'Veículo leve',
    segmento: 'Automotivo',
    etapas: <ChecklistStageTemplate>[
      ChecklistStageTemplate(
        id: 'resumo',
        titulo: 'Resumo',
        descricao: 'Visão geral do preenchimento da vistoria.',
      ),
      ChecklistStageTemplate(
        id: 'identificacao',
        titulo: 'Identificação',
        descricao: 'Dados do atendimento e do veículo.',
      ),
      ChecklistStageTemplate(
        id: 'atendimento',
        titulo: 'Atendimento',
        descricao: 'Tipo de serviço e motivo da chamada.',
      ),
      ChecklistStageTemplate(
        id: 'avarias',
        titulo: 'Avarias',
        descricao: 'Condições externas e danos existentes.',
      ),
      ChecklistStageTemplate(
        id: 'pneus',
        titulo: 'Pneus',
        descricao: 'Pneus, estepe e combustível.',
      ),
      ChecklistStageTemplate(
        id: 'acessorios',
        titulo: 'Acessórios',
        descricao: 'Itens internos, externos e de segurança.',
      ),
      ChecklistStageTemplate(
        id: 'finalizacao',
        titulo: 'Finalização',
        descricao: 'Declarações, responsáveis e observações.',
      ),
    ],
    tiposAtendimento: <String>[
      'Remoção',
      'Socorro mecânico',
      'Troca de pneu',
      'Carga de bateria',
      'Chaveiro',
      'Outro',
    ],
    motivos: <String>[
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
    ],
    pneus: <String, String>{
      'dianteiro_esquerdo': 'Dianteiro esquerdo',
      'dianteiro_direito': 'Dianteiro direito',
      'traseiro_esquerdo': 'Traseiro esquerdo',
      'traseiro_direito': 'Traseiro direito',
      'estepe': 'Estepe',
    },
    gruposAcessorios: <ChecklistAccessoryGroup>[
      ChecklistAccessoryGroup(
        nome: 'Segurança',
        itens: <String>['Triângulo', 'Macaco', 'Chave de roda', 'Extintor', 'Estepe'],
      ),
      ChecklistAccessoryGroup(
        nome: 'Interior',
        itens: <String>['Rádio', 'Manual', 'Documentos', 'Tapetes', 'Acendedor'],
      ),
      ChecklistAccessoryGroup(
        nome: 'Elétrica',
        itens: <String>['Faróis', 'Lanternas', 'Luz de freio', 'Pisca-alerta', 'Buzina'],
      ),
      ChecklistAccessoryGroup(
        nome: 'Exterior',
        itens: <String>['Retrovisores', 'Para-choques', 'Rodas', 'Calotas', 'Antena'],
      ),
    ],
  );

  static List<ChecklistTemplate> get modelosDisponiveis => const <ChecklistTemplate>[
        veiculoLeve,
      ];
}

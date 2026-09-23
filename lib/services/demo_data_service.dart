import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../core/database/database_service.dart';
import '../core/session/session_manager.dart';
import '../repositories/manutencao_preventiva_repository.dart';

class DemoDataResumo {
  const DemoDataResumo({
    required this.clientes,
    required this.itens,
    required this.servicos,
    required this.produtos,
    required this.ordens,
  });

  final int clientes;
  final int itens;
  final int servicos;
  final int produtos;
  final int ordens;
}

class DemoDataService {
  static const _prefixo = 'demo-full-';

  Future<Database> get _db => DatabaseService.instance.database;
  String get _empresaUuid => SessionManager.instance.requireEmpresaUuid();

  Future<DemoDataResumo> criarCargaCompleta() async {
    await ManutencaoPreventivaRepository().garantirPadroes();
    final db = await _db;
    final agora = DateTime.now();
    final isoAgora = agora.toIso8601String();

    final clientes = <Map<String, Object?>>[
      _cliente('gabriel', 'GABRIEL ALMEIDA', 'F', '418.762.930-15', '(15) 99745-2180', 'gabriel.almeida@exemplo.com', '18200-110', 'RUA DAS ACÁCIAS', '184', 'CASA', 'JARDIM PRIMAVERA', 'ITAPETININGA', 'SP', 'CLIENTE FICTÍCIO. PREFERE CONTATO POR WHATSAPP.'),
      _cliente('mariana', 'MARIANA COSTA FERREIRA', 'F', '527.184.360-02', '(15) 99612-4038', 'mariana.ferreira@exemplo.com', '18207-340', 'AVENIDA PEIXOTO GOMIDE', '927', 'APTO 34', 'CENTRO', 'ITAPETININGA', 'SP', 'CLIENTE FICTÍCIA. VEÍCULO UTILIZADO DIARIAMENTE EM RODOVIA.'),
      _cliente('ricardo', 'RICARDO HENRIQUE SOUZA', 'F', '306.945.178-44', '(15) 99830-7741', 'ricardo.souza@exemplo.com', '18270-000', 'RUA PROFESSOR JÚLIO PRESTES', '512', null, 'CENTRO', 'SÃO MIGUEL ARCANJO', 'SP', 'CLIENTE FICTÍCIO. SOLICITA ORÇAMENTO ANTES DE QUALQUER SERVIÇO ADICIONAL.'),
      _cliente('patricia', 'PATRÍCIA MENDES BARBOSA', 'F', '684.230.591-70', '(15) 99711-9082', 'patricia.barbosa@exemplo.com', '18211-420', 'RUA JOÃO EVANGELISTA', '73', null, 'VILA NOVA', 'ITAPETININGA', 'SP', 'CLIENTE FICTÍCIA. MANUTENÇÕES PREVENTIVAS SEMPRE AGENDADAS.'),
      _cliente('joao', 'JOÃO PEDRO MARTINS', 'F', '158.904.672-36', '(15) 99164-2250', 'joao.martins@exemplo.com', '18213-090', 'RUA FRANCISCO VÁLIO', '1440', 'FUNDOS', 'VILA RIO BRANCO', 'ITAPETININGA', 'SP', 'CLIENTE FICTÍCIO. VEÍCULO DE USO COMERCIAL.'),
      _cliente('agrovale', 'AGROVALE IMPLEMENTOS LTDA', 'J', '47.218.639/0001-52', '(15) 3272-8450', 'manutencao@agrovale-exemplo.com.br', '18270-000', 'RODOVIA SP-139', 'KM 171', 'GALPÃO 2', 'ZONA RURAL', 'SÃO MIGUEL ARCANJO', 'SP', 'EMPRESA FICTÍCIA PARA DEMONSTRAÇÃO DE CLIENTE PESSOA JURÍDICA.'),
      _cliente('mercado', 'MERCADO BOM PREÇO LTDA', 'J', '31.804.756/0001-09', '(15) 3275-3100', 'financeiro@bompreco-exemplo.com.br', '18200-005', 'RUA CAMPOS SALES', '321', null, 'CENTRO', 'ITAPETININGA', 'SP', 'EMPRESA FICTÍCIA. FROTA DE ENTREGA LOCAL.'),
      _cliente('ana', 'ANA LÚCIA RIBEIRO', 'F', '742.519.038-21', '(15) 99655-1844', 'ana.ribeiro@exemplo.com', '18204-610', 'RUA JOSÉ DE ALMEIDA CARVALHO', '118', null, 'JARDIM MARABÁ', 'ITAPETININGA', 'SP', 'CLIENTE FICTÍCIA. HISTÓRICO COMPLETO DE REVISÕES NO APP.'),
    ];

    final itens = <Map<String, Object?>>[
      _item('uno', 'gabriel', 'VEICULO', 'FIAT UNO 1.0', 'FIAT', 'UNO ATTRACTIVE 1.0', '9BD195A4ZG0812345', 'FTR4A21', '2015/2016', 'PRATA', 'VEÍCULO FICTÍCIO. PNEUS 175/65 R14.'),
      _item('onix', 'mariana', 'VEICULO', 'CHEVROLET ONIX 1.0 TURBO', 'CHEVROLET', 'ONIX PREMIER', '9BGKS48U0PG123456', 'GAB7C32', '2022/2023', 'BRANCO', 'VEÍCULO FICTÍCIO. REVISÕES PERIÓDICAS EM DIA.'),
      _item('gol', 'ricardo', 'VEICULO', 'VOLKSWAGEN GOL 1.6', 'VOLKSWAGEN', 'GOL MSI', '9BWAB45U5JT654321', 'EZX9H11', '2018/2019', 'VERMELHO', 'VEÍCULO FICTÍCIO. UTILIZAÇÃO MISTA CIDADE/ESTRADA.'),
      _item('corolla', 'patricia', 'VEICULO', 'TOYOTA COROLLA 2.0', 'TOYOTA', 'COROLLA XEI', '9BRBD3HE6N0123456', 'FQA2D88', '2021/2022', 'PRETO', 'VEÍCULO FICTÍCIO. CLIENTE MANTÉM MANUTENÇÃO PREVENTIVA RIGOROSA.'),
      _item('strada', 'joao', 'VEICULO', 'FIAT STRADA 1.3', 'FIAT', 'STRADA FREEDOM CS', '9BD281A3ZM0123456', 'GBH5J90', '2021/2021', 'BRANCO', 'VEÍCULO FICTÍCIO DE USO COMERCIAL E CARGA LEVE.'),
      _item('trator', 'agrovale', 'MAQUINA_AGRICOLA', 'TRATOR MASSEY FERGUSON MF 4275', 'MASSEY FERGUSON', 'MF 4275', 'MF4275-DEMO-2020-84', null, '2020', 'VERMELHO', 'MÁQUINA AGRÍCOLA FICTÍCIA. HORÍMETRO CONTROLADO NAS OBSERVAÇÕES DAS OS.'),
      _item('saveiro', 'mercado', 'VEICULO', 'VOLKSWAGEN SAVEIRO 1.6', 'VOLKSWAGEN', 'SAVEIRO ROBUST', '9BWKB45U8NP123456', 'FVN6K44', '2022/2022', 'BRANCO', 'VEÍCULO FICTÍCIO PARA ENTREGAS URBANAS.'),
      _item('hb20', 'ana', 'VEICULO', 'HYUNDAI HB20 1.0', 'HYUNDAI', 'HB20 COMFORT', '9BHBG51CAKP123456', 'EZR3A67', '2019/2020', 'CINZA', 'VEÍCULO FICTÍCIO. USO PREDOMINANTEMENTE URBANO.'),
      _item('compressor', 'agrovale', 'EQUIPAMENTO', 'COMPRESSOR DE AR 15 PÉS', 'SCHULZ', 'MSV 15/175', 'SCHULZ-DEMO-88731', null, '2021', 'AZUL', 'EQUIPAMENTO FICTÍCIO DA OFICINA DA EMPRESA.'),
    ];

    final servicos = <Map<String, Object?>>[
      _servico('oleo', 'TROCA DE ÓLEO E FILTRO', 120.00, 'MÃO DE OBRA PARA TROCA DE ÓLEO DO MOTOR E FILTRO.'),
      _servico('revisao', 'REVISÃO PREVENTIVA COMPLETA', 350.00, 'INSPEÇÃO DE FREIOS, SUSPENSÃO, FLUIDOS, CORREIAS E SISTEMA ELÉTRICO.'),
      _servico('freio', 'SUBSTITUIÇÃO DE PASTILHAS DE FREIO', 180.00, 'SERVIÇO POR EIXO. NÃO INCLUI PEÇAS.'),
      _servico('alinhamento', 'ALINHAMENTO DE DIREÇÃO', 90.00, 'ALINHAMENTO COMPUTADORIZADO DO EIXO DIANTEIRO.'),
      _servico('balanceamento', 'BALANCEAMENTO DE RODAS', 25.00, 'VALOR UNITÁRIO POR RODA.'),
      _servico('injecao', 'DIAGNÓSTICO ELETRÔNICO / INJEÇÃO', 150.00, 'LEITURA DE FALHAS, PARÂMETROS E TESTES BÁSICOS.'),
      _servico('correia', 'TROCA DE KIT CORREIA DENTADA', 420.00, 'MÃO DE OBRA PARA CORREIA, TENSOR E INSPEÇÃO DA BOMBA D\'ÁGUA.'),
      _servico('suspensao', 'REVISÃO DE SUSPENSÃO', 190.00, 'INSPEÇÃO DE AMORTECEDORES, BUCHAS, PIVÔS E TERMINAIS.'),
      _servico('ar', 'HIGIENIZAÇÃO DO AR-CONDICIONADO', 140.00, 'HIGIENIZAÇÃO E SUBSTITUIÇÃO DO FILTRO QUANDO CONTRATADO.'),
      _servico('bateria', 'TESTE DE BATERIA E ALTERNADOR', 60.00, 'TESTE DE CARGA, PARTIDA E TENSÃO DO ALTERNADOR.'),
      _servico('eletrica', 'REPARO ELÉTRICO', 185.00, 'VALOR BASE DE MÃO DE OBRA, AJUSTÁVEL CONFORME DIAGNÓSTICO.'),
      _servico('equipamento', 'MANUTENÇÃO EM EQUIPAMENTO', 260.00, 'MANUTENÇÃO GERAL EM EQUIPAMENTOS E MÁQUINAS.'),
    ];

    final produtos = <Map<String, Object?>>[
      _produto('oleo5w30', 900001, 'ÓLEO MOTOR 5W30 SINTÉTICO 1L', 'LT', 52.90, '27101932', '500', '5405'),
      _produto('oleo10w40', 900002, 'ÓLEO MOTOR 10W40 SEMISSINTÉTICO 1L', 'LT', 39.90, '27101932', '500', '5405'),
      _produto('filtro-oleo', 900003, 'FILTRO DE ÓLEO MOTOR', 'UN', 34.50, '84212300', '500', '5405'),
      _produto('filtro-ar', 900004, 'FILTRO DE AR DO MOTOR', 'UN', 48.90, '84213100', '500', '5405'),
      _produto('filtro-cabine', 900005, 'FILTRO DE CABINE / AR-CONDICIONADO', 'UN', 42.00, '84213990', '500', '5405'),
      _produto('pastilha', 900006, 'JOGO DE PASTILHAS DE FREIO DIANTEIRAS', 'JG', 189.00, '87083019', '500', '5405'),
      _produto('fluido-freio', 900007, 'FLUIDO DE FREIO DOT 4 500ML', 'UN', 36.90, '38190000', '500', '5405'),
      _produto('aditivo', 900008, 'ADITIVO PARA RADIADOR LONG LIFE 1L', 'LT', 31.50, '38200000', '500', '5405'),
      _produto('correia-kit', 900009, 'KIT CORREIA DENTADA + TENSOR', 'KT', 329.90, '40103500', '500', '5405'),
      _produto('correia-alt', 900010, 'CORREIA DO ALTERNADOR', 'UN', 89.00, '40103900', '500', '5405'),
      _produto('vela', 900011, 'JOGO DE VELAS DE IGNIÇÃO', 'JG', 124.00, '85111000', '500', '5405'),
      _produto('bateria', 900012, 'BATERIA AUTOMOTIVA 60AH', 'UN', 579.00, '85071010', '500', '5405'),
      _produto('amortecedor', 900013, 'PAR AMORTECEDOR DIANTEIRO', 'PR', 698.00, '87088000', '500', '5405'),
      _produto('bieleta', 900014, 'BIELETA DA BARRA ESTABILIZADORA', 'UN', 79.90, '87088000', '500', '5405'),
      _produto('lampada', 900015, 'LÂMPADA FAROL H7 12V 55W', 'UN', 34.90, '85392110', '500', '5405'),
      _produto('limpa', 900016, 'PALHETA LIMPADOR DIANTEIRO', 'JG', 74.90, '85124010', '500', '5405'),
      _produto('graxa', 900017, 'GRAXA MULTIUSO 500G', 'UN', 28.50, '27101999', '500', '5405'),
      _produto('filtro-diesel', 900018, 'FILTRO DE COMBUSTÍVEL DIESEL', 'UN', 118.00, '84212300', '500', '5405'),
      _produto('oleo-hidraulico', 900019, 'ÓLEO HIDRÁULICO ISO 68 20L', 'BD', 389.00, '27101932', '500', '5405'),
      _produto('rele', 900020, 'RELÉ AUTOMOTIVO 12V 40A', 'UN', 29.90, '85364100', '500', '5405'),
    ];

    await db.transaction((txn) async {
      for (final row in clientes) {
        await txn.insert('clientes', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final row in itens) {
        await txn.insert('itens', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final row in servicos) {
        await txn.insert('servicos', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final row in produtos) {
        await txn.insert('produtos', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      final manutencoes = await txn.query(
        'manutencoes_preventivas',
        columns: <String>['uuid', 'descricao'],
        where: 'empresa_uuid = ? AND excluido = 0',
        whereArgs: <Object?>[_empresaUuid],
      );
      final manutPorDescricao = <String, String>{
        for (final row in manutencoes)
          (row['descricao'] as String).toUpperCase(): row['uuid'] as String,
      };

      final maxNumero = Sqflite.firstIntValue(await txn.rawQuery(
            'SELECT MAX(numero_os) FROM ordens_servico WHERE empresa_uuid = ?',
            <Object?>[_empresaUuid],
          )) ??
          0;

      final ordens = _ordens(agora, maxNumero + 1);
      for (final os in ordens) {
        final ordemUuid = os.uuid;
        await txn.insert(
          'ordens_servico',
          <String, Object?>{
            'uuid': ordemUuid,
            'empresa_uuid': _empresaUuid,
            'numero_os': os.numero,
            'cliente_uuid': _uuidCliente(os.cliente),
            'item_uuid': _uuidItem(os.item),
            'servico_uuid': os.servicos.isEmpty ? null : _uuidServico(os.servicos.first.id),
            'status': os.status,
            'descricao_problema': os.problema,
            'diagnostico': os.diagnostico,
            'solucao': os.solucao,
            'valor_total': os.total,
            'km_atual': os.km,
            'data_abertura': os.abertura.toIso8601String(),
            'data_conclusao': os.conclusao?.toIso8601String(),
            'criado_em': os.abertura.toIso8601String(),
            'atualizado_em': isoAgora,
            'sincronizado': 0,
            'excluido': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        for (var i = 0; i < os.servicos.length; i++) {
          final s = os.servicos[i];
          await txn.insert(
            'os_servicos',
            <String, Object?>{
              'uuid': '${ordemUuid}-srv-${i + 1}',
              'empresa_uuid': _empresaUuid,
              'ordem_uuid': ordemUuid,
              'servico_uuid': _uuidServico(s.id),
              'descricao': s.descricao,
              'quantidade': s.quantidade,
              'valor_unitario': s.valorUnitario,
              'desconto': s.desconto,
              'valor_total': s.total,
              'observacao': s.observacao,
              'ordem': i,
              'criado_em': os.abertura.toIso8601String(),
              'atualizado_em': isoAgora,
              'sincronizado': 0,
              'excluido': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        for (var i = 0; i < os.produtos.length; i++) {
          final p = os.produtos[i];
          final cadastro = produtos.firstWhere((e) => e['uuid'] == _uuidProduto(p.id));
          await txn.insert(
            'os_produtos',
            <String, Object?>{
              'uuid': '${ordemUuid}-prd-${i + 1}',
              'empresa_uuid': _empresaUuid,
              'ordem_uuid': ordemUuid,
              'produto_uuid': _uuidProduto(p.id),
              'codigo_produto': cadastro['codigo'],
              'descricao': cadastro['descricao'],
              'unidade': cadastro['unidade'],
              'ncm': cadastro['ncm'],
              'csosn': cadastro['csosn'],
              'cfop': cadastro['cfop'],
              'quantidade': p.quantidade,
              'valor_unitario': p.valorUnitario,
              'valor_total': p.total,
              'ordem': i,
              'criado_em': os.abertura.toIso8601String(),
              'atualizado_em': isoAgora,
              'sincronizado': 0,
              'excluido': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        for (var i = 0; i < os.checklist.length; i++) {
          final c = os.checklist[i];
          await txn.insert(
            'os_checklist',
            <String, Object?>{
              'uuid': '${ordemUuid}-chk-${i + 1}',
              'empresa_uuid': _empresaUuid,
              'ordem_uuid': ordemUuid,
              'descricao': c.descricao,
              'concluido': c.concluido ? 1 : 0,
              'observacao': c.observacao,
              'ordem': i,
              'criado_em': os.abertura.toIso8601String(),
              'atualizado_em': isoAgora,
              'sincronizado': 0,
              'excluido': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        if (os.vistoria != null) {
          final v = os.vistoria!;
          await txn.insert(
            'os_vistoria_veiculo',
            <String, Object?>{
              'uuid': '${ordemUuid}-vistoria',
              'empresa_uuid': _empresaUuid,
              'ordem_uuid': ordemUuid,
              'nome_motorista': v.motorista,
              'local': v.local,
              'destino': v.destino,
              'km': os.km?.toString() ?? '',
              'tipos_atendimento_json': jsonEncode(v.tipos),
              'motivos_json': jsonEncode(v.motivos),
              'outro_motivo': v.outroMotivo,
              'danos_json': jsonEncode(v.danos),
              'pneus_json': jsonEncode(v.pneus),
              'combustivel': v.combustivel,
              'acessorios_json': jsonEncode(v.acessorios),
              'proprietario_orientado': v.proprietarioOrientado ? 1 : 0,
              'patio_ciente': v.patioCiente ? 1 : 0,
              'observacoes': v.observacoes,
              'segurado_nome': v.seguradoNome,
              'segurado_rg': v.seguradoRg,
              'segurado_assinatura': v.seguradoAssinatura,
              'destinatario_nome': v.destinatarioNome,
              'destinatario_rg': v.destinatarioRg,
              'destinatario_assinatura': v.destinatarioAssinatura,
              'prestador_nome': v.prestadorNome,
              'prestador_rg': v.prestadorRg,
              'prestador_assinatura': v.prestadorAssinatura,
              'criado_em': os.abertura.toIso8601String(),
              'atualizado_em': isoAgora,
              'sincronizado': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        for (var i = 0; i < os.manutencoes.length; i++) {
          final nome = os.manutencoes[i].toUpperCase();
          final manutUuid = manutPorDescricao[nome];
          if (manutUuid == null) continue;
          await txn.insert(
            'manutencao_execucoes',
            <String, Object?>{
              'uuid': '${ordemUuid}-mnt-${i + 1}',
              'empresa_uuid': _empresaUuid,
              'item_uuid': _uuidItem(os.item),
              'manutencao_uuid': manutUuid,
              'ordem_uuid': ordemUuid,
              'quilometragem': os.km,
              'data_execucao': (os.conclusao ?? os.abertura).toIso8601String(),
              'observacao': 'EXECUÇÃO FICTÍCIA REGISTRADA PELA CARGA DE DEMONSTRAÇÃO.',
              'criado_em': os.abertura.toIso8601String(),
              'atualizado_em': isoAgora,
              'sincronizado': 0,
              'excluido': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });

    return DemoDataResumo(
      clientes: clientes.length,
      itens: itens.length,
      servicos: servicos.length,
      produtos: produtos.length,
      ordens: _ordens(agora, 1).length,
    );
  }

  Future<void> removerCargaCompleta() async {
    final db = await _db;
    await db.transaction((txn) async {
      final osRows = await txn.query(
        'ordens_servico',
        columns: <String>['uuid'],
        where: 'empresa_uuid = ? AND uuid LIKE ?',
        whereArgs: <Object?>[_empresaUuid, '$_prefixo%'],
      );
      final osUuids = osRows.map((e) => e['uuid'] as String).toList();
      for (final uuid in osUuids) {
        await txn.delete('manutencao_execucoes', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
        await txn.delete('os_fotos', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
        await txn.delete('os_vistoria_veiculo', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
        await txn.delete('os_checklist', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
        await txn.delete('os_produtos', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
        await txn.delete('os_servicos', where: 'empresa_uuid = ? AND ordem_uuid = ?', whereArgs: <Object?>[_empresaUuid, uuid]);
      }
      await txn.delete('ordens_servico', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
      await txn.delete('manutencao_execucoes', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
      await txn.delete('itens', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
      await txn.delete('clientes', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
      await txn.delete('servicos', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
      await txn.delete('produtos', where: 'empresa_uuid = ? AND uuid LIKE ?', whereArgs: <Object?>[_empresaUuid, '$_prefixo%']);
    });
  }

  Map<String, Object?> _cliente(
    String id,
    String nome,
    String tipo,
    String documento,
    String telefone,
    String email,
    String cep,
    String logradouro,
    String numero,
    String? complemento,
    String bairro,
    String cidade,
    String uf,
    String observacoes,
  ) {
    final agora = DateTime.now().toIso8601String();
    return <String, Object?>{
      'uuid': _uuidCliente(id),
      'empresa_uuid': _empresaUuid,
      'nome': nome,
      'tipo_pessoa': tipo,
      'cpf_cnpj': documento,
      'telefone': telefone,
      'email': email,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'observacoes': observacoes,
      'criado_em': agora,
      'atualizado_em': agora,
      'sincronizado': 0,
      'excluido': 0,
    };
  }

  Map<String, Object?> _item(
    String id,
    String cliente,
    String tipo,
    String descricao,
    String marca,
    String modelo,
    String? numeroSerie,
    String? placa,
    String ano,
    String cor,
    String observacoes,
  ) {
    final agora = DateTime.now().toIso8601String();
    return <String, Object?>{
      'uuid': _uuidItem(id),
      'empresa_uuid': _empresaUuid,
      'cliente_uuid': _uuidCliente(cliente),
      'tipo': tipo,
      'descricao': descricao,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'placa': placa,
      'ano': ano,
      'cor': cor,
      'observacoes': observacoes,
      'criado_em': agora,
      'atualizado_em': agora,
      'sincronizado': 0,
      'excluido': 0,
    };
  }

  Map<String, Object?> _servico(String id, String descricao, double valor, String observacoes) {
    final agora = DateTime.now().toIso8601String();
    return <String, Object?>{
      'uuid': _uuidServico(id),
      'empresa_uuid': _empresaUuid,
      'descricao': descricao,
      'valor_padrao': valor,
      'observacoes': observacoes,
      'criado_em': agora,
      'atualizado_em': agora,
      'sincronizado': 0,
      'excluido': 0,
    };
  }

  Map<String, Object?> _produto(
    String id,
    int codigo,
    String descricao,
    String unidade,
    double valor,
    String ncm,
    String csosn,
    String cfop,
  ) {
    final agora = DateTime.now().toIso8601String();
    return <String, Object?>{
      'uuid': _uuidProduto(id),
      'empresa_uuid': _empresaUuid,
      'codigo': codigo,
      'descricao': descricao,
      'unidade': unidade,
      'valor_venda': valor,
      'ncm': ncm,
      'csosn': csosn,
      'cfop': cfop,
      'criado_em': agora,
      'atualizado_em': agora,
      'sincronizado': 0,
      'excluido': 0,
    };
  }

  List<_DemoOrdem> _ordens(DateTime agora, int numeroInicial) {
    final ordens = <_DemoOrdem>[
      _DemoOrdem(
        id: 'os01', numero: numeroInicial, cliente: 'gabriel', item: 'uno', status: 'CONCLUIDA', km: 72700,
        abertura: agora.subtract(const Duration(days: 330)), conclusao: agora.subtract(const Duration(days: 329)),
        problema: 'CLIENTE RELATA QUE O VEÍCULO ATINGIU A QUILOMETRAGEM PROGRAMADA PARA REVISÃO E TROCA DE ÓLEO.',
        diagnostico: 'ÓLEO DO MOTOR ESCURECIDO, FILTRO SATURADO E FILTRO DE AR COM ACÚMULO MODERADO DE POEIRA.',
        solucao: 'REALIZADA TROCA DE ÓLEO, FILTRO DE ÓLEO, FILTRO DE AR E INSPEÇÃO GERAL.',
        servicos: const [
          _DemoServicoOs('oleo', 'TROCA DE ÓLEO E FILTRO', 1, 120, 0, 'ÓLEO E FILTROS SUBSTITUÍDOS.'),
          _DemoServicoOs('revisao', 'REVISÃO PREVENTIVA COMPLETA', 1, 350, 50, 'DESCONTO COMERCIAL DE DEMONSTRAÇÃO.'),
        ],
        produtos: const [
          _DemoProdutoOs('oleo10w40', 3.5, 39.90),
          _DemoProdutoOs('filtro-oleo', 1, 34.50),
          _DemoProdutoOs('filtro-ar', 1, 48.90),
        ],
        checklist: const [
          _DemoChecklist('NÍVEL DO ÓLEO DO MOTOR', true, 'NORMAL APÓS SUBSTITUIÇÃO.'),
          _DemoChecklist('SISTEMA DE ARREFECIMENTO', true, 'SEM VAZAMENTOS.'),
          _DemoChecklist('PNEUS E CALIBRAGEM', true, 'CALIBRADOS CONFORME RECOMENDAÇÃO.'),
          _DemoChecklist('ILUMINAÇÃO E SINALIZAÇÃO', true, 'FUNCIONAMENTO NORMAL.'),
        ],
        manutencoes: const ['TROCA DE ÓLEO E FILTRO DE ÓLEO', 'FILTRO DE AR DO MOTOR'],
      ),
      _DemoOrdem(
        id: 'os02', numero: numeroInicial + 1, cliente: 'mariana', item: 'onix', status: 'CONCLUIDA', km: 38620,
        abertura: agora.subtract(const Duration(days: 62)), conclusao: agora.subtract(const Duration(days: 61)),
        problema: 'RUÍDO LEVE AO FREAR E PEDAL COM SENSAÇÃO DIFERENTE EM BAIXA VELOCIDADE.',
        diagnostico: 'PASTILHAS DIANTEIRAS PRÓXIMAS DO LIMITE E FLUIDO DE FREIO COM TEMPO DE USO ELEVADO.',
        solucao: 'SUBSTITUÍDAS PASTILHAS DIANTEIRAS E FLUIDO DE FREIO. SISTEMA SANGRADO E TESTADO.',
        servicos: const [
          _DemoServicoOs('freio', 'SUBSTITUIÇÃO DE PASTILHAS DE FREIO', 1, 180, 0, 'EIXO DIANTEIRO.'),
          _DemoServicoOs('revisao', 'REVISÃO PREVENTIVA COMPLETA', 1, 350, 0, 'FOCO NO SISTEMA DE FREIOS.'),
        ],
        produtos: const [
          _DemoProdutoOs('pastilha', 1, 189.00),
          _DemoProdutoOs('fluido-freio', 2, 36.90),
        ],
        checklist: const [
          _DemoChecklist('PASTILHAS DE FREIO', true, 'SUBSTITUÍDAS.'),
          _DemoChecklist('DISCOS DE FREIO', true, 'DENTRO DA ESPESSURA DE SERVIÇO.'),
          _DemoChecklist('FLUIDO DE FREIO', true, 'SUBSTITUÍDO.'),
          _DemoChecklist('FREIO DE ESTACIONAMENTO', true, 'REGULAGEM NORMAL.'),
        ],
        manutencoes: const ['PASTILHAS E DISCOS DE FREIO', 'FLUIDO DE FREIO DOT 3/4', 'VERIFICAÇÃO DO FREIO DE MÃO'],
        vistoria: const _DemoVistoria(
          motorista: 'MARIANA COSTA FERREIRA', local: 'OFICINA G4 DEMONSTRAÇÃO', destino: 'BOX 02',
          tipos: ['REVISÃO', 'MANUTENÇÃO PREVENTIVA'], motivos: ['RUÍDO', 'REVISÃO PROGRAMADA'], outroMotivo: '',
          danos: [{'tipo': 'RISCO', 'local': 'PARA-CHOQUE TRASEIRO DIREITO', 'observacao': 'RISCO LEVE PRÉ-EXISTENTE'}],
          pneus: {'DIANTEIRO ESQUERDO': 'BOM', 'DIANTEIRO DIREITO': 'BOM', 'TRASEIRO ESQUERDO': 'BOM', 'TRASEIRO DIREITO': 'BOM'},
          combustivel: 58,
          acessorios: {'MACACO': 'SIM', 'TRIÂNGULO': 'SIM', 'CHAVE DE RODA': 'SIM', 'ESTEPE': 'SIM'},
          proprietarioOrientado: true, patioCiente: true,
          observacoes: 'VISTORIA FICTÍCIA PARA DEMONSTRAÇÃO. VEÍCULO ENTREGUE COM OBJETOS PESSOAIS NO PORTA-LUVAS.',
          seguradoNome: 'MARIANA COSTA FERREIRA', seguradoRg: '48.732.190-8', seguradoAssinatura: 'ASSINATURA DEMO',
          destinatarioNome: 'CARLOS MECÂNICO', destinatarioRg: '32.184.772-1', destinatarioAssinatura: 'ASSINATURA DEMO',
          prestadorNome: 'OFICINA G4 DEMONSTRAÇÃO', prestadorRg: 'RESPONSÁVEL DEMO', prestadorAssinatura: 'ASSINATURA DEMO',
        ),
      ),
      _DemoOrdem(
        id: 'os03', numero: numeroInicial + 2, cliente: 'ricardo', item: 'gol', status: 'EM_EXECUCAO', km: 91840,
        abertura: agora.subtract(const Duration(days: 2)), conclusao: null,
        problema: 'MOTOR APRESENTA OSCILAÇÃO EM MARCHA LENTA E AUMENTO DE CONSUMO.',
        diagnostico: 'FALHA INTERMITENTE DE IGNIÇÃO E VELAS COM DESGASTE. LIMPEZA DO SISTEMA DE ALIMENTAÇÃO RECOMENDADA.',
        solucao: 'SERVIÇO EM EXECUÇÃO. AGUARDANDO FINALIZAÇÃO DOS TESTES APÓS SUBSTITUIÇÃO DAS VELAS.',
        servicos: const [
          _DemoServicoOs('injecao', 'DIAGNÓSTICO ELETRÔNICO / INJEÇÃO', 1, 150, 0, 'SCANNER APONTOU FALHA DE COMBUSTÃO INTERMITENTE.'),
          _DemoServicoOs('revisao', 'REVISÃO PREVENTIVA COMPLETA', 1, 350, 0, 'REVISÃO ASSOCIADA AO DIAGNÓSTICO.'),
        ],
        produtos: const [_DemoProdutoOs('vela', 1, 124.00), _DemoProdutoOs('filtro-ar', 1, 48.90)],
        checklist: const [
          _DemoChecklist('LEITURA COM SCANNER', true, 'CÓDIGOS DE FALHA REGISTRADOS.'),
          _DemoChecklist('VELAS DE IGNIÇÃO', true, 'DESGASTE ACENTUADO.'),
          _DemoChecklist('BICOS INJETORES', false, 'TESTE AINDA EM EXECUÇÃO.'),
          _DemoChecklist('TESTE DE RODAGEM', false, 'PENDENTE APÓS MONTAGEM.'),
        ],
      ),
      _DemoOrdem(
        id: 'os04', numero: numeroInicial + 3, cliente: 'patricia', item: 'corolla', status: 'AGUARDANDO_APROVACAO', km: 64120,
        abertura: agora.subtract(const Duration(days: 1)), conclusao: null,
        problema: 'CLIENTE SOLICITA REVISÃO DE 60 MIL KM E ORÇAMENTO ANTES DA EXECUÇÃO.',
        diagnostico: 'AMORTECEDORES DIANTEIROS COM INÍCIO DE VAZAMENTO E BIELETAS COM FOLGA. DEMAIS ITENS EM BOM ESTADO.',
        solucao: 'ORÇAMENTO ENVIADO AO CLIENTE. AGUARDANDO APROVAÇÃO PARA SUBSTITUIÇÃO DAS PEÇAS.',
        servicos: const [
          _DemoServicoOs('suspensao', 'REVISÃO DE SUSPENSÃO', 1, 190, 0, 'DIAGNÓSTICO COMPLETO REALIZADO.'),
          _DemoServicoOs('alinhamento', 'ALINHAMENTO DE DIREÇÃO', 1, 90, 0, 'PROGRAMADO APÓS TROCA DOS COMPONENTES.'),
        ],
        produtos: const [_DemoProdutoOs('amortecedor', 1, 698.00), _DemoProdutoOs('bieleta', 2, 79.90)],
        checklist: const [
          _DemoChecklist('AMORTECEDORES', true, 'VAZAMENTO LEVE NOS DIANTEIROS.'),
          _DemoChecklist('BUCHAS DA SUSPENSÃO', true, 'SEM TRINCAS RELEVANTES.'),
          _DemoChecklist('BIELETAS', true, 'FOLGA IDENTIFICADA.'),
          _DemoChecklist('APROVAÇÃO DO CLIENTE', false, 'AGUARDANDO RETORNO.'),
        ],
        vistoria: const _DemoVistoria(
          motorista: 'PATRÍCIA MENDES BARBOSA', local: 'RECEPÇÃO', destino: 'BOX 01',
          tipos: ['ORÇAMENTO', 'REVISÃO'], motivos: ['MANUTENÇÃO PREVENTIVA'], outroMotivo: '',
          danos: [],
          pneus: {'DIANTEIRO ESQUERDO': 'MEIA-VIDA', 'DIANTEIRO DIREITO': 'MEIA-VIDA', 'TRASEIRO ESQUERDO': 'BOM', 'TRASEIRO DIREITO': 'BOM'},
          combustivel: 75,
          acessorios: {'MACACO': 'SIM', 'TRIÂNGULO': 'SIM', 'CHAVE DE RODA': 'SIM', 'ESTEPE': 'SIM'},
          proprietarioOrientado: true, patioCiente: true,
          observacoes: 'SEM AVARIAS EXTERNAS RELEVANTES NA ENTRADA.',
          seguradoNome: 'PATRÍCIA MENDES BARBOSA', seguradoRg: '44.310.987-2', seguradoAssinatura: 'ASSINATURA DEMO',
          destinatarioNome: 'RECEPÇÃO G4', destinatarioRg: 'DEMO', destinatarioAssinatura: 'ASSINATURA DEMO',
          prestadorNome: 'OFICINA G4 DEMONSTRAÇÃO', prestadorRg: 'RESPONSÁVEL DEMO', prestadorAssinatura: 'ASSINATURA DEMO',
        ),
      ),
      _DemoOrdem(
        id: 'os05', numero: numeroInicial + 4, cliente: 'joao', item: 'strada', status: 'ABERTA', km: 108530,
        abertura: agora.subtract(const Duration(hours: 7)), conclusao: null,
        problema: 'BARULHO NA DIANTEIRA AO PASSAR EM DESNÍVEIS E VIBRAÇÃO ACIMA DE 90 KM/H.',
        diagnostico: 'AGUARDANDO INSPEÇÃO COMPLETA DA SUSPENSÃO E RODAS.',
        solucao: 'SERVIÇO AINDA NÃO INICIADO.',
        servicos: const [_DemoServicoOs('suspensao', 'REVISÃO DE SUSPENSÃO', 1, 190, 0, 'DIAGNÓSTICO INICIAL PROGRAMADO.')],
        produtos: const [],
        checklist: const [
          _DemoChecklist('RECEPÇÃO DO VEÍCULO', true, 'VEÍCULO RECEBIDO.'),
          _DemoChecklist('INSPEÇÃO DE SUSPENSÃO', false, 'PENDENTE.'),
          _DemoChecklist('BALANCEAMENTO', false, 'PENDENTE APÓS INSPEÇÃO.'),
        ],
      ),
      _DemoOrdem(
        id: 'os06', numero: numeroInicial + 5, cliente: 'agrovale', item: 'trator', status: 'CONCLUIDA', km: 4820,
        abertura: agora.subtract(const Duration(days: 35)), conclusao: agora.subtract(const Duration(days: 33)),
        problema: 'MANUTENÇÃO PROGRAMADA DO TRATOR E VERIFICAÇÃO DE VAZAMENTO NO CIRCUITO HIDRÁULICO.',
        diagnostico: 'FILTRO DIESEL SATURADO, ÓLEO HIDRÁULICO COM NÍVEL BAIXO E CONEXÃO COM PEQUENO VAZAMENTO.',
        solucao: 'SUBSTITUÍDO FILTRO, COMPLETADO ÓLEO HIDRÁULICO, REAPERTO DE CONEXÕES E LUBRIFICAÇÃO GERAL.',
        servicos: const [_DemoServicoOs('equipamento', 'MANUTENÇÃO EM EQUIPAMENTO', 2, 260, 40, 'DUAS HORAS TÉCNICAS COM DESCONTO.')],
        produtos: const [_DemoProdutoOs('filtro-diesel', 1, 118.00), _DemoProdutoOs('oleo-hidraulico', 1, 389.00), _DemoProdutoOs('graxa', 2, 28.50)],
        checklist: const [
          _DemoChecklist('SISTEMA HIDRÁULICO', true, 'VAZAMENTO SANADO.'),
          _DemoChecklist('FILTRO DE COMBUSTÍVEL', true, 'SUBSTITUÍDO.'),
          _DemoChecklist('LUBRIFICAÇÃO DOS PONTOS', true, 'EXECUTADA.'),
          _DemoChecklist('TESTE OPERACIONAL', true, 'FUNCIONAMENTO NORMAL.'),
        ],
      ),
      _DemoOrdem(
        id: 'os07', numero: numeroInicial + 6, cliente: 'mercado', item: 'saveiro', status: 'CONCLUIDA', km: 51210,
        abertura: agora.subtract(const Duration(days: 18)), conclusao: agora.subtract(const Duration(days: 17)),
        problema: 'FAROL DIANTEIRO DIREITO NÃO ACENDE E BATERIA APRESENTOU PARTIDA LENTA PELA MANHÃ.',
        diagnostico: 'LÂMPADA H7 QUEIMADA. BATERIA APROVADA NO TESTE, ALTERNADOR CARREGANDO NORMALMENTE.',
        solucao: 'SUBSTITUÍDA LÂMPADA E REALIZADO TESTE DE BATERIA/ALTERNADOR.',
        servicos: const [_DemoServicoOs('bateria', 'TESTE DE BATERIA E ALTERNADOR', 1, 60, 0, 'BATERIA APROVADA.'), _DemoServicoOs('eletrica', 'REPARO ELÉTRICO', 1, 185, 85, 'DESCONTO POR SERVIÇO SIMPLES DE ILUMINAÇÃO.')],
        produtos: const [_DemoProdutoOs('lampada', 1, 34.90)],
        checklist: const [_DemoChecklist('FARÓIS', true, 'LÂMPADA SUBSTITUÍDA.'), _DemoChecklist('BATERIA', true, 'TESTE APROVADO.'), _DemoChecklist('ALTERNADOR', true, '14,2 V EM CARGA.')],
        manutencoes: const ['TESTE DE CARGA DA BATERIA', 'TERMINAIS DA BATERIA / CONEXÕES ELÉTRICAS'],
      ),
      _DemoOrdem(
        id: 'os08', numero: numeroInicial + 7, cliente: 'ana', item: 'hb20', status: 'CONCLUIDA', km: 74850,
        abertura: agora.subtract(const Duration(days: 88)), conclusao: agora.subtract(const Duration(days: 87)),
        problema: 'REVISÃO PROGRAMADA, TROCA DE ÓLEO E HIGIENIZAÇÃO DO AR-CONDICIONADO.',
        diagnostico: 'FILTRO DE CABINE SATURADO. DEMAIS ITENS SEM ANORMALIDADES IMPORTANTES.',
        solucao: 'TROCA DE ÓLEO/FILTRO, FILTRO DE CABINE E HIGIENIZAÇÃO DO SISTEMA.',
        servicos: const [_DemoServicoOs('oleo', 'TROCA DE ÓLEO E FILTRO', 1, 120, 0, null), _DemoServicoOs('ar', 'HIGIENIZAÇÃO DO AR-CONDICIONADO', 1, 140, 0, null)],
        produtos: const [_DemoProdutoOs('oleo5w30', 3.5, 52.90), _DemoProdutoOs('filtro-oleo', 1, 34.50), _DemoProdutoOs('filtro-cabine', 1, 42.00)],
        checklist: const [_DemoChecklist('ÓLEO DO MOTOR', true, 'SUBSTITUÍDO.'), _DemoChecklist('FILTRO DE CABINE', true, 'SUBSTITUÍDO.'), _DemoChecklist('AR-CONDICIONADO', true, 'HIGIENIZADO.')],
        manutencoes: const ['TROCA DE ÓLEO E FILTRO DE ÓLEO', 'FILTRO DO AR-CONDICIONADO (CABINE)'],
      ),
      _DemoOrdem(
        id: 'os09', numero: numeroInicial + 8, cliente: 'gabriel', item: 'uno', status: 'CONCLUIDA', km: 83450,
        abertura: agora.subtract(const Duration(days: 3)), conclusao: agora.subtract(const Duration(days: 2)),
        problema: 'REVISÃO PREVENTIVA. CLIENTE RELATA PEQUENO RUÍDO DE CORREIA NA PARTIDA A FRIO.',
        diagnostico: 'CORREIA DE ACESSÓRIOS RESSECADA. ÓLEO DO MOTOR NO LIMITE DE QUILOMETRAGEM PROGRAMADA.',
        solucao: 'SUBSTITUÍDA CORREIA DE ACESSÓRIOS. TROCA DE ÓLEO RECOMENDADA PARA O PRÓXIMO RETORNO.',
        servicos: const [_DemoServicoOs('revisao', 'REVISÃO PREVENTIVA COMPLETA', 1, 350, 0, 'AVALIAÇÃO COMPLETA DO VEÍCULO.')],
        produtos: const [_DemoProdutoOs('correia-alt', 1, 89.00)],
        checklist: const [_DemoChecklist('CORREIA DE ACESSÓRIOS', true, 'SUBSTITUÍDA.'), _DemoChecklist('CORREIA DENTADA', true, 'HISTÓRICO DE TROCA NÃO LOCALIZADO - ORIENTADO VERIFICAR.'), _DemoChecklist('ÓLEO DO MOTOR', true, 'PRÓXIMO DA TROCA.')],
        manutencoes: const ['CORREIA DO ALTERNADOR / ACESSÓRIOS'],
        vistoria: const _DemoVistoria(
          motorista: 'GABRIEL ALMEIDA', local: 'RECEPÇÃO', destino: 'BOX 03', tipos: ['REVISÃO'], motivos: ['RUÍDO', 'MANUTENÇÃO PREVENTIVA'], outroMotivo: '',
          danos: [{'tipo': 'AMASSADO', 'local': 'PORTA DIANTEIRA ESQUERDA', 'observacao': 'PEQUENO AMASSADO PRÉ-EXISTENTE'}],
          pneus: {'DIANTEIRO ESQUERDO': 'MEIA-VIDA', 'DIANTEIRO DIREITO': 'MEIA-VIDA', 'TRASEIRO ESQUERDO': 'BOM', 'TRASEIRO DIREITO': 'BOM'},
          combustivel: 32, acessorios: {'MACACO': 'SIM', 'TRIÂNGULO': 'SIM', 'CHAVE DE RODA': 'SIM', 'ESTEPE': 'SIM'},
          proprietarioOrientado: true, patioCiente: true, observacoes: 'CLIENTE ORIENTADO SOBRE HISTÓRICO DA CORREIA DENTADA.',
          seguradoNome: 'GABRIEL ALMEIDA', seguradoRg: '40.812.551-3', seguradoAssinatura: 'ASSINATURA DEMO',
          destinatarioNome: 'RECEPÇÃO G4', destinatarioRg: 'DEMO', destinatarioAssinatura: 'ASSINATURA DEMO',
          prestadorNome: 'OFICINA G4 DEMONSTRAÇÃO', prestadorRg: 'RESPONSÁVEL DEMO', prestadorAssinatura: 'ASSINATURA DEMO',
        ),
      ),
      _DemoOrdem(
        id: 'os10', numero: numeroInicial + 9, cliente: 'mariana', item: 'onix', status: 'EM_ANALISE', km: 42180,
        abertura: agora.subtract(const Duration(hours: 20)), conclusao: null,
        problema: 'LUZ DE INJEÇÃO ACENDEU DUAS VEZES EM ULTRAPASSAGEM, SEM PERDA PERMANENTE DE POTÊNCIA.',
        diagnostico: 'VEÍCULO EM ANÁLISE. SCANNER REGISTROU CÓDIGO INTERMITENTE A SER CONFIRMADO EM TESTE DINÂMICO.',
        solucao: 'AGUARDANDO TESTE DE RODAGEM E NOVA LEITURA DO SISTEMA.',
        servicos: const [_DemoServicoOs('injecao', 'DIAGNÓSTICO ELETRÔNICO / INJEÇÃO', 1, 150, 0, 'EM ANDAMENTO.')],
        produtos: const [],
        checklist: const [_DemoChecklist('LEITURA INICIAL DO SCANNER', true, 'CONCLUÍDA.'), _DemoChecklist('TESTE DE RODAGEM', false, 'PENDENTE.'), _DemoChecklist('NOVA LEITURA APÓS TESTE', false, 'PENDENTE.')],
      ),
      _DemoOrdem(
        id: 'os11', numero: numeroInicial + 10, cliente: 'ricardo', item: 'gol', status: 'CANCELADA', km: 90310,
        abertura: agora.subtract(const Duration(days: 12)), conclusao: agora.subtract(const Duration(days: 11)),
        problema: 'SOLICITADA TROCA PREVENTIVA DO KIT DE CORREIA DENTADA.',
        diagnostico: 'SERVIÇO ORÇADO. CLIENTE INFORMOU QUE REALIZARIA O SERVIÇO EM OUTRA DATA.',
        solucao: 'ORDEM CANCELADA A PEDIDO DO CLIENTE. NENHUMA PEÇA SUBSTITUÍDA.',
        servicos: const [_DemoServicoOs('correia', 'TROCA DE KIT CORREIA DENTADA', 1, 420, 0, 'NÃO EXECUTADO - OS CANCELADA.')],
        produtos: const [_DemoProdutoOs('correia-kit', 1, 329.90)],
        checklist: const [_DemoChecklist('ORÇAMENTO APRESENTADO', true, 'CLIENTE CIENTE.'), _DemoChecklist('SERVIÇO AUTORIZADO', false, 'NÃO AUTORIZADO.')],
      ),
      _DemoOrdem(
        id: 'os12', numero: numeroInicial + 11, cliente: 'agrovale', item: 'compressor', status: 'CONCLUIDA', km: null,
        abertura: agora.subtract(const Duration(days: 46)), conclusao: agora.subtract(const Duration(days: 45)),
        problema: 'COMPRESSOR DEMORA PARA ENCHER O RESERVATÓRIO E APRESENTA PEQUENO VAZAMENTO NA LINHA.',
        diagnostico: 'CONEXÃO DE SAÍDA COM VEDAÇÃO DANIFICADA E FILTRO DE ADMISSÃO SUJO.',
        solucao: 'VEDAÇÃO SUBSTITUÍDA, FILTRO LIMPO E TESTE DE PRESSÃO REALIZADO COM SUCESSO.',
        servicos: const [_DemoServicoOs('equipamento', 'MANUTENÇÃO EM EQUIPAMENTO', 1.5, 260, 0, 'MANUTENÇÃO MECÂNICA E TESTE DE PRESSÃO.')],
        produtos: const [],
        checklist: const [_DemoChecklist('TESTE DE VAZAMENTO', true, 'SEM VAZAMENTO APÓS REPARO.'), _DemoChecklist('PRESSÃO DE CORTE', true, 'DENTRO DO ESPERADO.'), _DemoChecklist('LIMPEZA GERAL', true, 'EXECUTADA.')],
      ),
      _DemoOrdem(
        id: 'os13', numero: numeroInicial + 12, cliente: 'joao', item: 'strada', status: 'CONCLUIDA', km: 99200,
        abertura: agora.subtract(const Duration(days: 73)), conclusao: agora.subtract(const Duration(days: 72)),
        problema: 'REVISÃO DE ROTINA, ALINHAMENTO E BALANCEAMENTO DEVIDO A DESGASTE IRREGULAR DOS PNEUS.',
        diagnostico: 'CONVERGÊNCIA FORA DA ESPECIFICAÇÃO E RODAS DIANTEIRAS COM DESBALANCEAMENTO.',
        solucao: 'ALINHAMENTO E BALANCEAMENTO DAS QUATRO RODAS REALIZADOS. PNEUS ROTACIONADOS.',
        servicos: const [_DemoServicoOs('alinhamento', 'ALINHAMENTO DE DIREÇÃO', 1, 90, 0, null), _DemoServicoOs('balanceamento', 'BALANCEAMENTO DE RODAS', 4, 25, 0, null)],
        produtos: const [],
        checklist: const [_DemoChecklist('ALINHAMENTO', true, 'AJUSTADO.'), _DemoChecklist('BALANCEAMENTO', true, 'QUATRO RODAS.'), _DemoChecklist('ROTAÇÃO DOS PNEUS', true, 'REALIZADA.')],
        manutencoes: const ['ALINHAMENTO E BALANCEAMENTO', 'ROTAÇÃO DOS PNEUS'],
      ),
      _DemoOrdem(
        id: 'os14', numero: numeroInicial + 13, cliente: 'ana', item: 'hb20', status: 'CONCLUIDA', km: 80450,
        abertura: agora.subtract(const Duration(days: 9)), conclusao: agora.subtract(const Duration(days: 8)),
        problema: 'REVISÃO DOS 80 MIL KM E VERIFICAÇÃO DO SISTEMA DE ARREFECIMENTO.',
        diagnostico: 'LÍQUIDO DE ARREFECIMENTO COM PRAZO DE SUBSTITUIÇÃO ATINGIDO. DEMAIS ITENS NORMAIS.',
        solucao: 'REALIZADA SUBSTITUIÇÃO DO LÍQUIDO DE ARREFECIMENTO E TESTE DE ESTANQUEIDADE.',
        servicos: const [_DemoServicoOs('revisao', 'REVISÃO PREVENTIVA COMPLETA', 1, 350, 0, 'REVISÃO DOS 80 MIL KM.')],
        produtos: const [_DemoProdutoOs('aditivo', 4, 31.50)],
        checklist: const [_DemoChecklist('SISTEMA DE ARREFECIMENTO', true, 'FLUIDO SUBSTITUÍDO.'), _DemoChecklist('MANGUEIRAS E ABRAÇADEIRAS', true, 'SEM VAZAMENTOS.'), _DemoChecklist('VENTOINHA', true, 'ACIONAMENTO NORMAL.')],
        manutencoes: const ['LÍQUIDO DE ARREFECIMENTO'],
      ),
    ];

    return ordens;
  }

  String _uuidCliente(String id) => '${_prefixo}cliente-$id-g4os';
  String _uuidItem(String id) => '${_prefixo}item-$id-g4os';
  String _uuidServico(String id) => '${_prefixo}servico-$id-g4os';
  String _uuidProduto(String id) => '${_prefixo}produto-$id-g4os';
}

class _DemoOrdem {
  const _DemoOrdem({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.item,
    required this.status,
    required this.km,
    required this.abertura,
    required this.conclusao,
    required this.problema,
    required this.diagnostico,
    required this.solucao,
    required this.servicos,
    required this.produtos,
    required this.checklist,
    this.manutencoes = const <String>[],
    this.vistoria,
  });

  final String id;
  final int numero;
  final String cliente;
  final String item;
  final String status;
  final int? km;
  final DateTime abertura;
  final DateTime? conclusao;
  final String problema;
  final String diagnostico;
  final String solucao;
  final List<_DemoServicoOs> servicos;
  final List<_DemoProdutoOs> produtos;
  final List<_DemoChecklist> checklist;
  final List<String> manutencoes;
  final _DemoVistoria? vistoria;

  String get uuid => 'demo-full-$id-g4os';
  double get total =>
      servicos.fold<double>(0, (soma, item) => soma + item.total) +
      produtos.fold<double>(0, (soma, item) => soma + item.total);
}

class _DemoServicoOs {
  const _DemoServicoOs(this.id, this.descricao, this.quantidade, this.valorUnitario, this.desconto, this.observacao);
  final String id;
  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double desconto;
  final String? observacao;
  double get total {
    final valor = quantidade * valorUnitario - desconto;
    return valor < 0 ? 0 : valor;
  }
}

class _DemoProdutoOs {
  const _DemoProdutoOs(this.id, this.quantidade, this.valorUnitario);
  final String id;
  final double quantidade;
  final double valorUnitario;
  double get total => quantidade * valorUnitario;
}

class _DemoChecklist {
  const _DemoChecklist(this.descricao, this.concluido, this.observacao);
  final String descricao;
  final bool concluido;
  final String? observacao;
}

class _DemoVistoria {
  const _DemoVistoria({
    required this.motorista,
    required this.local,
    required this.destino,
    required this.tipos,
    required this.motivos,
    required this.outroMotivo,
    required this.danos,
    required this.pneus,
    required this.combustivel,
    required this.acessorios,
    required this.proprietarioOrientado,
    required this.patioCiente,
    required this.observacoes,
    required this.seguradoNome,
    required this.seguradoRg,
    required this.seguradoAssinatura,
    required this.destinatarioNome,
    required this.destinatarioRg,
    required this.destinatarioAssinatura,
    required this.prestadorNome,
    required this.prestadorRg,
    required this.prestadorAssinatura,
  });

  final String motorista;
  final String local;
  final String destino;
  final List<String> tipos;
  final List<String> motivos;
  final String outroMotivo;
  final List<Map<String, String>> danos;
  final Map<String, String> pneus;
  final int combustivel;
  final Map<String, String> acessorios;
  final bool proprietarioOrientado;
  final bool patioCiente;
  final String observacoes;
  final String seguradoNome;
  final String seguradoRg;
  final String seguradoAssinatura;
  final String destinatarioNome;
  final String destinatarioRg;
  final String destinatarioAssinatura;
  final String prestadorNome;
  final String prestadorRg;
  final String prestadorAssinatura;
}

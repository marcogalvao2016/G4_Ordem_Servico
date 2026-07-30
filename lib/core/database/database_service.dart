import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String databaseName = 'g4_os.db';
  static const int databaseVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String fullPath = p.join(databasePath, databaseName);

    return openDatabase(
      fullPath,
      version: databaseVersion,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((Transaction txn) async {
      await txn.execute('''
        CREATE TABLE clientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          nome TEXT NOT NULL,
          tipo_pessoa TEXT NOT NULL DEFAULT 'F',
          cpf_cnpj TEXT,
          telefone TEXT,
          email TEXT,
          cep TEXT,
          logradouro TEXT,
          numero TEXT,
          complemento TEXT,
          bairro TEXT,
          cidade TEXT,
          uf TEXT,
          observacoes TEXT,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await txn.execute('''
        CREATE TABLE itens (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          cliente_uuid TEXT NOT NULL,
          tipo TEXT NOT NULL,
          descricao TEXT NOT NULL,
          marca TEXT,
          modelo TEXT,
          numero_serie TEXT,
          placa TEXT,
          ano TEXT,
          cor TEXT,
          observacoes TEXT,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (cliente_uuid) REFERENCES clientes(uuid)
        )
      ''');

      await txn.execute('''
        CREATE TABLE servicos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          descricao TEXT NOT NULL,
          valor_padrao REAL NOT NULL DEFAULT 0,
          observacoes TEXT,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await txn.execute('''
        CREATE TABLE ordens_servico (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          numero_os INTEGER NOT NULL,
          cliente_uuid TEXT NOT NULL,
          item_uuid TEXT NOT NULL,
          servico_uuid TEXT,
          status TEXT NOT NULL DEFAULT 'ABERTA',
          descricao_problema TEXT NOT NULL,
          diagnostico TEXT,
          solucao TEXT,
          valor_total REAL NOT NULL DEFAULT 0,
          data_abertura TEXT NOT NULL,
          data_conclusao TEXT,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0,
          UNIQUE (empresa_uuid, numero_os),
          FOREIGN KEY (cliente_uuid) REFERENCES clientes(uuid),
          FOREIGN KEY (item_uuid) REFERENCES itens(uuid),
          FOREIGN KEY (servico_uuid) REFERENCES servicos(uuid)
        )
      ''');


      await txn.execute('''
        CREATE TABLE os_servicos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          ordem_uuid TEXT NOT NULL,
          servico_uuid TEXT NOT NULL,
          descricao TEXT NOT NULL,
          quantidade REAL NOT NULL DEFAULT 1,
          valor_unitario REAL NOT NULL DEFAULT 0,
          desconto REAL NOT NULL DEFAULT 0,
          valor_total REAL NOT NULL DEFAULT 0,
          observacao TEXT,
          ordem INTEGER NOT NULL DEFAULT 0,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid) ON DELETE CASCADE,
          FOREIGN KEY (servico_uuid) REFERENCES servicos(uuid)
        )
      ''');

      await txn.execute('''
        CREATE TABLE os_checklist (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          ordem_uuid TEXT NOT NULL,
          descricao TEXT NOT NULL,
          concluido INTEGER NOT NULL DEFAULT 0,
          observacao TEXT,
          ordem INTEGER NOT NULL DEFAULT 0,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid)
            ON DELETE CASCADE
        )
      ''');


      await txn.execute('''
        CREATE TABLE os_vistoria_veiculo (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          ordem_uuid TEXT NOT NULL UNIQUE,
          nome_motorista TEXT, local TEXT, destino TEXT, km TEXT,
          tipos_atendimento_json TEXT NOT NULL DEFAULT '[]',
          motivos_json TEXT NOT NULL DEFAULT '[]', outro_motivo TEXT,
          danos_json TEXT NOT NULL DEFAULT '[]', pneus_json TEXT NOT NULL DEFAULT '{}',
          combustivel INTEGER NOT NULL DEFAULT 50,
          acessorios_json TEXT NOT NULL DEFAULT '{}',
          proprietario_orientado INTEGER NOT NULL DEFAULT 0,
          patio_ciente INTEGER NOT NULL DEFAULT 0, observacoes TEXT,
          segurado_nome TEXT, segurado_rg TEXT, segurado_assinatura TEXT,
          destinatario_nome TEXT, destinatario_rg TEXT, destinatario_assinatura TEXT,
          prestador_nome TEXT, prestador_rg TEXT, prestador_assinatura TEXT,
          criado_em TEXT NOT NULL, atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid) ON DELETE CASCADE
        )
      ''');

      await txn.execute(
        'CREATE INDEX idx_clientes_empresa_nome '
        'ON clientes(empresa_uuid, nome)',
      );
      await txn.execute(
        'CREATE INDEX idx_itens_empresa_cliente '
        'ON itens(empresa_uuid, cliente_uuid)',
      );
      await txn.execute(
        'CREATE INDEX idx_servicos_empresa_descricao '
        'ON servicos(empresa_uuid, descricao)',
      );
      await txn.execute(
        'CREATE INDEX idx_os_empresa_numero '
        'ON ordens_servico(empresa_uuid, numero_os)',
      );
      await txn.execute(
        'CREATE INDEX idx_os_servicos_empresa_ordem '
        'ON os_servicos(empresa_uuid, ordem_uuid, ordem)',
      );
      await txn.execute(
        'CREATE INDEX idx_checklist_empresa_ordem '
        'ON os_checklist(empresa_uuid, ordem_uuid, ordem)',
      );
    });
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE os_checklist (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          ordem_uuid TEXT NOT NULL,
          descricao TEXT NOT NULL,
          concluido INTEGER NOT NULL DEFAULT 0,
          observacao TEXT,
          ordem INTEGER NOT NULL DEFAULT 0,
          criado_em TEXT NOT NULL,
          atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          excluido INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid)
            ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_checklist_empresa_ordem '
        'ON os_checklist(empresa_uuid, ordem_uuid, ordem)',
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE os_vistoria_veiculo (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          empresa_uuid TEXT NOT NULL,
          ordem_uuid TEXT NOT NULL UNIQUE,
          nome_motorista TEXT, local TEXT, destino TEXT, km TEXT,
          tipos_atendimento_json TEXT NOT NULL DEFAULT '[]',
          motivos_json TEXT NOT NULL DEFAULT '[]', outro_motivo TEXT,
          danos_json TEXT NOT NULL DEFAULT '[]', pneus_json TEXT NOT NULL DEFAULT '{}',
          combustivel INTEGER NOT NULL DEFAULT 50,
          acessorios_json TEXT NOT NULL DEFAULT '{}',
          proprietario_orientado INTEGER NOT NULL DEFAULT 0,
          patio_ciente INTEGER NOT NULL DEFAULT 0, observacoes TEXT,
          segurado_nome TEXT, segurado_rg TEXT, segurado_assinatura TEXT,
          destinatario_nome TEXT, destinatario_rg TEXT, destinatario_assinatura TEXT,
          prestador_nome TEXT, prestador_rg TEXT, prestador_assinatura TEXT,
          criado_em TEXT NOT NULL, atualizado_em TEXT NOT NULL,
          sincronizado INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE os_servicos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL UNIQUE,
            empresa_uuid TEXT NOT NULL,
            ordem_uuid TEXT NOT NULL,
            servico_uuid TEXT NOT NULL,
            descricao TEXT NOT NULL,
            quantidade REAL NOT NULL DEFAULT 1,
            valor_unitario REAL NOT NULL DEFAULT 0,
            desconto REAL NOT NULL DEFAULT 0,
            valor_total REAL NOT NULL DEFAULT 0,
            observacao TEXT,
            ordem INTEGER NOT NULL DEFAULT 0,
            criado_em TEXT NOT NULL,
            atualizado_em TEXT NOT NULL,
            sincronizado INTEGER NOT NULL DEFAULT 0,
            excluido INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (ordem_uuid) REFERENCES ordens_servico(uuid) ON DELETE CASCADE,
            FOREIGN KEY (servico_uuid) REFERENCES servicos(uuid)
          )
        ''');
        await txn.execute(
          'CREATE INDEX idx_os_servicos_empresa_ordem '
          'ON os_servicos(empresa_uuid, ordem_uuid, ordem)',
        );

        // Migra o serviço único das OS existentes para a nova estrutura.
        final antigos = await txn.rawQuery('''
          SELECT os.uuid AS ordem_uuid, os.empresa_uuid, os.servico_uuid,
                 os.valor_total, os.criado_em, os.atualizado_em,
                 s.descricao, s.valor_padrao
          FROM ordens_servico os
          INNER JOIN servicos s ON s.uuid = os.servico_uuid
          WHERE os.servico_uuid IS NOT NULL
        ''');
        for (final item in antigos) {
          final ordemUuid = item['ordem_uuid'] as String;
          final servicoUuid = item['servico_uuid'] as String;
          final criadoEm = item['criado_em'] as String;
          await txn.insert('os_servicos', <String, Object?>{
            'uuid': '${ordemUuid}_$servicoUuid',
            'empresa_uuid': item['empresa_uuid'],
            'ordem_uuid': ordemUuid,
            'servico_uuid': servicoUuid,
            'descricao': item['descricao'],
            'quantidade': 1,
            'valor_unitario': item['valor_total'] ?? item['valor_padrao'] ?? 0,
            'desconto': 0,
            'valor_total': item['valor_total'] ?? item['valor_padrao'] ?? 0,
            'ordem': 0,
            'criado_em': criadoEm,
            'atualizado_em': item['atualizado_em'] ?? criadoEm,
            'sincronizado': 0,
            'excluido': 0,
          });
        }
      });
    }
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

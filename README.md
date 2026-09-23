# G4 OS — Ordem de Serviço

Aplicativo Flutter da **G4 Sistemas** para emissão e gestão de Ordens de Serviço, com funcionamento offline (SQLite) e preparado para sincronização SaaS.

**Versão atual:** 0.9.1+16

## Funcionalidades

- Splash, login e sessão persistente com logout.
- Cadastros de Clientes, Itens e Serviços, com exclusão lógica.
- Consulta automática de CEP (ViaCEP) e CNPJ no cadastro de clientes.
- Ordens de Serviço com numeração automática, vários serviços por OS (quantidade, valor unitário, desconto e total) e checklist com progresso.
- Ficha de vistoria veicular guiada: centro de vistoria, mapa interativo de avarias, pneus, combustível, acessórios e declarações, com modelos de checklist reutilizáveis.
- PDF da Ordem de Serviço e da ficha de vistoria, salvos em `Downloads/G4OS` e compartilháveis (WhatsApp ou seletor do Android).
- Campos cadastrais sempre em letras maiúsculas.

## Stack

| Camada | Tecnologia |
|---|---|
| App | Flutter / Dart (SDK >= 3.4) |
| Banco local | SQLite (`sqflite`), arquivo `g4_os.db` com migrações automáticas |
| PDF | `pdf` + `printing` |
| Sessão | `shared_preferences` |
| Integrações | `http` (CEP e CNPJ) |

## Estrutura

```text
lib/
  core/          constantes, banco, sessão e utilitários
  models/        entidades (cliente, OS, itens, vistoria...)
  repositories/  acesso ao SQLite
  services/      autenticação, CEP, CNPJ, PDFs, modelos de checklist
  screens/       telas (splash, login, home, clientes, itens, serviços, ordens)
  widgets/       componentes reutilizáveis e módulo de vistoria
```

A documentação técnica (visão do produto, arquitetura, requisitos, regras de negócio, modelo de dados, bancos SQLite/MySQL e API REST) está nos arquivos `G4OS-DOC-*.docx` na raiz.

## Executar

```bash
flutter clean
flutter pub get
flutter test
flutter run
```

## Autenticação

A autenticação atual é **local e temporária**, apenas para desenvolvimento, enquanto a API REST não é implantada. Ela está isolada em `lib/services/auth_service.dart`, que será trocado pela autenticação real via API com token JWT. Em modo debug, a tela de login já vem preenchida com o usuário de teste.

## Plataformas

O foco é Android. O `sqflite` também atende iOS e macOS. Para Windows e Linux será necessário incluir `sqflite_common_ffi`.

Identificador Android: `br.com.g4sistemas.g4os`.

## Histórico de versões

O detalhamento de cada versão está nos arquivos `ALTERACOES_v*.txt`.

- **0.2.x** — Base unificada: login, SQLite, CRUDs, consulta de CEP/CNPJ e checklist da OS.
- **0.3–0.6** — Ficha de vistoria veicular, fluxo guiado, mapa de avarias e modelos de checklist.
- **0.7** — Vários serviços por OS.
- **0.8.x** — PDF da OS e compartilhamento (MediaStore/FileProvider, compatível com Android 8.1).
- **0.9.0** — PDF da vistoria, campos em maiúsculas e listas em cartões.
- **0.9.1** — Limpeza do repositório: remoção de telas legadas, novo applicationId e testes.

## Roadmap

- API REST (PHP/MySQL) com autenticação JWT.
- Sincronização offline/online multiempresa (SaaS).
- Suporte desktop Windows.

---

© G4 Sistemas — Marco Aurélio Galvão

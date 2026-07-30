# G4 OS v0.2 — Projeto unificado

Esta versão preserva o fluxo de autenticação e integra:

- Splash Screen;
- Login;
- sessão persistente;
- logout;
- banco SQLite;
- models;
- repositories;
- CRUD de Clientes;
- CRUD de Itens;
- CRUD de Serviços;
- CRUD de Ordens de Serviço;
- numeração automática de OS;
- exclusão lógica;
- preparação para sincronização SaaS.

## Credenciais temporárias de teste

```text
E-mail: admin@g4os.com.br
Senha: 123456
```

A autenticação desta versão é local, somente para permitir o desenvolvimento e os testes do aplicativo enquanto a API REST ainda não foi implantada.

O arquivo `lib/services/auth_service.dart` está isolado para facilitar a substituição posterior pela autenticação real via API e token JWT.

## Instalação

1. Faça backup do projeto atual.
2. Copie os arquivos deste pacote para a raiz do projeto.
3. Execute:

```bash
flutter clean
flutter pub get
flutter run
```

## Fluxo

```text
Splash
  ↓
Sessão válida?
  ├── Sim → Dashboard
  └── Não → Login
```

## Banco local

Arquivo:

```text
g4_os.db
```

Versão:

```text
1
```

## Observação sobre Windows

O banco usa `sqflite`, voltado principalmente para Android, iOS e macOS.
Para executar o SQLite no Windows, será necessário incluir `sqflite_common_ffi`.

## Correção 0.2.1

O cadastro de clientes voltou a ter:

- consulta de CEP pelo ViaCEP;
- consulta de CNPJ pela BrasilAPI;
- preenchimento automático do endereço;
- preenchimento automático de razão social, telefone e e-mail;
- campo Complemento;
- tratamento de ausência de internet e respostas inválidas.

Depois de atualizar os arquivos, execute:

```bash
flutter clean
flutter pub get
flutter run
```


## Versão 0.2.2 — Checklist da Ordem de Serviço

Incluído na OS:

- inclusão de itens;
- marcação de concluído;
- observação por item;
- remoção;
- contador de progresso;
- gravação e leitura no SQLite;
- campos de sincronização;
- migração automática do banco para a versão 2.


## Versão 0.3.0 — Ficha de vistoria veicular

Implementada conforme o modelo enviado: identificação do veículo e motorista, tipo de atendimento, local/destino/KM, motivo da chamada, danos e avarias, pneus, combustível, acessórios com S/N/I, declarações, observações e confirmações de segurado, destinatário e prestador. Os dados são armazenados offline na tabela `os_vistoria_veiculo` e vinculados à OS.


## Versão 0.3.1 — Correção de foco e controllers

Corrigido o erro:

`A TextEditingController was used after being disposed.`

A correção:

- remove o foco antes de fechar os diálogos;
- aguarda o fim do frame de fechamento;
- preserva os valores digitados antes de destruir os controllers;
- verifica se a tela ainda está montada antes de chamar `setState`.

## Versão 0.4.0 — Ficha de Vistoria guiada

A ficha de vistoria foi separada da tela principal da Ordem de Serviço e passou a funcionar em um fluxo guiado com seis etapas:

1. Identificação e veículo
2. Tipo de atendimento e motivo da chamada
3. Danos e avarias
4. Pneus e combustível
5. Acessórios por categoria
6. Declarações, observações e responsáveis

A vistoria continua vinculada à OS e armazenada offline no SQLite. A tela anterior foi preservada no projeto para referência, mas a Ordem de Serviço abre agora a nova ficha guiada.


## Versão 0.5.0 — Mapa interativo de avarias

- mapa superior do veículo com regiões tocáveis;
- seleção automática da região ao registrar avaria;
- cores por situação (não verificado, observação e avaria relevante);
- contador de avarias por região;
- lista detalhada mantida abaixo do mapa;
- sem novas dependências externas.

## Versão 0.6.0 — Centro de Vistoria e modelos de checklist

Esta versão inicia a nova arquitetura do módulo de vistoria:

- tela Resumo com percentual real de preenchimento;
- cartões de etapas concluídas, observações e avarias;
- acesso direto a qualquer etapa pelo painel;
- definição do checklist por modelo reutilizável;
- modelo inicial `Veículo leve` separado da interface;
- grupos de acessórios, motivos, tipos de atendimento e pneus carregados pelo modelo;
- estrutura preparada para novos modelos, como moto, empilhadeira, informática e ar-condicionado.

Arquivos principais adicionados:

- `lib/models/checklist_template.dart`
- `lib/services/checklist_template_service.dart`
- `lib/widgets/vistoria/vistoria_dashboard.dart`

Nenhuma migração do SQLite é necessária nesta etapa.


## Versão 0.7.0 — múltiplos serviços por Ordem de Serviço

- A OS agora aceita vários serviços.
- Cada serviço possui quantidade, valor unitário, desconto, observação e total.
- O valor total da OS é calculado automaticamente.
- Nova tabela SQLite `os_servicos`.
- Migração automática da versão 3 para 4, preservando o serviço único das OS existentes.

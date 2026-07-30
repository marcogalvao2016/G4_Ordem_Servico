# Atualização: consulta automática de CNPJ e CEP

## Instalação

Extraia este pacote na pasta principal do projeto `GS_OS`, permitindo substituir os arquivos existentes.

Depois execute:

```bat
flutter clean
flutter pub get
flutter run -d 52006ed0b6dda40b
```

## Recursos adicionados

- Consulta de CNPJ pela API pública CNPJ.ws.
- Preenchimento de razão social, nome fantasia, inscrição estadual, situação, telefone, e-mail e endereço.
- Consulta de CEP pelo ViaCEP.
- Preenchimento de logradouro, complemento, bairro, cidade e UF.
- Botões de lupa nos campos CNPJ/CPF e CEP.
- Indicador de carregamento e mensagens de erro.
- Permissão de internet no Android.

## Observações

- A consulta de CNPJ só é executada quando o documento possui 14 dígitos e passa pela validação dos dígitos verificadores.
- CPF permanece como cadastro manual.
- A API pública do CNPJ.ws possui limite de consultas por minuto.
- Os campos continuam editáveis após o preenchimento automático.

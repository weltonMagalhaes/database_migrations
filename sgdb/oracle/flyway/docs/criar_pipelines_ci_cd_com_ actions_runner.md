# Criar Pipelines CI/CD com Actions Runner

Este documento descreve como instalar e configurar GitHub Actions Runner
para executar pipelines CI/CD do projeto em Windows e Linux.

## Quando usar runner self-hosted

- Quando o pipeline precisa acessar rede interna (VPN, banco privado, on-premises).
- Quando voce precisa de ferramentas/pre-requisitos especificos na maquina.
- Quando deseja controlar capacidade, custo e isolamento por ambiente.

## Onde instalar o runner

Escolha uma maquina por ambiente (`DEV`, `HML`, `PROD`) para isolar execucoes.

- Recomendado por ambiente:
  - `runner-dev`: executa jobs do ambiente DEV
  - `runner-hml`: executa jobs do ambiente HML
  - `runner-prod`: executa jobs do ambiente PROD
- Nao instalar em servidor pessoal/local de desenvolvedor para uso continuo.
- Em producao, prefira VM/host dedicado e com acesso minimo necessario.

## Pre-requisitos gerais

- Permissao de admin no repositorio (ou organizacao) para registrar runner.
- Usuario de sistema dedicado ao runner.
- Acesso de saida para `github.com` e dominios do GitHub Actions.
- Git e utilitarios basicos instalados.

## Instalacao no Windows

### 1) Preparar diretorio

1. Criar pasta dedicada, por exemplo:
   `C:\actions-runner\controle-financeiro-dev`
2. Executar o PowerShell como administrador apenas para instalacao de servico.

### 2) Baixar e extrair runner

1. No GitHub, abrir:
   `Repositorio > Settings > Actions > Runners > New self-hosted runner`
2. Selecionar Windows x64 e copiar os comandos sugeridos.
3. Baixar e extrair dentro da pasta criada.

### 3) Configurar runner

1. Executar `config.cmd` com os parametros recomendados:
   - `--url https://github.com/<owner>/<repo>`
   - `--token <token-temporario>`
   - `--name runner-dev-win` (ajuste por ambiente)
   - `--labels self-hosted,windows,dev,oracle` (ajuste labels)
   - `--work _work`
2. Confirmar que o registro aparece em `Settings > Actions > Runners`.

### 4) Instalar como servico

1. Executar:
   - `.\svc install`
   - `.\svc start`
2. Validar no `services.msc` se o servico ficou em `Running`.

### 5) Boas praticas no Windows

- Usar conta de servico com menor privilegio possivel.
- Liberar apenas portas e destinos necessarios.
- Atualizar runner periodicamente.

## Instalacao no Linux

### 1) Preparar host e usuario

1. Criar usuario dedicado, por exemplo `actions`.
2. Criar pasta dedicada, por exemplo:
   `/opt/actions-runner/controle-financeiro-dev`
3. Dar permissao ao usuario do runner nessa pasta.

### 2) Baixar e extrair runner

1. No GitHub, abrir:
   `Repositorio > Settings > Actions > Runners > New self-hosted runner`
2. Selecionar Linux x64 e copiar comandos de download/extracao.
3. Executar os comandos no diretorio criado.

### 3) Configurar runner

Executar:

```bash
./config.sh --url https://github.com/<owner>/<repo> \
  --token <token-temporario> \
  --name runner-dev-linux \
  --labels self-hosted,linux,dev,oracle \
  --work _work
```

### 4) Instalar e iniciar servico

Executar:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Validar:

```bash
sudo ./svc.sh status
```

### 5) Boas praticas no Linux

- Nao executar runner como root no dia a dia.
- Fixar versoes de ferramentas necessarias (java, flyway, sqlplus, etc.).
- Aplicar atualizacoes de seguranca no host.

## Exemplo de job usando labels do runner

```yaml
name: Oracle Schema Provision

on:
  workflow_dispatch:

jobs:
  provision-dev:
    runs-on: [self-hosted, linux, dev, oracle]
    steps:
      - uses: actions/checkout@v4
      - name: Validar variaveis
        run: echo "Runner DEV operacional"
```

## Integracao com scripts de secrets

Depois que o runner estiver pronto, configure as variaveis/secrets com:

- `sgdb/oracle/flyway/scripts/definir-github-secrets.ps1`
- `sgdb/oracle/flyway/scripts/definir-github-secrets.sh`

Antes disso, crie o arquivo local de variaveis:

- `cp sgdb/oracle/flyway/scripts/variaveis-template.env sgdb/oracle/flyway/conf/projects/controle-financeiro/env/variaveis.env`

Templates de referencia:

- `sgdb/oracle/flyway/scripts/definir-github-secrets-template.ps1`
- `sgdb/oracle/flyway/scripts/definir-github-secrets-template.sh`

## Checklist rapido

1. Runner registrado e online no repositorio.
2. Labels coerentes com `runs-on` do workflow.
3. Secrets criadas (repositorio e environments).
4. Pipeline de teste executado com sucesso.

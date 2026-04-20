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
2. Recomendamos configurar o executor em `C:\actions-runner`.
   Isso ajuda a evitar problemas relacionados as permissoes da pasta de identidade do servico e as restricoes de caminho longo no Windows.
3. Executar o PowerShell como administrador apenas para instalacao de servico.

### 2) Baixar e extrair runner

1. No GitHub, abrir:
   `Repositorio > Settings > Actions > Runners > New self-hosted runner`
2. Selecionar Windows x64 e copiar os comandos sugeridos.
3. Baixar e extrair dentro da pasta criada.

Exemplo (PowerShell) com explicacao:

```powershell
# Create a folder under the drive root
mkdir actions-runner; cd actions-runner

# Download the latest runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.333.1/actions-runner-win-x64-2.333.1.zip -OutFile actions-runner-win-x64-2.333.1.zip

# Optional: Validate the hash
if((Get-FileHash -Path actions-runner-win-x64-2.333.1.zip -Algorithm SHA256).Hash.ToUpper() -ne 'd0c4fcb91f8f0754d478db5d61db533bba14cad6c4676a9b93c0b7c2a3969aa0'.ToUpper()){ throw 'Computed checksum did not match' }

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.333.1.zip", "$PWD")
```

- `mkdir actions-runner; cd actions-runner`: cria e entra no diretorio do runner na raiz do disco.
- `Invoke-WebRequest`: baixa o pacote `.zip` do runner.
- `Get-FileHash ... SHA256`: valida integridade do arquivo baixado comparando o hash oficial.
- `ExtractToDirectory(...)`: extrai o conteudo do `.zip` no diretorio atual.
- Ajuste a versao (`v2.333.1`) e o hash conforme a versao mais recente exibida no GitHub.

### 3) Configurar runner

1. Executar `config.cmd` com os parametros recomendados:
   - `--url https://github.com/<owner>/<repo>`
   - `--token <token-temporario>`
   - `--name runner-dev-win` (ajuste por ambiente)
   - `--labels self-hosted,windows,dev,oracle` (ajuste labels)
   - `--work _work`
2. Confirmar que o registro aparece em `Settings > Actions > Runners`.

Exemplo de configuracao e execucao manual:

```powershell
# Create the runner and start the configuration experience
.\config.cmd --url https://github.com/weltonMagalhaes/database_migrations --token <token-temporario>

# Run it!
.\run.cmd
```

- `.\config.cmd`: registra o runner no repositorio. O token e temporario e expira rapido.
- `.\run.cmd`: inicia o runner em primeiro plano para teste rapido.
- Para uso continuo, prefira instalar como servico com `.\svc install` e `.\svc start`.

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

Se quiser aceitar qualquer runner self-hosted registrado:

```yaml
runs-on: self-hosted
```

Explicacao:
- `runs-on: self-hosted` envia o job para qualquer maquina com runner self-hosted online.
- Para maior controle, prefira labels mais especificas (ex.: `windows`, `linux`, `dev`, `oracle`).

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

# Migracoes de Banco de Dados (Database Migrations)

Repositorio responsavel por centralizar o versionamento de banco de dados
utilizando **Flyway**, organizado por tipo de SGDB.

> Projeto parte do sistema de **Gestao Financeira Pessoal**

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Flyway](https://img.shields.io/badge/Flyway-9.x-red)
![Oracle](https://img.shields.io/badge/Oracle-21c-blue)

------------------------------------------------------------------------

## Sumario

- [Como Usar](#-como-usar)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Observacoes Importantes](#-observações-importantes)
- [Nomenclatura das Migrations](#-nomenclatura-das-migrations)
- [Importante](#-importante)
- [Objetivo da Estrutura](#-objetivo-da-estrutura)
- [Variaveis Globais](#-variaveis-globais)
- [Variaveis por Ambiente](#-variaveis-por-ambiente)
- [Execucao de Validacao por Ambiente](#-execução-de-validação-por-ambiente)
- [Execucao via Workflow](#-execucao-via-workflow)
- [Documentacao de Configuracao](#-documentacao-de-configuracao)
- [Referencias](#-referências)
- [Status](#-status)

------------------------------------------------------------------------

## 🚀 Como Usar

### Pre-requisitos

- [Flyway](https://flywaydb.org/download) instalado (versao 9.x ou superior)
- Acesso ao Oracle Database
- [GitHub CLI](https://cli.github.com/) (opcional, para configurar secrets)

### Configuracao Inicial

```bash
# 1. Clone o repositorio
git clone https://github.com/seu-usuario/database_migrations.git
cd database_migrations

# 2. Crie o arquivo local de variaveis (nao versionado)
cp sgdb/oracle/flyway/scripts/variaveis-template.env sgdb/oracle/flyway/conf/projects/controle-financeiro/env/variaveis.env

# 3. Edite o arquivo de variaveis com suas credenciais reais
# O variaveis.env esta no .gitignore - nao sera versionado

# 4. Configure os secrets no GitHub (Linux/macOS)
./sgdb/oracle/flyway/scripts/definir-github-secrets.sh
# 4b. Configure os secrets no GitHub (Windows PowerShell)
.\sgdb\oracle\flyway\scripts\definir-github-secrets.ps1

# 5. Entre na pasta do Flyway e execute uma migration
cd sgdb/oracle/flyway
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-dev.conf migrate
```

## 🧱 Estrutura de Pastas

A organização do projeto foi pensada para suportar múltiplos bancos de
dados de forma independente:

```bash
📁 database_migrations/
├── 📁 .github/                                          # Automatizacoes e pipelines do repositorio
│   └── 📁 workflows/                                   # CI/CD futuro
│       └── 📄 oracle-schema-provision.yml
├── 📁 sgdb/                                             # Organizacao por tecnologia de banco
│   └── 📁 oracle/                                       # SGDB: Oracle
│       ├── 📄 .gitignore                                # Regras de versionamento para arquivos locais do Oracle
│       └── 📁 flyway/                                   # Estrutura base do Flyway para Oracle
│           ├── 📁 conf/                                 # Configuracoes por projeto/ambiente
│           │   ├── 📄 flyway-configuracao_base-controle-finaceiro.conf
│           │   └── 📁 projects/                         # Configs segregadas por projeto
│           │       └── 📁 controle-financeiro/          # Projeto Gestao Financeira Pessoal
│           │           └── 📁 env/                      # Placeholders/credenciais por ambiente (local)
│           ├── 📁 docs/                                 # Documentacao especifica
│           │   ├── 📄 criar_repositorio_no_git.md
│           │   ├── 📄 criar_pipelines_ci_cd_com_ actions_runner.md
│           │   ├── 📄 documentacao_arquivos_de_configuracao.md
│           │   └── 📄 documentacao_das_variaveis_de_configuracao.md
│           ├── 📁 logs/                                 # Logs gerados pelo Flyway
│           │   └── 📄 .gitkeep
│           ├── 📁 scripts/                              # Scripts auxiliares versionados
│           │   ├── 📄 definir-github-secrets.ps1
│           │   ├── 📄 definir-github-secrets.sh
│           │   └── 📄 variaveis-template.env
│           └── 📁 sql/                                  # Scripts SQL controlados por versao
│               └── 📁 migrations/                       # Migrations do Flyway
│                   └── 📁 db/                           # Trilhas de migracao de banco
│                       └── 📁 projects/                 # Migrations separadas por projeto
│                           └── 📁 controle-financeiro/  # Dominio de migrations do projeto
│                               ├── 📁 admin/
│                               │   └── 📁 users/        # DDL de usuarios + configuracoes Flyway
│                               │       ├── 📄 flyway-configuracao-usuario-dba-admin.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-dev.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-hml.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-prod.conf
│                               │       ├── 📄 flyway-configuracao-usuario-app-dev.conf
│                               │       ├── 📄 flyway-configuracao-usuario-app-hml.conf
│                               │       ├── 📄 flyway-configuracao-usuario-app-prod.conf
│                               │       ├── 📄 flyway-configuracao-validacao-app-dev.conf
│                               │       ├── 📄 flyway-configuracao-validacao-app-hml.conf
│                               │       ├── 📄 flyway-configuracao-validacao-app-prod.conf
│                               │       ├── 📄 flyway-configuracao-validacao-owner-dev.conf
│                               │       ├── 📄 flyway-configuracao-validacao-owner-hml.conf
│                               │       └── 📄 flyway-configuracao-validacao-owner-prod.conf
│                               ├── 📁 application/
│                               │   ├── 📁 app-dev/
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   ├── 📁 app-hml/
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   └── 📁 app-prod/
│                               │       ├── 📄 .gitkeep
│                               │       └── 📄 V1__validacao_flyway_inicial.sql
│                               └── 📁 owner/
│                                   ├── 📁 owner-dev/
│                                   │   ├── 📄 .gitkeep
│                                   │   └── 📄 V1__validacao_flyway_inicial.sql
│                                   ├── 📁 owner-hml/
│                                   │   ├── 📄 .gitkeep
│                                   │   └── 📄 V1__validacao_flyway_inicial.sql
│                                   └── 📁 owner-prod/
│                                       ├── 📄 .gitkeep
│                                       └── 📄 V1__validacao_flyway_inicial.sql
└── 📄 README.md
```

------------------------------------------------------------------------

## 📝 Observações Importantes

- Cada SGDB possui sua propria estrutura Flyway dentro de `sgdb/`.
- O dominio `admin/users` concentra configuracoes `.conf` por contexto.
- Os dominios `application` e `owner` estao organizados por ambiente (`dev`, `hml`, `prod`).
- As validacoes iniciais de versionamento foram criadas para `application` e `owner` em todos os ambientes.
- Os arquivos de configuração `.conf` usam placeholders `${VARIAVEL}` resolvidos pelo Flyway.
- A pasta `.github` sera utilizada para automacao futura (GitHub Actions).

### 📋 Nomenclatura das Migrations

```bash
V{numero}__{descricao}.sql

Exemplos:
V1__validacao_flyway_inicial.sql
V2__create_table_transacoes.sql
V3__add_audit_fields.sql
```

## ⚠️ Importante

- Se voce esta acostumado com outras ferramentas (como Liquibase ou ferramentas com timestamp), o Flyway e mais rigido nesse aspecto.
- O padrao correto e sempre:

- ✅ Use numeros sequenciais: `V1`, `V2`, `V3`...
- ✅ Use **duplo underscore** `__` apos o numero
- ✅ Descricao clara em snake_case
- ❌ **NAO use timestamps** (Flyway nao reconhece)
- ❌ **NAO repita numeros** (cada versao e unica)

------------------------------------------------------------------------

## 🎯 Objetivo da Estrutura

- Separar migrations por banco de dados
- Isolar configuracoes por tecnologia
- Permitir evolucao independente de cada banco
- Preparar o projeto para CI/CD
- Organizar scripts por ambiente e por dominio (`application` e `owner`)

------------------------------------------------------------------------

## 🌐 Variaveis Globais

### 🔹ADMIN

```bash
ADMIN_URL
ADMIN_USER
ADMIN_PASSWORD
MIGRATION_INSTALLED_BY
```

## 🔧 Variaveis por Ambiente

### 🔹APPLICATION

```bash
APP_<ENV>_ADMIN_URL
APP_<ENV>_ADMIN_USER
APP_<ENV>_ADMIN_PASSWORD
APP_<ENV>_USER
APP_<ENV>_PASSWORD
APP_<ENV>_DEFAULT_TABLESPACE
APP_<ENV>_TEMP_TABLESPACE
APP_<ENV>_DATABASE_NAME
```

### 🔹OWNER

```bash
OWNER_<ENV>_ADMIN_URL
OWNER_<ENV>_ADMIN_USER
OWNER_<ENV>_ADMIN_PASSWORD
OWNER_<ENV>_USER
OWNER_<ENV>_PASSWORD
OWNER_<ENV>_DEFAULT_TABLESPACE
OWNER_<ENV>_TEMP_TABLESPACE
OWNER_<ENV>_DATABASE_NAME
```

------------------------------------------------------------------------

## ✅ Execução de Validação por Ambiente

Entre na pasta do Flyway:

```bash
cd sgdb/oracle/flyway
```

### Validacao APPLICATION

```bash
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-dev.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-hml.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-prod.conf migrate
```

### Validacao OWNER

```bash
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-dev.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-hml.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-prod.conf migrate
```

------------------------------------------------------------------------

## ⚙️ Execucao via Workflow

Workflow disponivel:

- `.github/workflows/oracle-schema-provision.yml`

Execucao:

1. Acesse a aba `Actions` no GitHub.
2. Selecione `Oracle Schema Provision`.
3. Clique em `Run workflow`.
4. Preencha:
   `ambiente`: `DEV`, `HML` ou `PROD`
   `dominio`: `application`, `owner` ou `all`
   `comando`: `migrate`, `validate` ou `info`

Observacao:

- O job usa `environment` dinamico (`DEV`, `HML`, `PROD`), entao a aprovacao configurada em cada ambiente sera exigida.

------------------------------------------------------------------------

## 📘 Documentacao de Configuracao

- [Documentacao dos Arquivos de Configuracao (.conf)](sgdb/oracle/flyway/docs/documentacao_arquivos_de_configuracao.md)
- [Documentacao das Variaveis de Configuracao](sgdb/oracle/flyway/docs/documentacao_das_variaveis_de_configuracao.md)
- [Criar Pipelines CI/CD com Actions Runner](sgdb/oracle/flyway/docs/criar_pipelines_ci_cd_com_%20actions_runner.md)
- [Como criar repositorio no GitHub com GH CLI](sgdb/oracle/flyway/docs/criar_repositorio_no_git.md)

------------------------------------------------------------------------

## 📚 Referências

- [Documentacao oficial do Flyway](https://flywaydb.org/documentation/)
- [Boas praticas com migrations](https://flywaydb.org/documentation/concepts/migrations#versioned-migrations)
- [Oracle e Flyway](https://flywaydb.org/documentation/database/oracle)

## 🚧 Status

Em desenvolvimento ativo - Estrutura consolidada com validacoes iniciais para `application` e `owner` por ambiente.

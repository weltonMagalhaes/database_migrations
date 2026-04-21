# Migrações de Banco de Dados (Database Migrations)

Repositório responsável por centralizar o versionamento de banco de dados
utilizando **Flyway**, organizado por tipo de SGDB.

> Projeto parte do sistema de **Gestão Financeira Pessoal**

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Flyway](https://img.shields.io/badge/Flyway-9.x-red)
![Oracle](https://img.shields.io/badge/Oracle-21c-blue)

------------------------------------------------------------------------

## Sumário

- [Como Usar](#-como-usar)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Observações Importantes](#-observações-importantes)
- [Nomenclatura das Migrations](#-nomenclatura-das-migrations)
- [Importante](#-importante)
- [Objetivo da Estrutura](#-objetivo-da-estrutura)
- [Variáveis Globais](#-variáveis-globais)
- [Variáveis por Ambiente](#-variáveis-por-ambiente)
- [Execução de Validação por Ambiente](#-execução-de-validação-por-ambiente)
- [Execução via Workflow](#-execução-via-workflow)
- [Documentação de Configuração](#-documentação-de-configuração)
- [Referências](#-referências)
- [Status](#-status)
- [SQL Guard LLM (PoC)](#sql-guard-llm-poc)

------------------------------------------------------------------------

## 🚀 Como Usar

### Pré-requisitos

- [Flyway](https://flywaydb.org/download) instalado (versão 9.x ou superior)
- Acesso ao Oracle Database
- [GitHub CLI](https://cli.github.com/) (opcional, para configurar secrets)

### Configuração Inicial

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/database_migrations.git
cd database_migrations

# 2. Crie o arquivo local de variáveis (não versionado)
cp sgdb/oracle/flyway/scripts/variaveis-template.env sgdb/oracle/flyway/conf/projects/controle-financeiro/env/variaveis.env

# 3. Edite o arquivo de variáveis com suas credenciais reais
# O variaveis.env está no .gitignore - não será versionado

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
├── 📁 .github/                                          # Automatizações e pipelines do repositório
│   └── 📁 workflows/                                    # CI/CD futuro
│       └── 📄 oracle-schema-provision.yml
├── 📁 sgdb/                                             # Organização por tecnologia de banco
│   └── 📁 oracle/                                       # SGDB: Oracle
│       ├── 📄 .gitignore                                # Regras de versionamento para arquivos locais do Oracle
│       └── 📁 flyway/                                   # Estrutura base do Flyway para Oracle
│           ├── 📁 conf/                                 # Configurações por projeto/ambiente
│           │   ├── 📄 flyway-configuracao_base-controle-finaceiro.conf
│           │   └── 📁 projects/                         # Configs segregadas por projeto
│           │       └── 📁 controle-financeiro/          # Projeto Gestão Financeira Pessoal
│           │           └── 📁 env/                      # Placeholders/credenciais por ambiente (local)
│           ├── 📁 docs/                                 # Documentação específica
│           │   ├── 📄 criar_repositorio_no_git.md
│           │   ├── 📄 criar_pipelines_ci_cd_com_ actions_runner.md
│           │   ├── 📄 documentacao_arquivos_de_configuracao.md
│           │   └── 📄 documentacao_das_variaveis_de_configuracao.md
│           ├── 📁 logs/                                 # Logs gerados pelo Flyway
│           │   └── 📄 .gitkeep
│           ├── 📁 scripts/                              # Scripts auxiliares versionados
│           │   ├── 📄 definir-github-secrets.ps1
│           │   ├── 📄 definir-github-secrets.sh
│           │   ├── 📄 validar-padrao-sql-llm.ps1
│           │   └── 📄 variaveis-template.env
│           └── 📁 sql/                                  # Scripts SQL controlados por versão
│               └── 📁 migrations/                       # Migrations do Flyway
│                   └── 📁 db/                           # Trilhas de migração de banco
│                       └── 📁 projects/                 # Migrations separadas por projeto
│                           └── 📁 controle-financeiro/  # Domínio de migrations do projeto
│                               ├── 📁 admin/            # Camada administrativa (usuários e grants)
│                               │   └── 📁 users/        # DDL de usuários + configurações Flyway
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
│                               │       ├── 📄 flyway-configuracao-validacao-owner-prod.conf
│                               │       └── 📁 provision/ # Provisionamento/reconciliação de usuários
│                               │           ├── 📁 app-dev/   # Provisionamento do APP em DEV
│                               │           │   ├── 📄 V1__provisionar_usuario_app_dev.sql
│                               │           │   └── 📄 R__garantir_usuario_app_dev.sql
│                               │           ├── 📁 app-hml/   # Provisionamento do APP em HML
│                               │           │   ├── 📄 V1__provisionar_usuario_app_hml.sql
│                               │           │   └── 📄 R__garantir_usuario_app_hml.sql
│                               │           ├── 📁 app-prod/  # Provisionamento do APP em PROD
│                               │           │   ├── 📄 V1__provisionar_usuario_app_prod.sql
│                               │           │   └── 📄 R__garantir_usuario_app_prod.sql
│                               │           ├── 📁 owner-dev/ # Provisionamento do OWNER em DEV
│                               │           │   ├── 📄 V1__provisionar_usuario_owner_dev.sql
│                               │           │   └── 📄 R__garantir_usuario_owner_dev.sql
│                               │           ├── 📁 owner-hml/ # Provisionamento do OWNER em HML
│                               │           │   ├── 📄 V1__provisionar_usuario_owner_hml.sql
│                               │           │   └── 📄 R__garantir_usuario_owner_hml.sql
│                               │           └── 📁 owner-prod/ # Provisionamento do OWNER em PROD
│                               │               ├── 📄 V1__provisionar_usuario_owner_prod.sql
│                               │               └── 📄 R__garantir_usuario_owner_prod.sql
│                               ├── 📁 application/      # Migrations do schema de aplicação
│                               │   ├── 📁 app-dev/      # Trilha de aplicação em DEV
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   ├── 📁 app-hml/      # Trilha de aplicação em HML
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   └── 📁 app-prod/     # Trilha de aplicação em PROD
│                               │       ├── 📄 .gitkeep
│                               │       └── 📄 V1__validacao_flyway_inicial.sql
│                               ├── 📁 owner/            # Migrations do schema owner
│                               │   ├── 📁 owner-dev/    # Trilha de owner em DEV
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   ├── 📁 owner-hml/    # Trilha de owner em HML
│                               │   │   ├── 📄 .gitkeep
│                               │   │   └── 📄 V1__validacao_flyway_inicial.sql
│                               │   └── 📁 owner-prod/   # Trilha de owner em PROD
│                               │       ├── 📄 .gitkeep
│                               │       └── 📄 V1__validacao_flyway_inicial.sql
│                               └── 📁 shared/           # Scripts SQL compartilhados entre domínios
└── 📄 README.md
```

------------------------------------------------------------------------

## 📝 Observações Importantes

- Cada SGDB possui sua própria estrutura Flyway dentro de `sgdb/`.
- O domínio `admin/users` concentra configurações `.conf` por contexto.
- Os domínios `application` e `owner` estão organizados por ambiente (`dev`, `hml`, `prod`), e `shared` centraliza scripts reaproveitáveis.
- As validações iniciais de versionamento foram criadas para `application` e `owner` em todos os ambientes.
- Os arquivos de configuração `.conf` usam placeholders `${VARIAVEL}` resolvidos pelo Flyway.
- A pasta `.github` será utilizada para automação futura (GitHub Actions).

### 📋 Nomenclatura das Migrations

```bash
V{numero}__{descricao}.sql

Exemplos:
V1__validacao_flyway_inicial.sql
V2__create_table_transacoes.sql
V3__add_audit_fields.sql
```

## ⚠️ Importante

- Se você está acostumado com outras ferramentas (como Liquibase ou ferramentas com timestamp), o Flyway é mais rígido nesse aspecto.
- O padrão correto é sempre:
- ✅ Use números sequenciais: `V1`, `V2`, `V3`...
- ✅ Use **duplo underscore** `__` após o número
- ✅ Use descrição clara em snake_case
- ❌ **NÃO use timestamps** (Flyway não reconhece)
- ❌ **NÃO repita números** (cada versão é única)

------------------------------------------------------------------------

## 🎯 Objetivo da Estrutura

- Separar migrations por banco de dados
- Isolar configurações por tecnologia
- Permitir evolução independente de cada banco
- Preparar o projeto para CI/CD
- Organizar scripts por ambiente e por domínio (`application`, `owner` e `shared`)

------------------------------------------------------------------------

## 🌐 Variáveis Globais

### 🔹ADMIN

```bash
ADMIN_URL
ADMIN_USER
ADMIN_PASSWORD
MIGRATION_INSTALLED_BY
```

## 🔧 Variáveis por Ambiente

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

### Validação APPLICATION

```bash
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-dev.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-hml.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-prod.conf migrate
```

### Validação OWNER

```bash
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-dev.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-hml.conf migrate
flyway -configFiles=sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-prod.conf migrate
```

------------------------------------------------------------------------

## ⚙️ Execução via Workflow

Workflow disponível:

- `.github/workflows/oracle-schema-provision.yml`

Execução:

1. Acesse a aba `Actions` no GitHub.
2. Selecione `Oracle Schema Provision`.
3. Clique em `Run workflow`.
4. Preencha:
   `ambiente`: `DEV`, `HML` ou `PROD`
   `dominio`: `application`, `owner` ou `all`
   `comando`: `migrate`, `validate` ou `info`

Observação:

- O job usa `environment` dinâmico (`DEV`, `HML`, `PROD`), então a aprovação configurada em cada ambiente será exigida.

## Fluxo Recomendado e Troubleshooting

Ordem recomendada por ambiente/domínio:

1. Executar `migrate` no arquivo `flyway-configuracao-usuario-<dominio>-<ambiente>.conf` (provisionamento/reconciliação de usuário).
2. Executar `migrate` no arquivo `flyway-configuracao-validacao-<dominio>-<ambiente>.conf` (migrations do schema).

Erros comuns e como resolver:

- `Migration checksum mismatch for migration version 1`:
  executar `repair` usando o mesmo `configFiles` da trilha de usuário e, em seguida, executar `migrate` novamente.
- `ORA-01950: no privileges on tablespace`:
  garantir que os scripts `R__garantir_usuario_*.sql` foram aplicados (eles concedem `QUOTA UNLIMITED ON <DEFAULT_TABLESPACE>`), depois repetir o `migrate`.
- `Unable to connect to the database. Configure the url, user and password` em execução local:
  carregar as variáveis do arquivo `conf/projects/controle-financeiro/env/variaveis.env` na sessão antes de rodar Flyway.

------------------------------------------------------------------------

## 📘 Documentação de Configuração

- [Documentação dos Arquivos de Configuração (.conf)](sgdb/oracle/flyway/docs/documentacao_arquivos_de_configuracao.md)
- [Documentação das Variáveis de Configuração](sgdb/oracle/flyway/docs/documentacao_das_variaveis_de_configuracao.md)
- [Criar Pipelines CI/CD com Actions Runner](sgdb/oracle/flyway/docs/criar_pipelines_ci_cd_com_%20actions_runner.md)
- [Como criar repositório no GitHub com GH CLI](sgdb/oracle/flyway/docs/criar_repositorio_no_git.md)

------------------------------------------------------------------------

## 📚 Referências

- [Documentação oficial do Flyway](https://flywaydb.org/documentation/)
- [Boas práticas com migrations](https://flywaydb.org/documentation/concepts/migrations#versioned-migrations)
- [Oracle e Flyway](https://flywaydb.org/documentation/database/oracle)

## 🚧 Status

Em desenvolvimento ativo - Estrutura consolidada com validações iniciais para `application` e `owner` por ambiente.

------------------------------------------------------------------------

## SQL Guard LLM (PoC)

Esta cópia do projeto inclui uma PoC para validar padrão interno de SQL antes da execução do Flyway.

Arquivos da PoC:

- `sgdb/oracle/flyway/docs/padrao_sql_llm.md`
- `sgdb/oracle/flyway/conf/sql-guard-rules.json`
- `sgdb/oracle/flyway/scripts/validar-padrao-sql-llm.ps1`

Comportamento:

1. O workflow executa o SQL guard antes do `Run-Flyway` para `application` e `owner`.
2. Se houver violação de regra com severidade `error`, a execução é bloqueada.
3. Se `SQL_GUARD_ALLOW_OVERRIDE=true`, o pipeline continua e registra a decisão no log.
4. O log é salvo em `sgdb/oracle/flyway/logs/llm_sql_guard.log`.

Variáveis da PoC:

- `SQL_GUARD_LLM_ENABLED` (`true` ou `false`)
- `SQL_GUARD_ALLOW_OVERRIDE` (`true` ou `false`)
- `LLM_PROVIDER` (`openai`, `deepseek` ou `gemini`)
- `LLM_API_KEY`
- `LLM_MODEL`
- `LLM_BASE_URL`

Compatibilidade retroativa (opcional):

- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `OPENAI_BASE_URL`
- `GEMINI_API_KEY`

Exemplos rápidos:

- DeepSeek (compatível OpenAI):
  - `LLM_PROVIDER=deepseek`
  - `LLM_API_KEY=<chave>`
  - `LLM_MODEL=deepseek-chat` (ou outro modelo)
  - `LLM_BASE_URL=https://api.deepseek.com`
- Gemini (API nativa):
  - `LLM_PROVIDER=gemini`
  - `LLM_API_KEY=<chave>` ou `GEMINI_API_KEY=<chave>`
  - `LLM_MODEL=gemini-1.5-flash` (ou outro modelo)
  - `LLM_BASE_URL=https://generativelanguage.googleapis.com`

Observação:

- A revisão LLM é complementar. A decisão de bloqueio/permissão continua controlada pelas regras determinísticas + política de override.




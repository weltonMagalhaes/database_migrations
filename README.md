# Migracoes de Banco de Dados (Database Migrations)

Repositorio responsavel por centralizar o versionamento de banco de dados
utilizando **Flyway**, organizado por tipo de SGDB.

> Projeto parte do sistema de **Gestao Financeira Pessoal**

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Flyway](https://img.shields.io/badge/Flyway-9.x-red)
![Oracle](https://img.shields.io/badge/Oracle-19c-blue)

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
flyway -configFiles=conf/projects/controle-financeiro/flyway-controle-financeiro-app-dev.conf migrate
```

## 🧱 Estrutura de Pastas

A organização do projeto foi pensada para suportar múltiplos bancos de
dados de forma independente:

```bash
📁 database_migrations/
├── 📁 .github/                                          # Automatizacoes e pipelines do repositorio
│   └── 📁 workflows/                                   # CI/CD futuro
│       └── 📄 .gitkeep
├── 📁 sgdb/                                             # Organizacao por tecnologia de banco
│   └── 📁 oracle/                                       # SGDB: Oracle
│       ├── 📄 .gitignore                                # Regras de versionamento para arquivos locais do Oracle
│       └── 📁 flyway/                                   # Estrutura base do Flyway para Oracle
│           ├── 📁 conf/                                 # Configuracoes por projeto/ambiente
│           │   └── 📁 projects/                         # Configs segregadas por projeto
│           │       └── 📁 controle-financeiro/          # Projeto Gestao Financeira Pessoal
│           │           └── 📁 env/                      # Placeholders/credenciais por ambiente adicionado no arquivo gitignore
│           │               
│           │               
│           ├── 📁 docs/                                  # Documentacao especifica
│           │   ├── 📄 criar_repositorio_no_git.md
│           │   ├── 📄 criar_pipelines_ci_cd_com_ actions_runner.md
│           │   ├── 📄 documentacao_arquivos_de_configuracao.md
│           │   └── 📄 documentacao_das_variaveis_de_configuracao.md
│           ├── 📁 logs/                                  # Logs gerados pelo Flyway
│           │   └── 📄 .gitkeep
│           ├── 📁 scripts/                               # Scripts auxiliares versionados
│           │   ├── 📄 definir-github-secrets.ps1
│           │   ├── 📄 definir-github-secrets.sh
│           │   └── 📄 variaveis-template.env
│           └── 📁 sql/                                  # Scripts SQL controlados por versao
│               └── 📁 migrations/                       # Migrations do Flyway
│                   └── 📁 db/                           # Trilhas de migracao de banco
│                       └── 📁 projects/                 # Migrations separadas por projeto
│                           └── 📁 controle-financeiro/  # Dominio de migrations do projeto
│                               ├── 📁 admin/            # Trilhas do schema administrativo
│                               │   ├── 📁 audit/        # Objetos e regras de auditoria
│                               │   │   └── 📄 .gitkeep
│                               │   ├── 📁 monitoring/   # Objetos de monitoramento e observabilidade
│                               │   │   └── 📄 .gitkeep
│                               │   └── 📁 users/        # DDL de usuarios, roles e grants
│                               │       ├── 📄 flyway-configuracao-usuario-dba-admin.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-dev.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-hml.conf
│                               │       ├── 📄 flyway-configuracao-usuario-owner-prod.conf
│                               │       ├── 📄 flyway-configuracao-usuario-app-dev.conf
│                               │       ├── 📄 flyway-configuracao-usuario-app-hml.conf
│                               │       └── 📄 flyway-configuracao-usuario-app-prod.conf
│                               ├── 📁 application/      # Trilhas do schema da aplicacao
│                               │   ├── 📁 app-dev/      # Scripts especificos do ambiente DEV
│                               │   │   └── 📄 .gitkeep
│                               │   ├── 📁 app-hml/      # Scripts especificos do ambiente HML
│                               │   │   └── 📄 .gitkeep
│                               │   └── 📁 app-prod/     # Scripts especificos do ambiente PROD
│                               │       └── 📄 .gitkeep
│                               ├── 📁 owner/            # Trilhas do schema owner
│                               │   ├── 📁 owner-dev/    # Scripts especificos do ambiente DEV
│                               │   │   └── 📄 .gitkeep
│                               │   ├── 📁 owner-hml/    # Scripts especificos do ambiente HML
│                               │   │   └── 📄 .gitkeep
│                               │   └── 📁 owner-prod/   # Scripts especificos do ambiente PROD
│                               │       └── 📄 .gitkeep
│                               └── 📁 shared/           # Objetos compartilhados entre dominios/schemas
└── 📄 README.md
```

------------------------------------------------------------------------

## 📝 Observações Importantes

-  Cada SGDB possui sua própria estrutura Flyway dentro de sgdb/
-  O dominio admin esta separado em trilhas audit, monitoring e users
-  Os domínios application e owner estao organizados por ambiente (dev, hml e prod)
-  Os arquivos de configuração .conf usam placeholders (${VARIAVEL}) resolvidos pelo Flyway
-  A pasta .github será utilizada para automação futura (GitHub Actions)



### 📋 Nomenclatura das Migrations

```bash
        V{numero}__{descricao}.sql

        Exemplos:
        V1__init_admin_common.sql       # Versão 1: inicial comum
        V2__admin_dev.sql               # Versão 2: específico DEV
        V3__add_audit_fields.sql        # Versão 3: adiciona campos de auditoria
        V4__create_table_transacoes.sql # Versão 4: nova tabela

```



## ⚠️ Importante

 - Se você está acostumado com outras ferramentas (como Liquibase ou ferramentas que usam timestamp), o Flyway é mais  rígido nesse aspecto. O padrão correto é sempre:

- ✅ Use números sequenciais: `V1`, `V2`, `V3`...
- ✅ Use **duplo underscore** `__` após o número
- ✅ Descrição clara em snake_case
- ❌ **NÃO use timestamps** (Flyway não reconhece)
- ❌ **NÃO repita números** (cada versão é única)

------------------------------------------------------------------------

## 🎯 Objetivo da Estrutura

-   Separar migrations por banco de dados\
-   Isolar configurações por tecnologia\
-   Permitir evolução independente de cada banco\
-   Preparar o projeto para CI/CD\
-   Organizar scripts por ambiente

------------------------------------------------------------------------

## 🌐 Variaveis Globais

### 🔹ADMIN

```bash
        ADMIN_URL
        ADMIN_USER
        ADMIN_PASSWORD
```

## 🔧 Variaveis por Ambiente

### 🔹DEV

```bash
        DB_USER_DEV
        DB_PASSWORD_DEV
        DB_USER_APP_DEV
        DB_PASSWORD_APP_DEV
```

### 🔹HML

```bash
        DB_USER_HML
        DB_PASSWORD_HML
        DB_USER_APP_HML
        DB_PASSWORD_APP_HML
```

### 🔹PROD

```bash
        DB_USER_PROD
        DB_PASSWORD_PROD
        DB_USER_APP_PROD
        DB_PASSWORD_APP_PROD
```

------------------------------------------------------------------------

## 📘 Documentacao de Configuracao

- [Documentacao dos Arquivos de Configuracao (.conf)](sgdb/oracle/flyway/docs/documentacao_arquivos_de_configuracao.md)
- [Documentacao das Variaveis de Configuracao](sgdb/oracle/flyway/docs/documentacao_das_variaveis_de_configuracao.md)
- [Criar Pipelines CI/CD com Actions Runner](sgdb/oracle/flyway/docs/criar_pipelines_ci_cd_com_%20actions_runner.md)
- Este documento concentra a lista dos arquivos `.conf` e o papel de cada configuracao no projeto.

------------------------------------------------------------------------

## 📚 Referências
- [Documentação oficial do Flyway](https://flywaydb.org/documentation/)
- [Boas práticas com migrations](https://flywaydb.org/documentation/concepts/migrations#versioned-migrations)
- [Oracle e Flyway](https://flywaydb.org/documentation/database/oracle)
- [Como criar repositorio no GitHub com GH CLI](sgdb/oracle/flyway/docs/criar_repositorio_no_git.md)
- [Documentacao dos arquivos de configuracao](sgdb/oracle/flyway/docs/documentacao_arquivos_de_configuracao.md)


## 🚧 Status

Em desenvolvimento ativo - Estrutura sendo consolidada.

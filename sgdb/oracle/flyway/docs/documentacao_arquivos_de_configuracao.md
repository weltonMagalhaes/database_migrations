# Documentacao dos Arquivos de Configuracao (.conf)

Este documento centraliza a lista de arquivos `.conf` do projeto e descreve a funcionalidade de cada um.

## Objetivo

Padronizar o entendimento das configuracoes do Flyway e facilitar manutencao, auditoria e onboarding.

## Lista de Arquivos `.conf`

### 1) `flyway-configuracao_base-controle-finaceiro.conf`

- Caminho: `sgdb/oracle/flyway/conf/flyway-configuracao_base-controle-finaceiro.conf`
- Tipo: configuracao base compartilhada
- Funcao principal: definir as regras globais de execucao de migrations do projeto `controle-financeiro`.

Configuracoes principais aplicadas por este arquivo:

- `flyway.encoding=UTF-8`: padrao de codificacao dos scripts SQL.
- `flyway.validateMigrationNaming=true`: valida o padrao de nomenclatura dos arquivos de migration.
- `flyway.sqlMigrationPrefix=V`: define prefixo de versao das migrations.
- `flyway.sqlMigrationSuffixes=.sql`: define extensoes esperadas dos scripts.
- `flyway.sqlMigrationSeparator=__`: separador entre versao e descricao.
- `flyway.installedBy=${MIGRATION_INSTALLED_BY}`: registra quem executou a migration.
- `flyway.cleanDisabled=true`: bloqueia o comando `clean` para reduzir risco de perda acidental de dados.
- `flyway.createSchemas=false`: nao cria schemas automaticamente.
- `flyway.outOfOrder=true`: permite execucao de migrations fora de ordem, util para correcoes pontuais.

### 2) `flyway-configuracao-usuario-dba-admin.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-dba-admin.conf`
- Tipo: configuracao administrativa (DBA/SYS)
- Funcao principal: realizar conexao privilegiada no banco para execucao de migrations administrativas de usuarios.

Configuracoes principais aplicadas por este arquivo:

- `flyway.url=${ADMIN_URL}`: URL administrativa do banco.
- `flyway.user=${ADMIN_USER}`: usuario administrativo.
- `flyway.password=${ADMIN_PASSWORD}`: senha administrativa.
- `flyway.jdbcProperties.internal_logon=SYSDBA`: habilita login SYSDBA quando necessario.
- `flyway.defaultSchema=${ADMIN_USER}`: schema padrao da execucao administrativa.
- `flyway.table=flyway_history_admin_users`: tabela de historico dedicada ao contexto administrativo de usuarios.
- `flyway.locations=filesystem:./sql/migrations/db/projects/controle-financeiro/admin/users`: local base dos scripts administrativos.
- `flyway.baselineOnMigrate=true`: permite baseline em ambientes existentes.
- `flyway.connectRetries=10` e `flyway.connectRetriesInterval=5`: retentativas de conexao.

### 3) `flyway-configuracao-usuario-owner-dev.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-owner-dev.conf`
- Tipo: configuracao de criacao/gestao de usuario OWNER no DEV
- Funcao principal: executar scripts da trilha `owner/owner-dev` com placeholders de usuario OWNER do DEV.

### 4) `flyway-configuracao-usuario-owner-hml.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-owner-hml.conf`
- Tipo: configuracao de criacao/gestao de usuario OWNER no HML
- Funcao principal: executar scripts da trilha `owner/owner-hml` com placeholders de usuario OWNER do HML.

### 5) `flyway-configuracao-usuario-owner-prod.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-owner-prod.conf`
- Tipo: configuracao de criacao/gestao de usuario OWNER no PROD
- Funcao principal: executar scripts da trilha `owner/owner-prod` com placeholders de usuario OWNER do PROD.

### 6) `flyway-configuracao-usuario-app-dev.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-app-dev.conf`
- Tipo: configuracao de criacao/gestao de usuario APPLICATION no DEV
- Funcao principal: executar scripts da trilha `application/app-dev` com placeholders de usuario APPLICATION do DEV.

### 7) `flyway-configuracao-usuario-app-hml.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-app-hml.conf`
- Tipo: configuracao de criacao/gestao de usuario APPLICATION no HML
- Funcao principal: executar scripts da trilha `application/app-hml` com placeholders de usuario APPLICATION do HML.

### 8) `flyway-configuracao-usuario-app-prod.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-app-prod.conf`
- Tipo: configuracao de criacao/gestao de usuario APPLICATION no PROD
- Funcao principal: executar scripts da trilha `application/app-prod` com placeholders de usuario APPLICATION do PROD.

### 9) `flyway-configuracao-validacao-app-dev.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-dev.conf`
- Tipo: configuracao de validacao de migrations no schema APPLICATION DEV
- Funcao principal: conectar com o usuario de aplicacao DEV e validar execucao da trilha `application/app-dev`.

### 10) `flyway-configuracao-validacao-app-hml.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-hml.conf`
- Tipo: configuracao de validacao de migrations no schema APPLICATION HML
- Funcao principal: conectar com o usuario de aplicacao HML e validar execucao da trilha `application/app-hml`.

### 11) `flyway-configuracao-validacao-app-prod.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-app-prod.conf`
- Tipo: configuracao de validacao de migrations no schema APPLICATION PROD
- Funcao principal: conectar com o usuario de aplicacao PROD e validar execucao da trilha `application/app-prod`.

### 12) `flyway-configuracao-validacao-owner-dev.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-dev.conf`
- Tipo: configuracao de validacao de migrations no schema OWNER DEV
- Funcao principal: conectar com o usuario owner DEV e validar execucao da trilha `owner/owner-dev`.

### 13) `flyway-configuracao-validacao-owner-hml.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-hml.conf`
- Tipo: configuracao de validacao de migrations no schema OWNER HML
- Funcao principal: conectar com o usuario owner HML e validar execucao da trilha `owner/owner-hml`.

### 14) `flyway-configuracao-validacao-owner-prod.conf`

- Caminho: `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-validacao-owner-prod.conf`
- Tipo: configuracao de validacao de migrations no schema OWNER PROD
- Funcao principal: conectar com o usuario owner PROD e validar execucao da trilha `owner/owner-prod`.

Configuracoes principais comuns aos arquivos `owner-*` e `app-*`:

- Conexao administrativa dedicada por arquivo: `flyway.url`, `flyway.user`, `flyway.password`.
- `flyway.jdbcProperties.internal_logon=SYSDBA`: login privilegiado quando aplicavel.
- `flyway.defaultSchema=${..._ADMIN_USER}`: schema padrao de execucao administrativa por ambiente.
- `flyway.table`: tabela de historico dedicada por contexto/ambiente (`flyway_history_owner_dev`, `flyway_history_owner_hml`, `flyway_history_owner_prod`, `flyway_history_app_dev`, `flyway_history_app_hml`, `flyway_history_app_prod`).
- `flyway.locations`: aponta para a trilha SQL correta do ambiente/tipo de usuario.
- `flyway.placeholders.*`: parametriza nome do usuario, senha e tablespaces para os scripts SQL.
- Nos arquivos `flyway-configuracao-validacao-app-*` e `flyway-configuracao-validacao-owner-*` foi adicionado `flyway.placeholders.ambiente` para registrar o nome logico do ambiente nas migrations de validacao.

## Relacao entre novos `.conf` e `.sql` de validacao

Esta secao mapeia os novos arquivos de configuracao de validacao para os scripts SQL executados em cada ambiente.

### APPLICATION

| Arquivo `.conf` | `flyway.locations` | Script SQL relacionado | Descricao |
| --- | --- | --- | --- |
| `flyway-configuracao-validacao-app-dev.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/application/app-dev` | `application/app-dev/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema APPLICATION no DEV. |
| `flyway-configuracao-validacao-app-hml.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/application/app-hml` | `application/app-hml/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema APPLICATION no HML. |
| `flyway-configuracao-validacao-app-prod.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/application/app-prod` | `application/app-prod/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema APPLICATION no PROD. |

### OWNER

| Arquivo `.conf` | `flyway.locations` | Script SQL relacionado | Descricao |
| --- | --- | --- | --- |
| `flyway-configuracao-validacao-owner-dev.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/owner/owner-dev` | `owner/owner-dev/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema OWNER no DEV. |
| `flyway-configuracao-validacao-owner-hml.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/owner/owner-hml` | `owner/owner-hml/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema OWNER no HML. |
| `flyway-configuracao-validacao-owner-prod.conf` | `filesystem:./sql/migrations/db/projects/controle-financeiro/owner/owner-prod` | `owner/owner-prod/V1__validacao_flyway_inicial.sql` | Valida a trilha de migration do schema OWNER no PROD. |

### Descricao dos novos scripts SQL

- `application/app-dev/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente DEV.
- `application/app-hml/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente HML.
- `application/app-prod/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente PROD.
- `owner/owner-dev/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente DEV.
- `owner/owner-hml/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente HML.
- `owner/owner-prod/V1__validacao_flyway_inicial.sql`: cria `TB_FLYWAY_TESTE` e insere registro de validacao no ambiente PROD.

## Observacoes

- O arquivo base `flyway-configuracao_base-controle-finaceiro.conf` nao define credenciais, `flyway.locations` fixas por ambiente, nem `flyway.table`.
- A definicao de ambiente (DEV/HML/PROD), conexao e localizacao de scripts fica nos arquivos complementares de usuarios (`dba-admin`, `owner-*`, `app-*`) e/ou pipeline.
- A tabela de historico do Flyway foi segregada por contexto para evitar conflito quando multiplas trilhas sao executadas com o mesmo usuario/schema administrativo.
- Novos arquivos `.conf` devem ser registrados neste documento, mantendo o historico funcional da configuracao.

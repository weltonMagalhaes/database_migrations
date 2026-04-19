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
- `flyway.sqlMigrationSuffix=.sql`: define extensao esperada dos scripts.
- `flyway.sqlMigrationSeparator=__`: separador entre versao e descricao.
- `flyway.table=flyway_controle_financeiro_history`: tabela de historico/control de versoes do Flyway.
- `flyway.installedBy=${MIGRATION_INSTALLED_BY}`: registra quem executou a migration.
- `flyway.cleanDisabled=true`: bloqueia o comando `clean` para reduzir risco de perda acidental de dados.
- `flyway.createSchemas=false`: nao cria schemas automaticamente.
- `flyway.outOfOrder=true`: permite execucao de migrations fora de ordem, util para correcoes pontuais.

## Observacoes

- Este arquivo nao define credenciais e nem `flyway.locations` de forma fixa para ambientes.
- A definicao de ambiente (DEV/HML/PROD), conexao e localizacao de scripts deve ficar em arquivos complementares por ambiente ou via pipeline.
- Novos arquivos `.conf` devem ser registrados neste documento, mantendo o historico funcional da configuracao.

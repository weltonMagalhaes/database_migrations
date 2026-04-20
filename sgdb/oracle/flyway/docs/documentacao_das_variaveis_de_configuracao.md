# Documentacao das Variaveis de Configuracao

Este arquivo lista as variaveis de configuracao ja citadas nos arquivos `.conf`
do projeto `controle-financeiro`, usadas pelo Flyway em execucoes administrativas
e de criacao/gestao de usuarios.

## Regras gerais

- Nunca versionar valores reais de secrets no repositorio.
- Definir os valores em variaveis do pipeline (ex.: GitHub Secrets/Actions).
- `ADMIN_*` e `MIGRATION_INSTALLED_BY` sao compartilhadas.
- `APP_*` e `OWNER_*` mudam por ambiente (`DEV`, `HML`, `PROD`).

## Variaveis identificadas no repositorio

### Compartilhadas

| Variavel | Escopo | Descricao |
| --- | --- | --- |
| `ADMIN_URL` | Geral | URL JDBC Oracle para conexao administrativa global. |
| `ADMIN_USER` | Geral | Usuario administrativo global (ex.: `SYS` no bootstrap). |
| `ADMIN_PASSWORD` | Geral | Senha do usuario administrativo global. |
| `MIGRATION_INSTALLED_BY` | Geral | Identificacao de quem executou a migration (`flyway.installedBy`). |

### APPLICATION por ambiente

| Variavel | Ambiente | Descricao |
| --- | --- | --- |
| `APP_DEV_ADMIN_URL` | DEV | URL JDBC para executar trilha APPLICATION com usuario admin. |
| `APP_DEV_ADMIN_USER` | DEV | Usuario admin para trilha APPLICATION. |
| `APP_DEV_ADMIN_PASSWORD` | DEV | Senha do usuario admin da trilha APPLICATION. |
| `APP_DEV_USER` | DEV | Nome do usuario APPLICATION a ser criado/gerenciado. |
| `APP_DEV_PASSWORD` | DEV | Senha do usuario APPLICATION. |
| `APP_DEV_DEFAULT_TABLESPACE` | DEV | Default tablespace do usuario APPLICATION. |
| `APP_DEV_TEMP_TABLESPACE` | DEV | Temporary tablespace do usuario APPLICATION. |
| `APP_HML_ADMIN_URL` | HML | URL JDBC para executar trilha APPLICATION com usuario admin. |
| `APP_HML_ADMIN_USER` | HML | Usuario admin para trilha APPLICATION. |
| `APP_HML_ADMIN_PASSWORD` | HML | Senha do usuario admin da trilha APPLICATION. |
| `APP_HML_USER` | HML | Nome do usuario APPLICATION a ser criado/gerenciado. |
| `APP_HML_PASSWORD` | HML | Senha do usuario APPLICATION. |
| `APP_HML_DEFAULT_TABLESPACE` | HML | Default tablespace do usuario APPLICATION. |
| `APP_HML_TEMP_TABLESPACE` | HML | Temporary tablespace do usuario APPLICATION. |
| `APP_PROD_ADMIN_URL` | PROD | URL JDBC para executar trilha APPLICATION com usuario admin. |
| `APP_PROD_ADMIN_USER` | PROD | Usuario admin para trilha APPLICATION. |
| `APP_PROD_ADMIN_PASSWORD` | PROD | Senha do usuario admin da trilha APPLICATION. |
| `APP_PROD_USER` | PROD | Nome do usuario APPLICATION a ser criado/gerenciado. |
| `APP_PROD_PASSWORD` | PROD | Senha do usuario APPLICATION. |
| `APP_PROD_DEFAULT_TABLESPACE` | PROD | Default tablespace do usuario APPLICATION. |
| `APP_PROD_TEMP_TABLESPACE` | PROD | Temporary tablespace do usuario APPLICATION. |

### OWNER por ambiente

| Variavel | Ambiente | Descricao |
| --- | --- | --- |
| `OWNER_DEV_ADMIN_URL` | DEV | URL JDBC para executar trilha OWNER com usuario admin. |
| `OWNER_DEV_ADMIN_USER` | DEV | Usuario admin para trilha OWNER. |
| `OWNER_DEV_ADMIN_PASSWORD` | DEV | Senha do usuario admin da trilha OWNER. |
| `OWNER_DEV_USER` | DEV | Nome do usuario OWNER a ser criado/gerenciado. |
| `OWNER_DEV_PASSWORD` | DEV | Senha do usuario OWNER. |
| `OWNER_DEV_DEFAULT_TABLESPACE` | DEV | Default tablespace do usuario OWNER. |
| `OWNER_DEV_TEMP_TABLESPACE` | DEV | Temporary tablespace do usuario OWNER. |
| `OWNER_HML_ADMIN_URL` | HML | URL JDBC para executar trilha OWNER com usuario admin. |
| `OWNER_HML_ADMIN_USER` | HML | Usuario admin para trilha OWNER. |
| `OWNER_HML_ADMIN_PASSWORD` | HML | Senha do usuario admin da trilha OWNER. |
| `OWNER_HML_USER` | HML | Nome do usuario OWNER a ser criado/gerenciado. |
| `OWNER_HML_PASSWORD` | HML | Senha do usuario OWNER. |
| `OWNER_HML_DEFAULT_TABLESPACE` | HML | Default tablespace do usuario OWNER. |
| `OWNER_HML_TEMP_TABLESPACE` | HML | Temporary tablespace do usuario OWNER. |
| `OWNER_PROD_ADMIN_URL` | PROD | URL JDBC para executar trilha OWNER com usuario admin. |
| `OWNER_PROD_ADMIN_USER` | PROD | Usuario admin para trilha OWNER. |
| `OWNER_PROD_ADMIN_PASSWORD` | PROD | Senha do usuario admin da trilha OWNER. |
| `OWNER_PROD_USER` | PROD | Nome do usuario OWNER a ser criado/gerenciado. |
| `OWNER_PROD_PASSWORD` | PROD | Senha do usuario OWNER. |
| `OWNER_PROD_DEFAULT_TABLESPACE` | PROD | Default tablespace do usuario OWNER. |
| `OWNER_PROD_TEMP_TABLESPACE` | PROD | Temporary tablespace do usuario OWNER. |

## Onde sao consumidas

- Arquivo base:
  `sgdb/oracle/flyway/conf/flyway-configuracao_base-controle-finaceiro.conf`
- Arquivos de usuarios:
  `sgdb/oracle/flyway/sql/migrations/db/projects/controle-financeiro/admin/users/flyway-configuracao-usuario-*.conf`
- Documentacao relacionada:
  `sgdb/oracle/flyway/docs/documentacao_arquivos_de_configuracao.md`

## Observacao de versionamento

- Nao versionar scripts locais de carga de secrets com valores reais.
- Se existir script utilitario como `set-github-secrets.ps1`, manter fora de commit.

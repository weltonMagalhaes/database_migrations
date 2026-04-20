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

## Como criar secrets no GitHub

### Opcao 1: via Browser (GitHub Web)

1. Acesse o repositorio no GitHub.
2. Abra `Settings` > `Secrets and variables` > `Actions`.
3. Clique em `New repository secret`.
4. Informe `Name` (ex.: `ADMIN_URL`) e `Secret` (valor real).
5. Clique em `Add secret`.
6. Repita para todas as variaveis desta documentacao.

Para secrets por ambiente (`DEV`, `HML`, `PROD`):

1. Em `Settings` > `Environments`, crie/abra o ambiente.
2. Dentro do ambiente, abra `Environment secrets`.
3. Clique em `Add secret`, informe nome/valor e salve.

### Opcao 2: via Actions Runner no Windows (PowerShell + GitHub CLI)

Pre-requisitos:

- `gh` (GitHub CLI) instalado no runner.
- Usuario autenticado com permissao de administrar secrets no repositorio.

Comandos iniciais:

```powershell
gh auth login
gh repo set-default <owner>/<repo>
```

Criar secrets de repositorio (exemplos):

```powershell
# O valor sera solicitado de forma interativa (nao aparece em tela)
gh secret set ADMIN_URL
gh secret set ADMIN_USER
gh secret set ADMIN_PASSWORD
gh secret set MIGRATION_INSTALLED_BY
```

Criar secret de ambiente (exemplo):

```powershell
gh secret set APP_DEV_ADMIN_URL --env DEV
gh secret set APP_HML_ADMIN_URL --env HML
gh secret set APP_PROD_ADMIN_URL --env PROD
```

Criacao em lote no PowerShell (ajuste a lista):

```powershell
$secrets = @(
  "ADMIN_URL",
  "ADMIN_USER",
  "ADMIN_PASSWORD",
  "MIGRATION_INSTALLED_BY",
  "APP_DEV_ADMIN_URL",
  "APP_DEV_ADMIN_USER",
  "APP_DEV_ADMIN_PASSWORD"
)

foreach ($name in $secrets) {
  gh secret set $name
}
```

Script completo (todas as variaveis do projeto):

```powershell
# 1) Secrets de repositorio (globais)
$repoSecrets = @(
  "ADMIN_URL",
  "ADMIN_USER",
  "ADMIN_PASSWORD",
  "MIGRATION_INSTALLED_BY"
)

foreach ($name in $repoSecrets) {
  gh secret set $name
}

# 2) Secrets por ambiente (APP_* e OWNER_*)
$environments = @("DEV", "HML", "PROD")
$grupos = @("APP", "OWNER")
$sufixos = @(
  "ADMIN_URL",
  "ADMIN_USER",
  "ADMIN_PASSWORD",
  "USER",
  "PASSWORD",
  "DEFAULT_TABLESPACE",
  "TEMP_TABLESPACE"
)

foreach ($env in $environments) {
  foreach ($grupo in $grupos) {
    foreach ($sufixo in $sufixos) {
      $name = "${grupo}_${env}_${sufixo}"
      gh secret set $name --env $env
    }
  }
}
```

### Opcao 3: via Actions Runner no Linux (Bash + GitHub CLI)

Pre-requisitos:

- `gh` instalado no runner.
- Usuario autenticado com permissao de administrar secrets no repositorio.

Comandos iniciais:

```bash
gh auth login
gh repo set-default <owner>/<repo>
```

Criar secrets de repositorio (exemplos):

```bash
gh secret set ADMIN_URL
gh secret set ADMIN_USER
gh secret set ADMIN_PASSWORD
gh secret set MIGRATION_INSTALLED_BY
```

Criar secret de ambiente (exemplo):

```bash
gh secret set APP_DEV_ADMIN_URL --env DEV
gh secret set APP_HML_ADMIN_URL --env HML
gh secret set APP_PROD_ADMIN_URL --env PROD
```

Criacao em lote no Bash (ajuste a lista):

```bash
secrets=(
  ADMIN_URL
  ADMIN_USER
  ADMIN_PASSWORD
  MIGRATION_INSTALLED_BY
  APP_DEV_ADMIN_URL
  APP_DEV_ADMIN_USER
  APP_DEV_ADMIN_PASSWORD
)

for name in "${secrets[@]}"; do
  gh secret set "$name"
done
```

Script completo (todas as variaveis do projeto):

```bash
# 1) Secrets de repositorio (globais)
repo_secrets=(
  ADMIN_URL
  ADMIN_USER
  ADMIN_PASSWORD
  MIGRATION_INSTALLED_BY
)

for name in "${repo_secrets[@]}"; do
  gh secret set "$name"
done

# 2) Secrets por ambiente (APP_* e OWNER_*)
environments=(DEV HML PROD)
groups=(APP OWNER)
suffixes=(
  ADMIN_URL
  ADMIN_USER
  ADMIN_PASSWORD
  USER
  PASSWORD
  DEFAULT_TABLESPACE
  TEMP_TABLESPACE
)

for env in "${environments[@]}"; do
  for group in "${groups[@]}"; do
    for suffix in "${suffixes[@]}"; do
      name="${group}_${env}_${suffix}"
      gh secret set "$name" --env "$env"
    done
  done
done
```

### Validacao rapida

- Listar secrets de repositorio:
  `gh secret list`
- Listar secrets de ambiente:
  `gh secret list --env DEV`
- Executar o workflow e validar se nao ha erro de variavel ausente.

## Observacao de versionamento

- Nao versionar scripts locais de carga de secrets com valores reais.
- Se existir script utilitario como `set-github-secrets.ps1`, manter fora de commit.

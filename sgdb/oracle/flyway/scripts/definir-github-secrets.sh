#!/usr/bin/env bash
# Script para definir GitHub Secrets via Bash (Linux)
# Requer: GitHub CLI (gh) instalado e autenticado.
#
# Uso:
#   1) gh auth login
#   2) gh repo set-default <owner>/<repo>
#   3) chmod +x ./sgdb/oracle/flyway/scripts/definir-github-secrets.sh
#   4) ./sgdb/oracle/flyway/scripts/definir-github-secrets.sh

set -euo pipefail

set_repo_secret() {
  local name="$1"
  local value="$2"
  echo "Definindo secret de repositorio: $name"
  gh secret set "$name" --body "$value"
}

set_env_secret() {
  local name="$1"
  local environment="$2"
  local value="$3"
  echo "Definindo secret de ambiente: $name (env: $environment)"
  gh secret set "$name" --env "$environment" --body "$value"
}

get_secret_value() {
  local name="$1"
  local value="${!name-}"

  if [[ -z "${value}" ]]; then
    echo "WARN: Variavel '${name}' nao encontrada no variaveis.env. Secret nao sera criada." >&2
    return 1
  fi

  if [[ "${value}" == \<FILL_* ]]; then
    echo "WARN: Variavel '${name}' esta com placeholder. Secret nao sera criada." >&2
    return 1
  fi

  printf '%s' "$value"
}

repo_secrets=(
  ADMIN_URL
  ADMIN_USER
  ADMIN_PASSWORD
  MIGRATION_INSTALLED_BY
)

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

echo "Iniciando definicao de GitHub Secrets..."

vars_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../conf/projects/controle-financeiro/env/variaveis.env"
if [[ ! -f "$vars_file" ]]; then
  echo "ERRO: arquivo de variaveis nao encontrado: $vars_file" >&2
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "$vars_file"
set +a

for name in "${repo_secrets[@]}"; do
  if value="$(get_secret_value "$name")"; then
    set_repo_secret "$name" "$value"
  fi
done

for env in "${environments[@]}"; do
  for group in "${groups[@]}"; do
    for suffix in "${suffixes[@]}"; do
      name="${group}_${env}_${suffix}"
      if value="$(get_secret_value "$name")"; then
        set_env_secret "$name" "$env" "$value"
      fi
    done
  done
done

echo "Concluido. Use 'gh secret list' e 'gh secret list --env DEV' para validar."

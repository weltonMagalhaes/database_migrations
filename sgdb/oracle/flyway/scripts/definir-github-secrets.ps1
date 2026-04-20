# Script para definir GitHub Secrets via PowerShell (Windows)
# Requer: GitHub CLI (gh) instalado e autenticado.
#
# Uso:
#   1) gh auth login
#   2) gh repo set-default <owner>/<repo>
#   3) .\sgdb\oracle\flyway\scripts\definir-github-secrets.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-SecretsFromEnvFile {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Arquivo de variaveis nao encontrado: $Path"
  }

  $map = @{}
  foreach ($rawLine in Get-Content -LiteralPath $Path) {
    $line = $rawLine.Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
      continue
    }

    $idx = $line.IndexOf("=")
    if ($idx -le 0) {
      Write-Warning "Linha invalida ignorada em variaveis.env: $line"
      continue
    }

    $name = $line.Substring(0, $idx).Trim()
    $value = $line.Substring($idx + 1).Trim()

    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
      $value = $value.Substring(1, $value.Length - 2)
    }

    $map[$name] = $value
  }

  return $map
}

function Get-SecretValue {
  param(
    [Parameter(Mandatory = $true)][hashtable]$Map,
    [Parameter(Mandatory = $true)][string]$Name
  )

  if (-not $Map.Contains($Name)) {
    Write-Warning "Variavel '$Name' nao encontrada no variaveis.env. Secret nao sera criada."
    return $null
  }

  $value = [string]$Map[$Name]
  if ([string]::IsNullOrWhiteSpace($value) -or $value -like "<FILL_*") {
    Write-Warning "Variavel '$Name' esta vazia/placeholder. Secret nao sera criada."
    return $null
  }

  return $value
}

function Set-RepoSecret {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Value
  )
  Write-Host "Definindo secret de repositorio: $Name"
  gh secret set $Name --body $Value
}

function Set-EnvSecret {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Environment,
    [Parameter(Mandatory = $true)][string]$Value
  )
  Write-Host "Definindo secret de ambiente: $Name (env: $Environment)"
  gh secret set $Name --env $Environment --body $Value
}

$repoSecrets = @(
  "ADMIN_URL",
  "ADMIN_USER",
  "ADMIN_PASSWORD",
  "MIGRATION_INSTALLED_BY"
)

$environments = @("DEV", "HML", "PROD")
$groups = @("APP", "OWNER")
$suffixes = @(
  "ADMIN_URL",
  "ADMIN_USER",
  "ADMIN_PASSWORD",
  "USER",
  "PASSWORD",
  "DEFAULT_TABLESPACE",
  "TEMP_TABLESPACE"
)

Write-Host "Iniciando definicao de GitHub Secrets..."

$varsFile = Join-Path $PSScriptRoot "..\\conf\\projects\\controle-financeiro\\env\\variaveis.env"
$varsFile = [System.IO.Path]::GetFullPath($varsFile)
$Secrets = Get-SecretsFromEnvFile -Path $varsFile

foreach ($name in $repoSecrets) {
  $value = Get-SecretValue -Map $Secrets -Name $name
  if ($null -ne $value) {
    Set-RepoSecret -Name $name -Value $value
  }
}

foreach ($env in $environments) {
  foreach ($group in $groups) {
    foreach ($suffix in $suffixes) {
      $name = "${group}_${env}_${suffix}"
      $value = Get-SecretValue -Map $Secrets -Name $name
      if ($null -ne $value) {
        Set-EnvSecret -Name $name -Environment $env -Value $value
      }
    }
  }
}

Write-Host "Concluido. Use 'gh secret list' e 'gh secret list --env DEV' para validar."

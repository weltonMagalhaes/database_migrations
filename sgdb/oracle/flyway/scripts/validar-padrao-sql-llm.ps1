[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FlywayConfigFile,

    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [Parameter(Mandatory = $true)]
    [string]$Ambiente,

    [string]$ProjectRoot = ".",
    [string]$RulesFilePath = "conf/sql-guard-rules.json",
    [string]$RuleGuidePath = "docs/padrao_sql_llm.md",
    [string]$LogFilePath = "logs/llm_sql_guard.log"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToBool {
    param(
        [AllowNull()][string]$Value,
        [bool]$Default = $false
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Default
    }

    $normalized = $Value.Trim().ToLowerInvariant()
    return $normalized -in @("1", "true", "yes", "y", "on")
}

function Get-FirstNonEmpty {
    param([string[]]$Values)

    foreach ($value in $Values) {
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }

    return $null
}

function Resolve-PathSafe {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$ChildPath
    )

    if ([System.IO.Path]::IsPathRooted($ChildPath)) {
        return [System.IO.Path]::GetFullPath($ChildPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $ChildPath))
}

function Get-RelativePathSafe {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)

    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)

    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', '\\')
}

function Get-LineNumberFromIndex {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$Index
    )

    if ($Index -le 0) {
        return 1
    }

    $slice = $Text.Substring(0, [Math]::Min($Index, $Text.Length))
    return ($slice -split "`n").Count
}

function New-Finding {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][int]$Line,
        [Parameter(Mandatory = $true)][string]$RuleId,
        [Parameter(Mandatory = $true)][string]$Severity,
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][string]$Suggestion,
        [Parameter(Mandatory = $true)][string]$Detector
    )

    return [PSCustomObject]@{
        file       = $File
        line       = $Line
        rule_id    = $RuleId
        severity   = $Severity
        message    = $Message
        suggestion = $Suggestion
        detector   = $Detector
    }
}

function Parse-FlywayLocations {
    param([Parameter(Mandatory = $true)][string]$ConfigPath)

    $content = Get-Content -Path $ConfigPath
    $line = $content | Where-Object { $_ -match '^\s*flyway\.locations\s*=' } | Select-Object -Last 1

    if (-not $line) {
        throw "Nao foi encontrada a chave flyway.locations em: $ConfigPath"
    }

    $value = ($line -split '=', 2)[1].Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "A chave flyway.locations esta vazia em: $ConfigPath"
    }

    $locations = @()
    foreach ($item in ($value -split ',')) {
        $loc = $item.Trim()
        if ($loc -like 'filesystem:*') {
            $loc = $loc.Substring('filesystem:'.Length)
        }
        if (-not [string]::IsNullOrWhiteSpace($loc)) {
            $locations += $loc
        }
    }

    return $locations
}

function Get-SqlFilesFromLocations {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRootPath,
        [Parameter(Mandatory = $true)][string[]]$Locations
    )

    $all = New-Object System.Collections.Generic.List[string]
    foreach ($location in $Locations) {
        $abs = Resolve-PathSafe -BasePath $ProjectRootPath -ChildPath $location
        if (-not (Test-Path -Path $abs)) {
            Write-Warning "Location nao encontrada para validacao: $abs"
            continue
        }

        Get-ChildItem -Path $abs -Recurse -File -Filter '*.sql' |
            Sort-Object FullName |
            ForEach-Object { [void]$all.Add($_.FullName) }
    }

    return $all | Select-Object -Unique
}

function Get-RuleRegex {
    param(
        [Parameter(Mandatory = $true)][object]$Rules,
        [Parameter(Mandatory = $true)][string]$RuleId,
        [Parameter(Mandatory = $true)][string]$Fallback
    )

    $rule = $Rules.rules | Where-Object { $_.id -eq $RuleId } | Select-Object -First 1
    if ($rule -and $rule.regex) {
        return [string]$rule.regex
    }

    return $Fallback
}

function Test-DeterministicSqlRules {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FileContent,
        [Parameter(Mandatory = $true)][object]$Rules,
        [Parameter(Mandatory = $true)][string]$ProjectRootPath
    )

    $findings = New-Object System.Collections.Generic.List[object]

    $tableRegex = Get-RuleRegex -Rules $Rules -RuleId 'table_name_tb_prefix' -Fallback '^TB_[A-Z0-9_]+$'
    $sequenceRegex = Get-RuleRegex -Rules $Rules -RuleId 'sequence_name_sq_prefix' -Fallback '^SQ_[A-Z0-9_]+$'
    $columnRegex = Get-RuleRegex -Rules $Rules -RuleId 'column_name_upper_snake' -Fallback '^[A-Z][A-Z0-9_]*$'

    $relativeFile = Get-RelativePathSafe -BasePath $ProjectRootPath -TargetPath $FilePath

    $createTablePattern = '(?is)\bCREATE\s+TABLE\s+("?([A-Za-z0-9_]+)"?)\s*\((.*?)\)\s*;'
    $tableMatches = [regex]::Matches($FileContent, $createTablePattern)

    foreach ($match in $tableMatches) {
        $tableNameRaw = $match.Groups[2].Value
        $tableName = $tableNameRaw.ToUpperInvariant()
        $line = Get-LineNumberFromIndex -Text $FileContent -Index $match.Index

        if ($tableName -notmatch $tableRegex) {
            [void]$findings.Add((New-Finding -File $relativeFile -Line $line -RuleId 'table_name_tb_prefix' -Severity 'error' -Message "Tabela '$tableNameRaw' fora do padrao." -Suggestion 'Use TB_ + UPPER_SNAKE_CASE.' -Detector 'deterministic'))
        }

        $columnsBlock = $match.Groups[3].Value
        $columnLines = $columnsBlock -split "`r?`n"
        $offset = 0
        foreach ($lineText in $columnLines) {
            $offset++
            $trim = $lineText.Trim()

            if ([string]::IsNullOrWhiteSpace($trim)) { continue }
            if ($trim.StartsWith('--')) { continue }
            if ($trim -match '^(CONSTRAINT|PRIMARY\s+KEY|FOREIGN\s+KEY|UNIQUE|CHECK|\))\b') { continue }
            if ($trim -notmatch '^("?([A-Za-z0-9_]+)"?)\s+') { continue }

            $columnRaw = $Matches[2]
            $columnName = $columnRaw.ToUpperInvariant()
            $columnLine = $line + $offset

            if ($columnName -notmatch $columnRegex) {
                [void]$findings.Add((New-Finding -File $relativeFile -Line $columnLine -RuleId 'column_name_upper_snake' -Severity 'error' -Message "Coluna '$columnRaw' fora do padrao." -Suggestion 'Use UPPER_SNAKE_CASE para nomes de colunas.' -Detector 'deterministic'))
            }
        }
    }

    $sequencePattern = '(?im)\bCREATE\s+SEQUENCE\s+("?([A-Za-z0-9_]+)"?)'
    $sequenceMatches = [regex]::Matches($FileContent, $sequencePattern)
    foreach ($sequenceMatch in $sequenceMatches) {
        $sequenceRaw = $sequenceMatch.Groups[2].Value
        $sequenceName = $sequenceRaw.ToUpperInvariant()
        $sequenceLine = Get-LineNumberFromIndex -Text $FileContent -Index $sequenceMatch.Index

        if ($sequenceName -notmatch $sequenceRegex) {
            [void]$findings.Add((New-Finding -File $relativeFile -Line $sequenceLine -RuleId 'sequence_name_sq_prefix' -Severity 'error' -Message "Sequence '$sequenceRaw' fora do padrao." -Suggestion 'Use SQ_ + UPPER_SNAKE_CASE.' -Detector 'deterministic'))
        }
    }

    return $findings
}

function Get-JsonFromMarkdown {
    param([Parameter(Mandatory = $true)][string]$Text)

    if ($Text -match '```json\s*(?<json>[\s\S]*?)```') {
        return $Matches['json']
    }

    if ($Text -match '```\s*(?<json>[\s\S]*?)```') {
        return $Matches['json']
    }

    return $Text
}

function Get-LlmProviderConfig {
    param([string]$Provider)

    $normalized = if ([string]::IsNullOrWhiteSpace($Provider)) { 'openai' } else { $Provider.Trim().ToLowerInvariant() }
    if ($normalized -eq 'geminai') {
        $normalized = 'gemini'
    }

    switch ($normalized) {
        'openai' {
            return [PSCustomObject]@{
                provider = 'openai'
                apiStyle = 'openai'
                defaultModel = 'gpt-5.4-mini'
                defaultBaseUrl = 'https://api.openai.com'
            }
        }
        'deepseek' {
            return [PSCustomObject]@{
                provider = 'deepseek'
                apiStyle = 'openai'
                defaultModel = 'deepseek-chat'
                defaultBaseUrl = 'https://api.deepseek.com'
            }
        }
        'gemini' {
            return [PSCustomObject]@{
                provider = 'gemini'
                apiStyle = 'gemini'
                defaultModel = 'gemini-1.5-flash'
                defaultBaseUrl = 'https://generativelanguage.googleapis.com'
            }
        }
        default {
            Write-Warning "LLM_PROVIDER '$Provider' nao reconhecido. Usando 'openai'."
            return [PSCustomObject]@{
                provider = 'openai'
                apiStyle = 'openai'
                defaultModel = 'gpt-5.4-mini'
                defaultBaseUrl = 'https://api.openai.com'
            }
        }
    }
}

function Invoke-OpenAiCompatibleReview {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [Parameter(Mandatory = $true)][string]$Model,
        [Parameter(Mandatory = $true)][string]$BaseUrl,
        [Parameter(Mandatory = $true)][string]$ApiKey
    )

    $payload = @{
        model       = $Model
        temperature = 0
        messages    = @(
            @{ role = 'system'; content = 'You are a SQL standards reviewer. Return only JSON.' },
            @{ role = 'user'; content = $Prompt }
        )
    }

    $uri = $BaseUrl.TrimEnd('/') + '/v1/chat/completions'
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ Authorization = "Bearer $ApiKey" } -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10)
    return [string]$response.choices[0].message.content
}

function Invoke-GeminiReview {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [Parameter(Mandatory = $true)][string]$Model,
        [Parameter(Mandatory = $true)][string]$BaseUrl,
        [Parameter(Mandatory = $true)][string]$ApiKey
    )

    $payload = @{
        contents = @(
            @{
                role = 'user'
                parts = @(
                    @{ text = $Prompt }
                )
            }
        )
        generationConfig = @{
            temperature = 0
        }
    }

    $encodedModel = [System.Uri]::EscapeDataString($Model)
    $encodedKey = [System.Uri]::EscapeDataString($ApiKey)
    $uri = "{0}/v1beta/models/{1}:generateContent?key={2}" -f $BaseUrl.TrimEnd('/'), $encodedModel, $encodedKey

    $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10)

    if (-not $response.candidates) {
        return $null
    }

    $first = $response.candidates | Select-Object -First 1
    if (-not $first.content -or -not $first.content.parts) {
        return $null
    }

    return (($first.content.parts | ForEach-Object { $_.text }) -join "`n")
}

function Invoke-LlmReview {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FileContent,
        [Parameter(Mandatory = $true)][string]$ProjectRootPath,
        [Parameter(Mandatory = $true)][string]$RuleGuideText,
        [Parameter(Mandatory = $true)][object]$Rules,
        [Parameter(Mandatory = $true)][string]$Provider,
        [Parameter(Mandatory = $true)][string]$ApiStyle,
        [Parameter(Mandatory = $true)][string]$Model,
        [Parameter(Mandatory = $true)][string]$BaseUrl,
        [Parameter(Mandatory = $true)][string]$ApiKey
    )

    $findings = New-Object System.Collections.Generic.List[object]
    $relativeFile = Get-RelativePathSafe -BasePath $ProjectRootPath -TargetPath $FilePath

    $prompt = @"
Review the SQL file against the project SQL standard.

Return strictly JSON with this schema:
{
  "findings": [
    {
      "rule_id": "string",
      "severity": "error|warning",
      "message": "string",
      "suggestion": "string",
      "line": 1
    }
  ]
}

Rules guide:
$RuleGuideText

Rules JSON:
$($Rules | ConvertTo-Json -Depth 8)

SQL file path: $relativeFile
SQL content:
$FileContent
"@

    try {
        $raw = $null
        if ($ApiStyle -eq 'gemini') {
            $raw = Invoke-GeminiReview -Prompt $prompt -Model $Model -BaseUrl $BaseUrl -ApiKey $ApiKey
        }
        else {
            $raw = Invoke-OpenAiCompatibleReview -Prompt $prompt -Model $Model -BaseUrl $BaseUrl -ApiKey $ApiKey
        }

        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $findings
        }

        $jsonText = Get-JsonFromMarkdown -Text $raw
        $parsed = $jsonText | ConvertFrom-Json

        if (-not $parsed.findings) {
            return $findings
        }

        foreach ($item in $parsed.findings) {
            $line = 1
            if ($item.line -and $item.line -as [int]) {
                $line = [int]$item.line
            }

            $severity = 'warning'
            if ($item.severity) {
                $severity = [string]$item.severity
            }

            [void]$findings.Add((New-Finding -File $relativeFile -Line $line -RuleId ([string]$item.rule_id) -Severity $severity -Message ([string]$item.message) -Suggestion ([string]$item.suggestion) -Detector ("llm:{0}" -f $Provider)))
        }
    }
    catch {
        Write-Warning "Falha na revisao LLM para '$relativeFile' (provider=$Provider): $($_.Exception.Message)"
    }

    return $findings
}

$projectRootPath = (Resolve-Path $ProjectRoot).Path
$flywayConfPath = Resolve-PathSafe -BasePath $projectRootPath -ChildPath $FlywayConfigFile
$rulesPath = Resolve-PathSafe -BasePath $projectRootPath -ChildPath $RulesFilePath
$guidePath = Resolve-PathSafe -BasePath $projectRootPath -ChildPath $RuleGuidePath
$logPath = Resolve-PathSafe -BasePath $projectRootPath -ChildPath $LogFilePath

if (-not (Test-Path -Path $flywayConfPath)) {
    throw "Arquivo de configuracao Flyway nao encontrado: $flywayConfPath"
}
if (-not (Test-Path -Path $rulesPath)) {
    throw "Arquivo de regras nao encontrado: $rulesPath"
}
if (-not (Test-Path -Path $guidePath)) {
    throw "Arquivo guia de padrao nao encontrado: $guidePath"
}

$rules = Get-Content -Path $rulesPath -Raw | ConvertFrom-Json
$guideText = Get-Content -Path $guidePath -Raw

$allowOverride = Convert-ToBool -Value $env:SQL_GUARD_ALLOW_OVERRIDE -Default $false
$llmEnabled = Convert-ToBool -Value $env:SQL_GUARD_LLM_ENABLED -Default $false

$providerConfig = Get-LlmProviderConfig -Provider $env:LLM_PROVIDER
$llmProvider = $providerConfig.provider
$llmApiStyle = $providerConfig.apiStyle
$llmModel = Get-FirstNonEmpty -Values @($env:LLM_MODEL, $env:OPENAI_MODEL, $providerConfig.defaultModel)
$llmBaseUrl = Get-FirstNonEmpty -Values @($env:LLM_BASE_URL, $env:OPENAI_BASE_URL, $providerConfig.defaultBaseUrl)
$llmApiKey = Get-FirstNonEmpty -Values @($env:LLM_API_KEY, $env:OPENAI_API_KEY, $env:GEMINI_API_KEY)

if ($llmEnabled -and [string]::IsNullOrWhiteSpace($llmApiKey)) {
    Write-Warning 'SQL_GUARD_LLM_ENABLED=true, mas nenhuma chave foi informada (LLM_API_KEY/OPENAI_API_KEY/GEMINI_API_KEY). Revisao LLM sera ignorada.'
    $llmEnabled = $false
}

$locations = Parse-FlywayLocations -ConfigPath $flywayConfPath
$sqlFiles = @(Get-SqlFilesFromLocations -ProjectRootPath $projectRootPath -Locations $locations)

Write-Host "SQL guard: dominio=$Domain ambiente=$Ambiente arquivos=$($sqlFiles.Count) provider=$llmProvider"

$allFindings = New-Object System.Collections.Generic.List[object]

foreach ($file in $sqlFiles) {
    $content = Get-Content -Path $file -Raw

    $deterministicFindings = Test-DeterministicSqlRules -FilePath $file -FileContent $content -Rules $rules -ProjectRootPath $projectRootPath
    foreach ($f in $deterministicFindings) {
        [void]$allFindings.Add($f)
    }

    if ($llmEnabled) {
        $llmFindings = Invoke-LlmReview -FilePath $file -FileContent $content -ProjectRootPath $projectRootPath -RuleGuideText $guideText -Rules $rules -Provider $llmProvider -ApiStyle $llmApiStyle -Model $llmModel -BaseUrl $llmBaseUrl -ApiKey $llmApiKey
        foreach ($f in $llmFindings) {
            [void]$allFindings.Add($f)
        }
    }
}

$deduped = @(
    $allFindings |
    Group-Object -Property { "{0}|{1}|{2}|{3}" -f $_.file, $_.line, $_.rule_id, $_.message } |
    ForEach-Object { $_.Group | Select-Object -First 1 }
)

$blocking = @($deduped | Where-Object { $_.severity -eq 'error' })

foreach ($finding in $deduped) {
    $level = if ($finding.severity -eq 'error') { 'error' } else { 'warning' }
    Write-Host "::$level file=$($finding.file),line=$($finding.line)::[$($finding.rule_id)] $($finding.message) | sugestao: $($finding.suggestion) | detector: $($finding.detector)"
}

$decision = 'pass'
if ($blocking.Count -gt 0 -and -not $allowOverride) {
    $decision = 'blocked'
}
elseif ($blocking.Count -gt 0 -and $allowOverride) {
    $decision = 'override_accepted'
}

$logDir = Split-Path -Path $logPath -Parent
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

$logEntry = [PSCustomObject]@{
    timestamp_utc       = (Get-Date).ToUniversalTime().ToString('o')
    domain              = $Domain
    ambiente            = $Ambiente
    flyway_config       = Get-RelativePathSafe -BasePath $projectRootPath -TargetPath $flywayConfPath
    locations           = $locations
    files_scanned       = @($sqlFiles | ForEach-Object { Get-RelativePathSafe -BasePath $projectRootPath -TargetPath $_ })
    findings_total      = $deduped.Count
    findings_blocking   = $blocking.Count
    override_used       = $allowOverride
    llm_enabled         = $llmEnabled
    llm_provider        = if ($llmEnabled) { $llmProvider } else { $null }
    llm_model           = if ($llmEnabled) { $llmModel } else { $null }
    llm_base_url        = if ($llmEnabled) { $llmBaseUrl } else { $null }
    decision            = $decision
    findings            = $deduped
}

Add-Content -Path $logPath -Value ($logEntry | ConvertTo-Json -Depth 12 -Compress) -Encoding UTF8

if ($decision -eq 'blocked') {
    Write-Error "SQL guard bloqueou a execucao. Encontradas $($blocking.Count) violacoes de padrao."
    exit 2
}

if ($decision -eq 'override_accepted') {
    Write-Warning "SQL guard encontrou $($blocking.Count) violacoes, mas override esta habilitado. Execucao permitida e log registrada."
}

Write-Host "SQL guard finalizado com decisao: $decision"
exit 0

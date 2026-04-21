# Padrao SQL para Guard LLM (PoC)

Este arquivo define o padrao minimo para scripts SQL de migration no projeto.
A validacao e executada pelo script `scripts/validar-padrao-sql-llm.ps1`.

## Objetivo

Garantir consistencia de nomenclatura de objetos SQL e reduzir drift de padrao entre migrations.

## Regras obrigatorias

1. Nome de tabela: `TB_` + `UPPER_SNAKE_CASE`.
- Exemplo valido: `TB_TRANSACAO_FINANCEIRA`
- Exemplo invalido: `transacao`, `tbTransacao`

2. Nome de sequence: `SQ_` + `UPPER_SNAKE_CASE`.
- Exemplo valido: `SQ_TRANSACAO_FINANCEIRA`
- Exemplo invalido: `SEQ_TRANSACAO`, `sequenceTransacao`

3. Nome de colunas: `UPPER_SNAKE_CASE`.
- Exemplo valido: `ID`, `DATA_CRIACAO`, `VL_TOTAL`
- Exemplo invalido: `dataCriacao`, `valor-total`

4. Arquivos SQL fora da convencao sao bloqueados por padrao no pipeline.

## Politica de override

Se houver violacao e for necessario seguir fora do padrao temporariamente:

1. Defina `SQL_GUARD_ALLOW_OVERRIDE=true` no ambiente.
2. O pipeline continua a execucao.
3. O guard registra o evento em `logs/llm_sql_guard.log` com os motivos e findings.

## Uso de LLM

Quando habilitado (`SQL_GUARD_LLM_ENABLED=true`) e com `OPENAI_API_KEY` configurada:

1. O guard chama a API para revisao complementar.
2. A decisao final continua baseada nas regras deterministicas + politica de override.
3. Findings da LLM entram no mesmo log para auditoria.

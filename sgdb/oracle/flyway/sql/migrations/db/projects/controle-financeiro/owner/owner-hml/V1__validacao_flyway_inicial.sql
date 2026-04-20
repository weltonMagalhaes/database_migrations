/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@author         : Welton Magalhaes de Oliveira
@email          : welton.m.o@hotmail.com
@data-criacao   : 20-04-2026
@database       : HML

Descricao:
Tabela inicial criada apenas para validacao do versionamento com Flyway.
Esta migration tem como objetivo garantir que a estrutura de migrations,
configuracao e execucao estejam funcionando corretamente no ambiente HML.

=======================================================================================*/

-- Tabela de teste inicial (validacao do Flyway)
CREATE TABLE TB_FLYWAY_TESTE (
    ID NUMBER PRIMARY KEY,
    DESCRICAO VARCHAR2(100)
);

-- Insercao de registro de teste
INSERT INTO TB_FLYWAY_TESTE (ID, DESCRICAO)
VALUES (1, 'Tabela de teste inicial (validacao do Flyway) - HML');

COMMIT;

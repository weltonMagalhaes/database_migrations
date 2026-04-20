/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@author         : Welton Magalhaes de Oliveira
@email          : welton.m.o@hotmail.com
@data-criacao   : 20-04-2026
@ambiente       : DEV
@dominio        : OWNER

Descricao:
Provisiona o usuario OWNER do ambiente DEV.
Se o usuario nao existir, cria. Se existir, atualiza senha/tablespaces e desbloqueia.

=======================================================================================*/

DECLARE
    v_usuario_existe NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_usuario_existe
      FROM dba_users
     WHERE username = UPPER('${usuario_nome}');

    IF v_usuario_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ${usuario_nome} IDENTIFIED BY "${usuario_senha}" ' ||
                          'DEFAULT TABLESPACE ${default_tablespace} TEMPORARY TABLESPACE ${temp_tablespace}';
    ELSE
        EXECUTE IMMEDIATE 'ALTER USER ${usuario_nome} IDENTIFIED BY "${usuario_senha}"';
        EXECUTE IMMEDIATE 'ALTER USER ${usuario_nome} DEFAULT TABLESPACE ${default_tablespace} TEMPORARY TABLESPACE ${temp_tablespace}';
    END IF;

    EXECUTE IMMEDIATE 'ALTER USER ${usuario_nome} ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${usuario_nome}';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ${usuario_nome}';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO ${usuario_nome}';
    EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO ${usuario_nome}';
    EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO ${usuario_nome}';
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO ${usuario_nome}';
END;
/

COMMIT;

/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@ambiente       : PROD
@dominio        : OWNER

Descricao:
Migration repeatable para garantir que o usuario OWNER PROD exista e esteja
com senha/tablespaces/permissoes sincronizados com os placeholders do pipeline.

=======================================================================================*/

-- Forca reexecucao em todo migrate para reconciliar senha e grants.
-- ${flyway:timestamp}

DECLARE
    v_usuario_existe NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_usuario_existe
      FROM dba_users
     WHERE username = UPPER('${OWNER_PROD_USER}');

    IF v_usuario_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ${OWNER_PROD_USER} IDENTIFIED BY "${OWNER_PROD_PASSWORD}" ' ||
                          'DEFAULT TABLESPACE ${OWNER_PROD_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${OWNER_PROD_TEMP_TABLESPACE}';
    ELSE
        EXECUTE IMMEDIATE 'ALTER USER ${OWNER_PROD_USER} IDENTIFIED BY "${OWNER_PROD_PASSWORD}"';
        EXECUTE IMMEDIATE 'ALTER USER ${OWNER_PROD_USER} DEFAULT TABLESPACE ${OWNER_PROD_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${OWNER_PROD_TEMP_TABLESPACE}';
    END IF;

    EXECUTE IMMEDIATE 'ALTER USER ${OWNER_PROD_USER} ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${OWNER_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ${OWNER_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO ${OWNER_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO ${OWNER_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO ${OWNER_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO ${OWNER_PROD_USER}';
END;
/

COMMIT;


/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@ambiente       : PROD
@dominio        : APPLICATION

Descricao:
Migration repeatable para garantir que o usuario APPLICATION PROD exista e esteja
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
     WHERE username = UPPER('${APP_PROD_USER}');

    IF v_usuario_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ${APP_PROD_USER} IDENTIFIED BY "${APP_PROD_PASSWORD}" ' ||
                          'DEFAULT TABLESPACE ${APP_PROD_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_PROD_TEMP_TABLESPACE}';
    ELSE
        EXECUTE IMMEDIATE 'ALTER USER ${APP_PROD_USER} IDENTIFIED BY "${APP_PROD_PASSWORD}"';
        EXECUTE IMMEDIATE 'ALTER USER ${APP_PROD_USER} DEFAULT TABLESPACE ${APP_PROD_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_PROD_TEMP_TABLESPACE}';
    END IF;

    EXECUTE IMMEDIATE 'ALTER USER ${APP_PROD_USER} ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${APP_PROD_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ${APP_PROD_USER}';
END;
/

COMMIT;


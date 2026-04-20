/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@ambiente       : DEV
@dominio        : APPLICATION

Descricao:
Migration repeatable para garantir que o usuario APPLICATION DEV exista e esteja
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
     WHERE username = UPPER('${APP_DEV_USER}');

    IF v_usuario_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ${APP_DEV_USER} IDENTIFIED BY "${APP_DEV_PASSWORD}" ' ||
                          'DEFAULT TABLESPACE ${APP_DEV_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_DEV_TEMP_TABLESPACE}';
    ELSE
        EXECUTE IMMEDIATE 'ALTER USER ${APP_DEV_USER} IDENTIFIED BY "${APP_DEV_PASSWORD}"';
        EXECUTE IMMEDIATE 'ALTER USER ${APP_DEV_USER} DEFAULT TABLESPACE ${APP_DEV_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_DEV_TEMP_TABLESPACE}';
    END IF;

    EXECUTE IMMEDIATE 'ALTER USER ${APP_DEV_USER} ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${APP_DEV_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ${APP_DEV_USER}';
END;
/

COMMIT;


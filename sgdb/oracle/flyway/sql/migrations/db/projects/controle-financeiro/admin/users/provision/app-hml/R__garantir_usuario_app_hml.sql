/*=======================================================================================

@versao         : Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
@ambiente       : HML
@dominio        : APPLICATION

Descricao:
Migration repeatable para garantir que o usuario APPLICATION HML exista e esteja
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
     WHERE username = UPPER('${APP_HML_USER}');

    IF v_usuario_existe = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ${APP_HML_USER} IDENTIFIED BY "${APP_HML_PASSWORD}" ' ||
                          'DEFAULT TABLESPACE ${APP_HML_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_HML_TEMP_TABLESPACE}';
    ELSE
        EXECUTE IMMEDIATE 'ALTER USER ${APP_HML_USER} IDENTIFIED BY "${APP_HML_PASSWORD}"';
        EXECUTE IMMEDIATE 'ALTER USER ${APP_HML_USER} DEFAULT TABLESPACE ${APP_HML_DEFAULT_TABLESPACE} TEMPORARY TABLESPACE ${APP_HML_TEMP_TABLESPACE}';
    END IF;

    EXECUTE IMMEDIATE 'ALTER USER ${APP_HML_USER} ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE 'ALTER USER ${APP_HML_USER} QUOTA UNLIMITED ON ${APP_HML_DEFAULT_TABLESPACE}';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${APP_HML_USER}';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ${APP_HML_USER}';
END;
/

COMMIT;


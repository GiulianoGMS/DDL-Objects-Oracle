CREATE OR REPLACE PROCEDURE NAGP_LIB_PROG_FIN (psNroEmpresa NUMBER, psNroTitulo NUMBER)

  IS
  
  psUsuarioLiberacao VARCHAR2(4000);
  
  BEGIN
    
  SELECT SYS_CONTEXT ('USERENV','CLIENT_IDENTIFIER')
    INTO psUsuarioLiberacao
    FROM DUAL;
    
  INSERT INTO NAGT_LIB_CRIT_PROG VALUES (psNroEmpresa, psNroTitulo, SYSDATE, psUsuarioLiberacao);
  
  COMMIT;
  
  END;

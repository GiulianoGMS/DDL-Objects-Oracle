CREATE OR REPLACE PROCEDURE NAGP_UPD_CONTROLE_SELOS_PDV (psNroEmpresa  VARCHAR2, 
                                                         psNroCheckout NUMBER, 
                                                         psSeqTurno    NUMBER, 
                                                         psDataMovto   DATE, 
                                                         psSeloInicial NUMBER, 
                                                         psSeloFinal   NUMBER,
                                                         psOperacao    VARCHAR2)
                                                         
 IS
 
  vlDiferenca NUMBER(10);
  psUsuarioLogado VARCHAR2 (300);
  psDecodeOperacao VARCHAR2(1);
 
 BEGIN
   
   vlDiferenca := psSeloFinal - psSeloInicial;  
   
   SELECT DECODE(psOperacao, 'Ajuste', 'A', 'Estorno de Ajuste', 'E') 
     INTO psDecodeOperacao
     FROM DUAL;
   
   SELECT SYS_CONTEXT ('USERENV','CLIENT_IDENTIFIER')
     INTO psUsuarioLogado
     FROM DUAL;
     
   IF psDecodeOperacao = 'A' THEN
 
   UPDATE NAGT_CONTROLE_SELOS_PDV X SET X.SELO_INICIAL = psSeloInicial,
                                        X.SELO_FINAL   = psSeloFinal,
                                        X.DIFERENCA    = X.DIFERENCA - vlDiferenca,
                                        X.DTAAJUSTE    = SYSDATE,
                                        X.USUAJUSTE    = psUsuarioLogado
                                        
                                  WHERE X.NROEMPRESA   = psNroEmpresa
                                    AND X.NROCHECKOUT  = psNroCheckout
                                    AND X.SEQTURNO     = psSeqTurno
                                    AND X.DTAMOVIMENTO = psDataMovto
                                    AND X.SELO_INICIAL = 'TURNO_ABERTO';
                                    
    IF SQL%ROWCOUNT > 0 THEN -- Se atualizou, grava log
                                    
    INSERT INTO NAGT_CONTROLE_SELOS_PDV_LOG VALUES(psNroEmpresa, psNroCheckout, psSeqTurno, psDataMovto, psSeloInicial, psSeloFinal, psUsuarioLogado, SYSDATE, psOperacao);
    
    END IF;
                                    
   ELSIF psDecodeOperacao = 'E' THEN
     
   UPDATE NAGT_CONTROLE_SELOS_PDV X SET X.SELO_INICIAL = 'TURNO_ABERTO',
                                        X.SELO_FINAL   = 'TURNO_ABERTO',
                                        X.DIFERENCA    = X.DIFERENCA + (SELO_FINAL - SELO_INICIAL),
                                        X.USUAJUSTE = NULL,
                                        X.DTAAJUSTE = NULL
                                        
                                  WHERE X.NROEMPRESA   = psNroEmpresa
                                    AND X.NROCHECKOUT  = psNroCheckout
                                    AND X.SEQTURNO     = psSeqTurno
                                    AND X.DTAMOVIMENTO = psDataMovto
                                    AND X.USUAJUSTE IS NOT NULL;
                                    
    IF SQL%ROWCOUNT > 0 THEN -- Se atualizou, grava log
                                    
    INSERT INTO NAGT_CONTROLE_SELOS_PDV_LOG VALUES(psNroEmpresa, psNroCheckout, psSeqTurno, psDataMovto, NULL, NULL, psUsuarioLogado, SYSDATE, psOperacao);
    
    END IF;
   
   END IF;
   
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
 END;

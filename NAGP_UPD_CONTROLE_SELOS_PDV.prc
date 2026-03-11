CREATE OR REPLACE PROCEDURE NAGP_UPD_CONTROLE_SELOS_PDV (psNroEmpresa  VARCHAR2,
                                                         psNroCheckout NUMBER,
                                                         psSeqTurno    NUMBER,
                                                         psDataMovto   DATE,
                                                         psSeloInicial NUMBER,
                                                         psSeloFinal   NUMBER,
                                                         psOperacao    VARCHAR2,
                                                         psSeloNro     VARCHAR2
)
IS

    psUsuarioLogado   VARCHAR2(300);
    psDecodeOperacao  VARCHAR2(1);

    vSQL              CLOB;
    vColunaInicial    VARCHAR2(30);
    vColunaFinal      VARCHAR2(30);
    
    vlSeloNro         NUMBER(1);

    vlCountBalcao     NUMBER(10);
    
BEGIN  
   
    SELECT DECODE(psOperacao, 'Ajuste', 'A', 'Estorno de Ajuste', 'E', 'Selo do Balcao', 'B')
      INTO psDecodeOperacao
      FROM DUAL;

    SELECT SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
      INTO psUsuarioLogado
      FROM DUAL;

    SELECT TO_NUMBER(SUBSTR(psSeloNro,6,1))
      INTO vlSeloNro
      FROM DUAL;

    /* define as colunas dinamicas */
    
    IF vlSeloNro = '1' THEN
        vColunaInicial := 'SELO_INICIAL';
        vColunaFinal   := 'SELO_FINAL';
    ELSE
        vColunaInicial := 'SELO_INICIAL' || vlSeloNro;
        vColunaFinal   := 'SELO_FINAL'   || vlSeloNro;
    END IF;


    IF psDecodeOperacao = 'A' THEN

        vSQL := '
            UPDATE NAGT_CONTROLE_SELOS_PDV_v2 X
               SET X.'||vColunaInicial||' = :1,
                   X.'||vColunaFinal||'   = :2,
                   X.DTAAJUSTE           = SYSDATE,
                   X.USUARIOAJUSTE       = :3
             WHERE X.NROEMPRESA   = :4
               AND X.NROCHECKOUT  = :5
               AND X.SEQTURNO     = :6
               AND X.DTAMOVIMENTO = :7
               AND (X.'||vColunaFinal||' IS NULL AND X.'||vColunaFinal||' IS NULL OR ABS(X.'||NVL(vColunaFinal,0)||' - X.'||NVL(vColunaInicial,0)||') > 2000)';

        EXECUTE IMMEDIATE vSQL
        USING psSeloInicial,
              psSeloFinal,
              psUsuarioLogado,
              psNroEmpresa,
              psNroCheckout,
              psSeqTurno,
              psDataMovto;

        IF SQL%ROWCOUNT > 0 THEN

            INSERT INTO NAGT_CONTROLE_SELOS_PDV_LOG
            VALUES (
                psNroEmpresa,
                psNroCheckout,
                psSeqTurno,
                psDataMovto,
                psSeloInicial,
                psSeloFinal,
                psUsuarioLogado,
                SYSDATE,
                psOperacao,
                psSeloNro
            );

        END IF;

    ELSIF psDecodeOperacao = 'E' THEN

        vSQL := '
                UPDATE NAGT_CONTROLE_SELOS_PDV_v2 X
                   SET X.'||vColunaInicial||' = NULL,
                       X.'||vColunaFinal||'   = NULL
                 WHERE X.NROEMPRESA   = :1
                   AND X.NROCHECKOUT  = :2
                   AND X.SEQTURNO     = :3
                   AND X.DTAMOVIMENTO = :4
                   AND X.USUARIOAJUSTE IS NOT NULL
                   AND EXISTS (
                        SELECT 1
                          FROM NAGT_CONTROLE_SELOS_PDV_LOG L
                         WHERE L.NROEMPRESA   = X.NROEMPRESA
                           AND L.NROCHECKOUT  = X.NROCHECKOUT
                           AND L.SEQTURNO     = X.SEQTURNO
                           AND L.DTAMOVIMENTO = X.DTAMOVIMENTO
                           AND L.SELO_NRO     = :5
                   )';
        EXECUTE IMMEDIATE vSQL
        USING psNroEmpresa,
              psNroCheckout,
              psSeqTurno,
              psDataMovto,
              psSeloNro;

        IF SQL%ROWCOUNT > 0 THEN

            INSERT INTO NAGT_CONTROLE_SELOS_PDV_LOG
            VALUES (
                psNroEmpresa,
                psNroCheckout,
                psSeqTurno,
                psDataMovto,
                NULL,
                NULL,
                psUsuarioLogado,
                SYSDATE,
                psOperacao,
                psSeloNro
            );

        END IF;

    ELSIF psDecodeOperacao = 'B' THEN
      
    SELECT COUNT(1) 
      INTO vlCountBalcao
      FROM NAGT_CONTROLE_SELOS_PDV_v2 X
     WHERE X.NROEMPRESA = psNroEmpresa
       AND X.NROCHECKOUT = 999
       AND X.DTAMOVIMENTO = psDataMovto;
       
    IF vlCountBalcao = 0 THEN
      
    INSERT INTO NAGT_CONTROLE_SELOS_PDV_v2 (Dtaajuste, Usuarioajuste, Nroempresa, Nrocheckout, Seqturno, Selos_Aceitos, Selos_Recusados, Selo_Inicial, Selo_Final, Dtamovimento, Operador, Nome_Operador)
                                    VALUES (SYSDATE, psUsuarioLogado, TO_NUMBER(psNroEmpresa), 999, 1, (psSeloFinal - psSeloInicial) +1, 0, psSeloInicial, psSeloFinal, psDataMovto, 999, 'Balcao');
    
    END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;

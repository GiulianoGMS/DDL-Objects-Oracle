CREATE TABLE NAGT_DEPARA_CCT_CONDICAO (SEQCENARIO NUMBER(3), IDENTIFICADOR VARCHAR2(100));

SELECT * FROM NAGT_DEPARA_CCT_CONDICAO;

CREATE OR REPLACE PROCEDURE NAGP_CCT_CONDICAO_PORTAL (psSeqCenario NUMBER, psValor NUMBER)

  IS psCount NUMBER;
     psSeqCenCondicao NUMBER;

BEGIN

   SELECT COUNT(1)
     INTO psCount
     FROM CCT_CENARIOCONDICAOITEM X WHERE X.VALOR = psValor AND X.SEQCENARIO = psSeqCenario;

   IF psCount = 0 THEN

   SELECT MAX(SEQCENARIOCONDICAO)
     INTO psSeqCenCondicao
     FROM CCT_CENARIOCONDICAOITEM X WHERE X.SEQCENARIO = psSeqCenario;

   IF psSeqCenCondicao > 0 AND psValor != 0 THEN

   FOR bs IN (SELECT S_CCT_CENARIOCONDICAOITEM.NEXTVAL SeqCenarioItem, psSeqCenCondicao SeqCondicao, psValor VALOR, 'N' IndTipoEntidade, SYSDATE DTAHORINCLUSAO, 'PORTAL' USUINCLUSAO, NULL NROBASEEXPORTACAO, psSeqCenario SEQCENARIO, dp.IDENTIFICADOR
                FROM NAGT_DEPARA_CCT_CONDICAO DP WHERE DP.SEQCENARIO = psSeqCenario)
    LOOP
      INSERT INTO CCT_CENARIOCONDICAOITEM VALUES (bs.SeqCenarioItem, bs.SeqCondicao, bs.Valor, bs.IndTipoEntidade, bs.Dtahorinclusao, bs.Usuinclusao, bs.Nrobaseexportacao, bs.Seqcenario, bs.Identificador);
      INSERT INTO CCT_CENARIOITEM VALUES (bs.Seqcenario,
                                          CASE WHEN UPPER(bs.Identificador) = 'PRODUTO' THEN psValor ELSE 0 END,
                                            CASE WHEN UPPER(bs.Identificador) = 'NCM' THEN psValor ELSE 0 END,
                                              CASE WHEN UPPER(bs.Identificador) = 'FAMILIA' THEN psValor ELSE 0 END,
                                                CASE WHEN UPPER(bs.Identificador) = 'CGO' THEN psValor ELSE 0 END,
                                          0,0, 'N', 'N', SYSDATE, 'PORTAL', NULL, 
                                          CASE WHEN UPPER(bs.Identificador) = 'NBS' THEN psValor ELSE 0 END);
      
    COMMIT;
    END LOOP;

   END IF;
   END IF;

   END;


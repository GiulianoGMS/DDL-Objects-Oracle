CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_CBS_IBS_DEV_RED  IS

  -- Paliativo Giuliano para reforma
  -- (devolucao com reducao 100% nao estava zerando impostos
  -- Variaveis 
  
  pdCGO          VARCHAR2(4000);
  psCGORegra     MAX_CODGERALOPER.CODGERALOPER%TYPE;
  
BEGIN
  
  FOR rej IN 
    
  (SELECT X.SEQNF, X.SEQNOTAFISCAL, X.CODGERALOPER CGO
     FROM MLF_NOTAFISCAL X INNER JOIN MAX_CODGERALOPER C ON C.CODGERALOPER = X.CODGERALOPER
      AND DTAEMISSAO >= SYSDATE - 7
      AND C.TIPDOCFISCAL = 'D'
      AND X.STATUSNFE = 5
      AND NOT EXISTS (SELECT 1 FROM NAGT_PALIAT_DEV D WHERE D.SEQNF = X.SEQNF))       
    
  LOOP
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DEV_CGO_CORRIGE_IBSCBS','S', NULL,
                        'Lista de CGOs que realiza a correcao dos campos de impostos CBS/IBS nas op de devolucoes (Correcao para reducao de aliq)', pdCGO);
    
    SELECT MAX(COLUMN_VALUE)
      INTO psCGORegra
      FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdCGO), 0)) AS C5INSTRTABLE))
     WHERE COLUMN_VALUE = rej.CGO AND COLUMN_VALUE IS NOT NULL;
 
  IF psCGORegra IS NOT NULL THEN -- Encontrou CGO no parametro dinamico
  
  INSERT INTO NAGT_PALIAT_DEV VALUES (rej.SEQNF);
  UPDATE MLF_NFITEM XI
   SET XI.VLRIMPOSTOIBSUF =
         CASE
           WHEN NVL(XI.PERALIQREDIBSUF,0) = 100 THEN 0
           ELSE ROUND(
                  XI.VLRBASEIBSUF *
                  ((XI.PERALIQIBSUF *
                   (1 - NVL(XI.PERALIQREDIBSUF,0) / 100)
                  ) / 100)
                , 2)
         END,
       XI.VLRIMPOSTOCBS =
         CASE
           WHEN NVL(XI.PERALIQREDCBS,0) = 100 THEN 0
           ELSE ROUND(
                  XI.VLRBASECBS *
                  ((XI.PERALIQCBS *
                   (1 - NVL(XI.PERALIQREDCBS,0) / 100)
                  ) / 100)
                , 2)
         END
 WHERE XI.SEQNF = rej.SEQNF
   AND (XI.PERALIQIBSUF IS NOT NULL
       OR XI.PERALIQCBS IS NOT NULL);
 
  COMMIT;
  SP_EXPORTANFE(rej.SEQNOTAFISCAL, 'E');
  COMMIT;
  END IF;
  
  END LOOP;
  
 EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
     -- DBMS para nao estourar erro SQL caso outro problema surja ao rodar essa proc, nao para o processo

END;

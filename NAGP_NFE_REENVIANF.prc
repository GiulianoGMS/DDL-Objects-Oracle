CREATE OR REPLACE PROCEDURE NAGP_NFE_REENVIANF (ChaveAntiga VARCHAR2, ChaveNova VARCHAR2, EscondeEpec VARCHAR2, vOutput OUT VARCHAR2) AS

  --=== Objeto utilizado para reenviar o XMl da NFe NORMAL e desfazer a troca de chaves no ERP ===--
  --=== Se não utilizar HIDDEN para ocultar a EPEC, deve ser abortada na NDD ===--

BEGIN
  
  -- 1. Troca a chave no ERP
  UPDATE MLF_NOTAFISCAL X
     SET X.NFECHAVEACESSO = ChaveAntiga
   WHERE X.NFECHAVEACESSO = ChaveNova
     AND X.DTAEMISSAO >= SYSDATE - 30;

  IF SQL%ROWCOUNT > 0 THEN
    vOutput := 'Chave trocada no ERP: SIM';
  ELSE
    vOutput := 'Chave trocada no ERP: NAO';
  END IF;

  -- 2. Reenvia a chave original
  UPDATE TBDATABASEINPUT X
     SET STATUS = 0
   WHERE X.CHAVEACESSO = ChaveAntiga
     AND ROWNUM = 1;

  IF SQL%ROWCOUNT > 0 THEN
    vOutput := vOutput || ' ' || 'Chave Original Reenviada: SIM';
  ELSE
    vOutput := vOutput || ' ' || 'Chave Original Reenviada: NAO';
  END IF;

  IF EscondeEpec = 'S' THEN
  -- 3. Oculta EPEC na NDD
  UPDATE NDD_CONNECTOR.TBLOGDOCUMENT X
     SET HIDDEN = 1
   WHERE X.ACCESSKEY = ChaveNova
     AND X.EMISSIONDATE >= SYSDATE - 30;

  IF SQL%ROWCOUNT > 0 THEN
    vOutput := vOutput || ' ' || 'Hidden EPEC: SIM';
  ELSE
    vOutput := vOutput || ' ' || 'Hidden EPEC: NAO';
  END IF;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(vOutput);

END;

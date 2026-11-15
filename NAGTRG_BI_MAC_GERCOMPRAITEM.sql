CREATE OR REPLACE TRIGGER NAGTRG_BI_MAC_GERCOMPRAITEM

  BEFORE INSERT ON MAC_GERCOMPRAITEM

FOR EACH ROW

  FOLLOWS TBIU_MAC_GERABASTECITEM

  DECLARE
   psSeqFornec     MAF_FORNECEDOR.SEQFORNECEDOR%TYPE;
   psSeqComprador  MAX_COMPRADOR.SEQCOMPRADOR%TYPE;
   psIndAcataSug   NUMBER(10);
   psCD            NUMBER(10);
   psOrigem        NUMBER(13);
   psCalcEsp       VARCHAR2(100);

BEGIN

   SELECT MAX(F.SEQFORNECEDOR)
     INTO psSeqFornec
     FROM MAC_GERCOMPRAFORN F
    WHERE F.SEQGERCOMPRA = :NEW.SEQGERCOMPRA;

   SELECT MAX(C.SEQCOMPRADOR), MAX(C.SEQGERCOMPORIGEM)
     INTO psSeqComprador, psOrigem
     FROM MAC_GERCOMPRA C
    WHERE C.SEQGERCOMPRA = :NEW.SEQGERCOMPRA
      AND C.TIPOLOTE = 'C';

   IF psSeqComprador IS NOT NULL AND psOrigem IS NULL THEN -- Segue

   SELECT COUNT(1), MAX(X.TIPOCALCESP)
     INTO psIndAcataSug, psCalcEsp
     FROM NAGT_COMP_FORN_SUGESTAUTO X
    WHERE psSeqComprador = X.SEQCOMPRADOR
      AND psSeqFornec = NVL(X.SEQFORNECEDOR, psSeqFornec)
      /*AND TIPOCALCESP IS NULL*/;

   IF psIndAcataSug > 0 THEN

       ----------------------------------------------------------------------
        -- Se existir CD no lote, nao aciona essa trigger
       ----------------------------------------------------------------------
        SELECT COUNT(1)
          INTO psCD
          FROM MAC_GERCOMPRAEMP GE
         WHERE GE.SEQGERCOMPRA = :NEW.SEQGERCOMPRA
           AND GE.NROEMPRESA BETWEEN 500 AND 599;

           IF psCD = 0  OR psCalcEsp IS NOT NULL THEN

     IF NVL(:NEW.QTDSUGERIDAFORNEC, 0) > 0 THEN
        :NEW.QTDPEDIDA := :NEW.QTDSUGERIDAFORNEC;
     ELSE
        :NEW.QTDPEDIDA := 0;
     END IF;

   :NEW.SITUACAOITEM := 'S';

     END IF;
    END IF;
   END IF;

END;

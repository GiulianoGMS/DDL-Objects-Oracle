CREATE OR REPLACE TRIGGER NAGTRG_BI_MAC_GERCOMPRAITEM

  BEFORE INSERT ON MAC_GERCOMPRAITEM

FOR EACH ROW

  FOLLOWS TBIU_MAC_GERABASTECITEM  
  
  DECLARE
   psSeqFornec     MAF_FORNECEDOR.SEQFORNECEDOR%TYPE;
   psSeqComprador  MAX_COMPRADOR.SEQCOMPRADOR%TYPE;
   psIndAcataSug   NUMBER(10);
   psCD            NUMBER(10);

BEGIN
  
   SELECT MAX(F.SEQFORNECEDOR)
     INTO psSeqFornec
     FROM MAC_GERCOMPRAFORN F
    WHERE F.SEQGERCOMPRA = :NEW.SEQGERCOMPRA;
     
   SELECT MAX(C.SEQCOMPRADOR)
     INTO psSeqComprador
     FROM MAC_GERCOMPRA C
    WHERE C.SEQGERCOMPRA = :NEW.SEQGERCOMPRA
      AND C.TIPOLOTE = 'C';
      
   IF psSeqComprador IS NOT NULL THEN -- Segue
         
   SELECT COUNT(1)
     INTO psIndAcataSug
     FROM NAGT_COMP_FORN_SUGESTAUTO X
    WHERE psSeqComprador = X.SEQCOMPRADOR
      AND psSeqFornec = NVL(X.SEQFORNECEDOR, psSeqFornec);
      
   IF psIndAcataSug > 0 THEN
     
       ----------------------------------------------------------------------
        -- Se existir CD no lote, nao aciona essa trigger
       ----------------------------------------------------------------------
        SELECT COUNT(1)
          INTO psCD
          FROM MAC_GERCOMPRAEMP GE
         WHERE GE.SEQGERCOMPRA = :NEW.SEQGERCOMPRA
           AND GE.NROEMPRESA BETWEEN 500 AND 599;
           
           IF psCD = 0 THEN

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

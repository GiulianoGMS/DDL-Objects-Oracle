CREATE OR REPLACE FUNCTION NAGF_DF_REF (psChaveAcesso VARCHAR2, psNroItemDoc NUMBER, psTipoRetorno VARCHAR2)

RETURN VARCHAR2
  IS psChaveNFRef VARCHAR2(44);
     psNroItemRef VARCHAR2(10);
     psRetorno    VARCHAR2(44);
     
BEGIN
  
  IF 1=1 THEN

   SELECT MAX(Xi.Nfreferencianfechaveacesso), MAX(Xi.Numchavenferet)
     INTO psChaveNFRef, psNroItemRef
     FROM MLF_NOTAFISCAL A INNER JOIN MLF_NFITEM XI ON XI.SEQNF = A.SEQNF
                           INNER JOIN MAX_CODGERALOPER C ON C.CODGERALOPER = A.CODGERALOPER
     WHERE A.NFECHAVEACESSO = psChaveAcesso
       AND C.TIPDOCFISCAL = 'D'
       AND XI.SEQITEMNF = psNroItemDoc;
    
    IF psTipoRetorno = 'C' THEN 
       psRetorno := psChaveNFRef;
    ELSE
       psRetorno := psNroItemRef;
    END IF;
    
  END IF;
    
 RETURN psRetorno;
     
END;

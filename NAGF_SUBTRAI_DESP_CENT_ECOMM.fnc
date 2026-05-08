CREATE OR REPLACE FUNCTION NAGF_SUBTRAI_DESP_CENT_ECOMM (psValorDespAcessoria MFL_DFITEM.VLRTOTDESPACESSORIA%TYPE,
                                                         psAppOrigem NUMBER,
                                                         psCGO MAX_CODGERALOPER.CODGERALOPER%TYPE) 

RETURN MFL_DFITEM.VLRTOTDESPACESSORIA%TYPE AS

 vsRetorno MFL_DFITEM.VLRTOTDESPACESSORIA%TYPE;
 vsVlrLimite MFL_DFITEM.VLRTOTDESPACESSORIA%TYPE := 0.07;
 vsCGO MAX_CODGERALOPER.DESCRICAO%TYPE;
 
 BEGIN
 -- Check se e ecommerce (nao achei outra forma)
 SELECT COUNT(1) INTO vsCGO FROM MAX_CODGERALOPER C WHERE CODGERALOPER = psCGO AND DESCRICAO LIKE '%E-COMM%';  
 
 IF vsCGO > 0 THEN
   
   -- Check se nao passa do limite
   IF psValorDespAcessoria > 0 
  AND psValorDespAcessoria <= vsVlrLimite 
  AND psAppOrigem = 7 THEN
      vsRetorno := psValorDespAcessoria;
   END IF;
   
 END IF;
 
 IF vsRetorno IS NULL THEN
    vsRetorno := 0;
 END IF;
   
   RETURN vsRetorno;
   
END;

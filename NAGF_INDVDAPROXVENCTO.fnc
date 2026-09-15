CREATE OR REPLACE FUNCTION NAGF_INDVDAPROXVENCTO (psCODPRODUTO   MFL_DFITEM.CODPRODUTO%TYPE,
                                                  psDtaMovimento MFL_DOCTOFISCAL.DTAMOVIMENTO%TYPE,
                                                  psNroEmpresa   NUMBER)
                                                  
  RETURN VARCHAR2 IS
    psQtdVdaCodEspec NUMBER(10);
    psIndProxVencto  VARCHAR2(1);
                                                  
BEGIN
  
  SELECT COUNT(1)
    INTO psQtdVdaCodEspec
    FROM MRL_PROMOCESPECIALHIST X WHERE X.NROEMPRESA = psNroEmpresa
                                    AND X.CODACESSOESPECIAL = psCODPRODUTO
                                    AND psDtaMovimento BETWEEN X.DTAINICIO AND X.DTAFIM;

 IF psQtdVdaCodEspec = 0 THEN
    psIndProxVencto := 'N';
 ELSE
    psIndProxVencto := 'S';
 END IF;

 RETURN psIndProxVencto;
 
 END;

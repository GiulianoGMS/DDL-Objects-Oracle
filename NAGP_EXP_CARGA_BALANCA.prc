CREATE OR REPLACE PROCEDURE NAGP_EXP_CARGA_BALANCA (psTipoCarga VARCHAR2) IS

  pdDirParcial VARCHAR2(1000);
  pdDirTotal   VARCHAR2(1000);
  pdDirSelec   VARCHAR2(1000);
  pdListaEmp   VARCHAR2(4000);
  pdDataBaseExp DATE;

BEGIN
  
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DIR_EXP_CARGA_BAL_CD','S', NULL,
                        'Diretorio para exportacao da carga de balanca dos CDs (Total)'  , pdDirTotal);
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DIR_EXP_CARGA_BAL_CD_PARCIAL','S', NULL,
                        'Diretorio para exportacao da carga de balanca dos CDs (Parcial)', pdDirParcial);
                        --
                        
  IF psTipoCarga = 'P' THEN
     pdDirSelec    := pdDirParcial;
     pdDataBaseExp := TRUNC(SYSDATE) - 10;
     
  ELSE
     pdDirSelec    := pdDirTotal;
     pdDataBaseExp := DATE '1990-01-01';
  END IF;
                        
  NAGP_ESPP_CPT_GERACARGATOLEDO(pdDataBaseExp, pdDirSelec);
  
END;

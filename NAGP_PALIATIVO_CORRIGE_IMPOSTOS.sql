CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_CORRIGE_IMPOSTOS (psSeqAuxNotaFiscal MLF_AUXNOTAFISCAL.SEQAUXNOTAFISCAL%TYPE) IS

  -- Paliativo Giuliano para reforma
  -- e outros 
  
  -- Adicionado na PKG_MLF_RECEBIMENTO
  -- Linha 7513
  -- NAGP_PALIATIVO_CORRIGE_IMPOSTOS(pnSeqAuxNotaFiscal);
  --

  -- Variaveis 

  psSeqPessoa    NUMBER(7);
  psStatusNT     VARCHAR2(1);
  psNumeroNF     NUMBER(30);
  psIndImp       VARCHAR2(3);
  psChave        MLF_AUXNOTAFISCAL.NFECHAVEACESSO%TYPE;
  psCBS          TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psIBS          TMP_M000_NF.M000_VL_VLRBASEIBSUF%TYPE;
  psCGO          MAX_CODGERALOPER.CODGERALOPER%TYPE;
  psCNPJ         GE_PESSOA.NROCGCCPF%TYPE;
  psTipDoc       VARCHAR2(1);
  pdTipPed       VARCHAR2(1);
  psIndProdRural VARCHAR2(1);
  
  psQtdRep       NUMBER(10);
  psCodProd      TMP_M014_ITEM.M014_CD_PRODUTO%TYPE;  
  psCGORegra     MAX_CODGERALOPER.CODGERALOPER%TYPE;
  pdCGO          VARCHAR2(4000);
  pdIndCorrigeDespForaNF VARCHAR2(1);
  psVlrTotDespForaNF MLF_AUXNOTAFISCAL.VLRDESPFORANF%TYPE;
  
  -- Variaveis por item para arred
  
  psBaseCBSItemToT  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrCBSItemToT   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psBaseIBSItemToT  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrIBSItemTot   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psBaseIBSMunItem  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrIBSMunItem   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  
  -- Variaveis com as diferencas
  
  psBaseCBSItemCalc  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrCBSItemCalc   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psBaseIBSItemCalc  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrIBSItemCalc   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psBaseIBSMunItemC  TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  psVlrIBSMunItemC   TMP_M000_NF.M000_VL_VLRBASECBS%TYPE;
  
  psRowID VARCHAR2(300);
  
  -- Paliativo 3 -- IPI Emp Importadora
  psImp          VARCHAR2(1);
  pdZeraIPI      VARCHAR2(1);
  
BEGIN
  -- Descobre o SEQ
  SELECT X.SEQPESSOA, NUMERONF, X.NFECHAVEACESSO, X.CODGERALOPER, G.NROCGCCPF, C.TIPDOCFISCAL, C.TIPPEDIDOCOMPRA, M.INDIMPORTADORA, G.INDPRODRURAL
    INTO psSeqPessoa, psNumeroNF, psChave, psCGO, psCNPJ, psTipDoc, pdTipPed, psIndImp, psIndProdRural
   FROM MLF_AUXNOTAFISCAL X INNER JOIN GE_PESSOA G ON G.SEQPESSOA = X.SEQPESSOA
                            INNER JOIN MAX_CODGERALOPER C ON C.CODGERALOPER = X.CODGERALOPER
                            INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = X.NROEMPRESA
  WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal /* AND X.SEQPESSOA NOT IN (504) AND X.NROEMPRESA NOT IN (504,505)*/ AND X.NUMERONF != 253287;
   
  -- Valida se a NT 2025002 esta ativa para o seq
  SELECT MAX(STATUS)
    INTO psStatusNT
    FROM MAX_EMPRESANOTATECNICA T WHERE T.NRONOTATECNICA = 2025002 AND T.NROEMPRESA = psSeqPessoa;
    
  -- Se o fornecedor nao emitiu no XML entao tambem zera, pois a obrigacao é em 02/2026
  SELECT MAX(X.M000_VL_VLRBASECBS), MAX(X.M000_VL_VLRBASEIBSUF)
    INTO psCBS, psIBS
    FROM TMP_M000_NF X 
   WHERE X.M000_NR_CHAVE_ACESSO = psChave;
  
  -- Paliativo 1
  -- Se o emissor (do grupo) nao emite impostos, zera a entrada)
  -- Se estiver ativa para o emissor do grupo, não deve zerar na entrada
  -- ou se o fornec nao enviou no XML e ainda nao passou da data de obrigatoriedade
  
  IF psSeqPessoa < 999 AND NVL(psStatusNT,'N') != 'A'
  OR (NVL(psCBS,0) = 0 OR NVL(psIBS,0) = 0) AND TRUNC(SYSDATE) < DATE '2026-06-30' AND NVL(psIndImp, 'N') != 'I' THEN
  
  -- Zera itens
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS         = 0,
                              XI.VLRIMPOSTOCBS      = 0,
                              XI.VLRBASEIBSUF       = 0,
                              XI.VLRIMPOSTOIBSUF    = 0,
                              XI.VLRBASEIBSMUN      = 0,
                              XI.VLRIMPOSTOIBSMUN   = 0
                        WHERE XI.SEQAUXNOTAFISCAL   = psSeqAuxNotaFiscal;
  -- Zera capa
  UPDATE MLF_AUXNOTAFISCAL X SET X.VLRBASECBS       = 0,
                                 X.VLRIMPOSTOCBS    = 0,
                                 X.VLRBASEIBSUF     = 0,
                                 X.VLRIMPOSTOIBSUF  = 0,
                                 X.VLRBASEIBSMUN    = 0,
                                 X.VLRIMPOSTOIBSMUN = 0
                           WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
                           
  COMMIT;
  
  -- Paliativo 2
  -- Se for nota do grupo, atualiza de acordo com XML pois ao alterar o CGO ele vai recalcular CBS IBS

  ELSIF 1=1 THEN
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'CGO_REP_XML_REFORMA','S', NULL,
                        'Lista de CGOs que mantem as informacoes do XML sobre os novos impostos da Reforma Tributária no lançamento entre lojas do grupo', pdCGO);
    
    SELECT MAX(COLUMN_VALUE)
      INTO psCGORegra
      FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdCGO), 0)) AS C5INSTRTABLE))
     WHERE COLUMN_VALUE = psCGO AND COLUMN_VALUE IS NOT NULL;
 
  IF psCGORegra IS NOT NULL THEN -- Encontrou CGO no parametro dinamico
    
  -- Item Rateado
 FOR item IN (
 SELECT MAX(BASECBS)        BASECBS,
        MAX(VLRCBS)         VLRCBS,
        MAX(BASEIBS)        BASEIBS,
        MAX(VLRIBS)         VLRIBS,
        MAX(BASEIBSMUN)     BASEIBSMUN,
        MAX(VLRIBSMUN)      VLRIBSMUN,
        
        SUM(BASEISCHEIO)    BASEISCHEIO,
        SUM(BASEIBSUFCHEIO) BASEIBSUFCHEIO,
        SUM(VLRIBSUFCHEIO)  VLRIBSUFCHEIO,
        SUM(BASEIBSMUNCHEIO) BASEIBSMUNCHEIO,
        SUM(VLRIBSMUNCHEIO) VLRIBSMUNCHEIO,
        SUM(BASECBSCHEIO)   BASECBSCHEIO,
        SUM(VLRCBSCHEIO)    VLRCBSCHEIO,
        
        COD, EMB_XML, PESOLIQUIDO, DESCCOMPLETA
   
   FROM (
       
  SELECT DISTINCT        Y.M014_NR_ITEM, NVL(Y.M014_VL_VLRBASECBS /          CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,0) BaseCBS, 
                         NVL(ROUND(Y.M014_VL_VLRIMPOSTOCBS / CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,5),0) VlrCBS, 
                         NVL(Y.M014_VL_VLRBASEIBSUF /        CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,0) BaseIBS, 
                         NVL(Y.M014_VL_VLRIMPOSTOIBS /       CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,0) VlrIBS,
                         NVL(Y.M014_VL_VLRBASEIBSMUN /       CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,0) BaseIbsMun, 
                         NVL(Y.M014_VL_VLRIMPOSTOIBSMUN /    CASE WHEN F.PESAVEL = 'S' THEN M014_VL_QTDE_TRIB ELSE Y.M014_VL_QTDE_COM END,0) VlrIBSMun,
                         
                         Y.M014_VL_VLRBASEIS        BaseISCheio,
                         Y.M014_VL_VLRBASEIBSUF     BaseIBSUFCheio,
                         Y.M014_VL_VLRIMPOSTOIBSUF  VlrIBSUFCheio,
                         Y.M014_VL_VLRBASEIBSMUN    BaseIBSMunCHeio,
                         Y.M014_VL_VLRIMPOSTOIBSMUN VlrIBSMunCheio,
                         Y.M014_VL_VLRBASECBS       BaseCBSCheio,
                         Y.M014_VL_VLRIMPOSTOCBS    VlrCBSCheio,
                         
                         CASE WHEN psTipDoc IN ('C','B','O') AND pdTipPed IN ('C','E') THEN TO_CHAR(NVL(C.SEQPRODUTO, C2.SEQPRODUTO)) ELSE Y.M014_CD_PRODUTO END COD, Y.M014_DS_UNID_COM EMB_XML, E.PESOLIQUIDO, P.DESCCOMPLETA
       
    FROM TMP_M000_NF X INNER JOIN TMP_M014_ITEM Y ON X.M000_ID_NF = Y.M000_ID_NF
                        LEFT JOIN MAP_PRODCODIGO C ON UPPER(C.CODACESSO)  = UPPER(Y.M014_CD_PRODUTO) AND psCNPJ LIKE '%'||C.CGCFORNEC||'%' AND C.TIPCODIGO = 'F'
                        LEFT JOIN MAP_PRODCODIGO C2 ON C2.CODACESSO = Y.M014_CD_EAN    AND C2.TIPCODIGO IN ('E', 'D') --AND psCNPJ LIKE '%'||C2.CGCFORNEC||'%' AND C2.TIPCODIGO = 'E'
                        LEFT JOIN MAP_PRODUTO P ON P.SEQPRODUTO = NVL(C.SEQPRODUTO, C2.SEQPRODUTO)
                        LEFT JOIN MAP_FAMILIA F ON F.SEQFAMILIA = P.SEQFAMILIA
                        LEFT JOIN MAP_FAMEMBALAGEM E ON E.SEQFAMILIA = F.SEQFAMILIA AND E.QTDEMBALAGEM = 1
                       
   WHERE X.M000_NR_CHAVE_ACESSO = psChave) GROUP BY COD, EMB_XML, PESOLIQUIDO, DESCCOMPLETA)
   
  LOOP
    
    -- Descobre se vai usar o valor rateado ou cheio
    SELECT COUNT(*) QTD_REPETICOES_PROD INTO psQtdRep FROM MLF_AUXNFITEM XI WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal AND XI.SEQPRODUTO = item.COD;
 
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS       = CASE WHEN psQtdRep > 1 THEN item.BaseCBS    * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.BaseCBSCheio    END,
                              XI.VLRIMPOSTOCBS    = CASE WHEN psQtdRep > 1 THEN item.VlrCBS     * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.VlrCBSCheio     END,
                              XI.VLRBASEIBSUF     = CASE WHEN psQtdRep > 1 THEN item.BaseIBS    * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.BaseIBSUFCheio  END,
                              XI.VLRIMPOSTOIBSUF  = CASE WHEN psQtdRep > 1 THEN item.VlrIBS     * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.VlrIBSUFCheio   END,
                              XI.VLRBASEIBSMUN    = CASE WHEN psQtdRep > 1 THEN item.BaseIBSMun * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.BaseIBSMunCHeio END,
                              XI.VLRIMPOSTOIBSMUN = CASE WHEN psQtdRep > 1 THEN item.VlrIBSMun  * ((XI.QUANTIDADE * CASE WHEN item.EMB_XML = 'KG' AND NVL(XI.EMBALAGEM, CASE WHEN item.DESCCOMPLETA LIKE '%KG%' THEN 'KG' ELSE 'X' END) != item.EMB_XML THEN item.PESOLIQUIDO ELSE 1 END) / CASE WHEN item.EMB_XML IN('UN','CR','UN1','KG','CP') THEN 1 ELSE XI.QTDEMBALAGEM END) ELSE item.VlrIBSMunCheio  END
                              
                        WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal
                          AND XI.SEQPRODUTO   = item.COD;
                          
    psQtdRep := 0;
    
  END LOOP;
  -- Atualiza Capa     
  FOR capa IN (   
  SELECT X.M000_VL_VLRBASECBS BaseCBSItemCheio, X.M000_VL_VLRIMPOSTOCBS VlrCBSItemCheio, X.M000_VL_VLRBASEIBSUF BaseIBSItemCheio, X.M000_VL_VLRIMPOSTOIBS VlrIBSItemCheio, 
         CASE WHEN M000_VL_VLRIMPOSTOIBSMUN > 0 THEN X.M000_VL_VLRBASEIBSMUN ELSE 0 END BaseIBSMunCheio, X.M000_VL_VLRIMPOSTOIBSMUN VlrIBSMunCheio
    FROM TMP_M000_NF X
   WHERE X.M000_NR_CHAVE_ACESSO = psChave)
   
  LOOP
                          
  UPDATE MLF_AUXNOTAFISCAL X SET X.VLRBASECBS       = capa.Basecbsitemcheio,
                                 X.VLRIMPOSTOCBS    = capa.VlrCBSItemCheio,
                                 X.VLRBASEIBSUF     = capa.BaseIBSItemCheio,
                                 X.VLRIMPOSTOIBSUF  = capa.VlrIBSItemCheio,
                                 X.VLRBASEIBSMUN    = capa.BaseIBSMunCheio,
                                 X.VLRIMPOSTOIBSMUN = capa.VlrIBSMunCheio
                           WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
   
  -- Arredonda os valores se a div for centavos
  
  SELECT SUM(VLRBASECBS), SUM(VLRIMPOSTOCBS), SUM(VLRBASEIBSUF), SUM(VLRIMPOSTOIBSUF), SUM(VLRBASEIBSMUN), SUM(VLRIMPOSTOIBSMUN), MAX(ROWID)
    INTO psBaseCBSItemToT, psVlrCBSItemToT, psBaseIBSItemToT, psVlrIBSItemTot, psBaseIBSMunItem, psVlrIBSMunItem, psRowID
    FROM MLF_AUXNFITEM XI WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
  
  psBaseCBSItemCalc  := capa.Basecbsitemcheio - psBaseCBSItemToT;
  psVlrCBSItemCalc   := capa.VlrCBSItemCheio  - psVlrCBSItemToT;
  psBaseIBSItemCalc  := capa.BaseIBSItemCheio - psBaseIBSItemToT;
  psVlrIBSItemCalc   := capa.VlrIBSItemCheio  - psVlrIBSItemTot;
  psBaseIBSMunItemC  := capa.BaseIBSMunCheio  - psBaseIBSMunItem;
  psVlrIBSMunItemC   := capa.VlrIBSMunCheio   - psVlrIBSMunItem;
  
  IF psBaseCBSItemCalc != 0 AND psBaseCBSItemCalc BETWEEN -0.05 AND 0.05 OR
     psVlrCBSItemCalc  != 0 AND psVlrCBSItemCalc  BETWEEN -0.05 AND 0.05 OR
     psBaseIBSItemCalc != 0 AND psBaseIBSItemCalc BETWEEN -0.05 AND 0.05 OR
     psVlrIBSItemCalc  != 0 AND psVlrIBSItemCalc  BETWEEN -0.05 AND 0.05 OR 
     psBaseIBSMunItemC != 0 AND psBaseIBSMunItemC BETWEEN -0.05 AND 0.05 OR
     psVlrIBSMunItemC  != 0 AND psVlrIBSMunItemC  BETWEEN -0.05 AND 0.05
     
  THEN 
    
  UPDATE MLF_AUXNFITEM XI SET XI.VLRBASECBS       = XI.VLRBASECBS       + psBaseCBSItemCalc,
                              XI.VLRIMPOSTOCBS    = XI.VLRIMPOSTOCBS    + psVlrCBSItemCalc,
                              XI.VLRBASEIBSUF     = XI.VLRBASEIBSUF     + psBaseIBSItemCalc,
                              XI.VLRIMPOSTOIBSUF  = XI.VLRIMPOSTOIBSUF  + psVlrIBSItemCalc,
                              XI.VLRBASEIBSMUN    = XI.VLRBASEIBSMUN    + psBaseIBSMunItemC,
                              XI.VLRIMPOSTOIBSMUN = XI.VLRIMPOSTOIBSMUN + psVlrIBSMunItemC
                              
                        WHERE XI.ROWID = psRowID
                          AND XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
  -- Reprocessa Inconsist
   
      END IF;
     END LOOP;
     COMMIT;
    END IF; 
   COMMIT;  
  END IF;
  
  -- Paliativo 3
  -- 3 Corrige IPI nas notas de importacao (entrada nas lojas) pois esta calculando IPI, ja que a empresa é importadora
  
  SELECT NAGF_EmpImportadora(psSeqPessoa)
    INTO psImp
    FROM DUAL;
  
  IF psImp = 'I' THEN 
    
    -- Busca PDs
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'REC_IND_ZERA_IPI_IMP','S', NULL,
                        'Indica se zera o IPI na entrada de emissao de notas de empresa importadora do grupo. S/N', pdZeraIPI);

    IF pdZeraIPI = 'S' THEN
        UPDATE MLF_AUXNFITEM XI SET XI.VLRIPI = 0,
                                    XI.BASCALCIPI = 0,
                                    XI.PERALIQUOTAIPI = 0
                              WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotafiscal;
        UPDATE MLF_AUXNOTAFISCAL X SET X.VLRIPI = 0
                                 WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
    END IF;
  
  END IF;
  
  -- Paliativo 6 fora de ordem rs
  -- 6 Corrige Despesa Fora NF (CBS+IBS)
  
  IF psIndImp = 'I' THEN
    
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'IMP_INDCORRIGEDESPFORANF','S', NULL,
                        'Indica se altera o valor Despesa Fora NF (Soma CBS+IBS da DI) na NF de Importacao', pdIndCorrigeDespForaNF);
    
    IF pdIndCorrigeDespForaNF = 'S' AND psCGO = 5 THEN
      
       SELECT SUM(XI.VLRDESPFORANF) 
         INTO psVlrTotDespForaNF
         FROM MLF_AUXNFITEM XI 
        WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
       
       IF psVlrTotDespForaNF > 0 THEN
       UPDATE MLF_AUXNOTAFISCAL X
          SET X.VLRDESPFORANF = CASE WHEN NVL(X.VLRDESPFORANF,0) >= psVlrTotDespForaNF THEN NVL(X.VLRDESPFORANF,0) ELSE NVL(X.VLRDESPFORANF,0) + psVlrTotDespForaNF END
        WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotaFiscal;
       END IF;
    END IF;
    
  END IF;
  
  -- Paliativo 4 30/01/2025
  -- Corrige ICMS Desonerado na entrada da devolucao, pois a alteracao do CGO recalcula ep ega a atual
  
  IF psCGO IN (103,18,55) AND TRUNC(SYSDATE) < DATE '2026-04-01' THEN
      UPDATE MLF_AUXNFITEM XI SET INDCALCICMSDESONOUTROS = 0, VLRTOTICMSDESONERADO = 0, MOTIVODESONERACAOICMS = NULL
                            WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotafiscal;
  COMMIT;
  END IF;
  
  -- Paliativo 5 20/03/2026 TKT 702383
  -- Zera ICMS Desonerado nas entradas de devolucoes
  
  IF psTipDoc = 'D' AND psSeqPessoa < 999 THEN
    
  pdCGO := NULL;
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'DEV_CGO_ZERA_DESON','S', NULL,
                        'Lista de CGOs que zera o imposto de ICMS Desonerado na entrada de devolucoes do grupo', pdCGO); 
                        
  SELECT MAX(COLUMN_VALUE)
      INTO psCGORegra
      FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdCGO), 0)) AS C5INSTRTABLE))
     WHERE COLUMN_VALUE = psCGO AND COLUMN_VALUE IS NOT NULL;
 
  IF psCGORegra IS NOT NULL OR 1=1 THEN -- Encontrou CGO no parametro dinamico (se o fiscal quiser)
    
     UPDATE MLF_AUXNFITEM XI SET XI.MOTIVODESONERACAOICMS = NULL,
                                 XI.VLRTOTICMSDESONERADO = 0
                           WHERE XI.SEQAUXNOTAFISCAL = psSeqAuxNotafiscal;
                           
  COMMIT;
  END IF;
  END IF;
  
  -- Paliativo 7
  -- Corrige/Recalc Prod Rural pois nao esta pegando cenarios atuais na versao
  
  IF psIndProdRural = 'S' AND psCGO != 900 THEN
     UPDATE MLF_AUXNOTAFISCAL X SET X.INDIMPXML = 'N'
      WHERE X.SEQAUXNOTAFISCAL = psSeqAuxNotafiscal;
     UPDATE MLF_AUXNFITEM XI SET INDMANUTENCAO = 'R'
                              --INDRECALCVLRORIGINAL = 'S'
      WHERE SEQAUXNOTAFISCAL = psSeqAuxNotafiscal;                   
      --COMMIT;
     -- PKG_MLF_RECEBIMENTO.SP_CONSISTEAUXNOTAFISCAL(psSeqAuxNotafiscal);
  END IF;
  COMMIT;
  
 EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
     -- DBMS para nao estourar erro SQL caso outro problema surja ao rodar essa proc, nao para o processo

END;

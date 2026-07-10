CREATE OR REPLACE PROCEDURE NAGP_MN_ENCARTE (psSeqEncarte  NUMBER,
                                             psIndRepFam   VARCHAR2,
                                             psIndRepSim   VARCHAR2) AS

BEGIN
  
  DECLARE codErro VARCHAR2(100);
       vSeqPromoc NUMBER(27);
  
  BEGIN
    
  ---////////// LOOP Segmento
  ---////////// Loop para gerar a Promocao por Segmento ///////////
  FOR seg IN (SELECT DISTINCT NROSEGMENTO, DTAINICIO perINI, DTAFIM perFIM FROM NAGV_BASE_MN_ENCARTE T 
               WHERE T.SEQENCARTE = psSeqEncarte
                  -- Este not exists evita duplicidades
                 AND NOT EXISTS(SELECT 1 FROM MFL_PROMOCAOPDV X WHERE X.DESCRICAO = T.DESC_PROMOC))
  
  LOOP
  
  -- Descobre o SEQ NextVal
  -- Vai ser necessario no loop de item x loja x preco
  SELECT S_SEQPROMOCPDV.NEXTVAL
    INTO vSeqPromoc
    FROM DUAL;  
  
  ---////////// LOOP CAPA
  ---////////// Insere a capa da promocao ///////////
  FOR capa IN (SELECT vSeqPromoc SEQPROMOCPDV, CODPROMOCAO, DTAINICIO, DTAFIM, DESC_PROMOC, 'A' STATUS
                 FROM (SELECT DISTINCT SEQENCARTE CODPROMOCAO, T.DTAINICIO, T.DTAFIM, DESC_PROMOC
                         FROM NAGV_BASE_MN_ENCARTE T 
                        WHERE 1=1 
                          AND T.SEQENCARTE  = psSeqEncarte
                          AND T.NROSEGMENTO = seg.Nrosegmento
                          AND T.DTAINICIO   = seg.perINI
                          AND T.DTAFIM      = seg.perFIM
                          -- Este not exists evita duplicidades
                          AND NOT EXISTS(SELECT 1 FROM MFL_PROMOCAOPDV X WHERE X.DESCRICAO = T.DESC_PROMOC)))
               
  LOOP
  codErro := capa.CODPROMOCAO;
  
  INSERT INTO MFL_PROMOCAOPDV X (SEQPROMOCPDV,
                                 DESCRICAO,
                                 STATUS,
                                 DTAINICIO,
                                 DTAFIM,
                                 DTAALTERACAO,
                                 USUALTERACAO,
                                 NROBASEEXPORTACAO,
                                 TIPOPROMOCAO,
                                 TIPOQUANTIDADE,
                                 INDTIPOQTDCARGAPDV,
                                 INDCONTROLAVERBAPDV,
                                 CODPARCEIRO)

  VALUES (capa.SEQPROMOCPDV,
          capa.DESC_PROMOC,
          capa.STATUS,
          capa.DTAINICIO,
          capa.DTAFIM,
          SYSDATE,
         'MN_ENCARTE',
          0,
         'I',
         'I',
         'A',
         'S', -- Controla Verba PDV (Sellout)
          700);
          
  ---////////// Loop ITEM
  ---////////// Insere os itens da promocao de acordo com o codpromocao da capa ///////////
  
  FOR item IN (SELECT BS.*, ROWNUM SEQITEMPROMOC FROM (   
   -- 1.: Se nao estiver marcado para replicar FAMILIA nem SIMILAR
   SELECT DISTINCT T.SEQFAMILIA, T.SEQPRODUTO 
                         FROM NAGV_BASE_MN_ENCARTE T INNER JOIN MAP_PRODUTO P ON P.SEQPRODUTO = T.SEQPRODUTO AND psIndRepFam = 'N' AND psIndRepSim = 'N'
                        WHERE 1=1 AND T.SEQENCARTE = psSeqEncarte
                          AND T.DTAINICIO   = seg.perINI
                          AND T.DTAFIM      = seg.perFIM
                          AND T.NROSEGMENTO = seg.Nrosegmento
UNION   
   -- 2.: Se estiver marcado para replicar apenas FAMILIA
   SELECT DISTINCT T.SEQFAMILIA, NVL(P.SEQPRODUTO, T.SEQPRODUTO) SEQPRODUTO
                         FROM NAGV_BASE_MN_ENCARTE T INNER JOIN MAP_PRODUTO P ON T.SEQFAMILIA = P.SEQFAMILIA AND psIndRepFam = 'S' AND psIndRepSim = 'N'
                        WHERE 1=1 AND T.SEQENCARTE = psSeqEncarte
                          AND T.DTAINICIO   = seg.perINI
                          AND T.DTAFIM      = seg.perFIM
                          AND T.NROSEGMENTO = seg.Nrosegmento

UNION 
   -- 3.: Se estiver marcado para replicar apenas FAMILIA
   SELECT DISTINCT T.SEQFAMILIA, NVL(S.SEQPRODUTO, T.SEQPRODUTO) SEQPRODUTO
                         FROM NAGV_BASE_MN_ENCARTE T INNER JOIN MAP_PRODSIMILAR S ON S.SEQSIMILARIDADE = T.SEQSIMILARIDADE AND psIndRepFam = 'N' AND psIndRepSim = 'S'
                        WHERE 1=1 AND T.SEQENCARTE = psSeqEncarte
                          AND T.DTAINICIO   = seg.perINI
                          AND T.DTAFIM      = seg.perFIM
                          AND T.NROSEGMENTO = seg.Nrosegmento
                        
UNION 
   -- 4.: Se estiver marcado para replicar FAMILIA E SIMILAR
   SELECT DISTINCT T.SEQFAMILIA, NVL(P.SEQPRODUTO, X.SEQPRODUTO) SEQPRODUTO
                         FROM NAGV_BASE_MN_ENCARTE T INNER JOIN MAP_PRODUTO X ON X.SEQFAMILIA = T.SEQFAMILIA AND psIndRepFam = 'S'
                                                     INNER JOIN MAP_PRODSIMILAR S ON S.SEQPRODUTO = X.SEQPRODUTO  AND psIndRepSim = 'S'
                                                     INNER JOIN MAP_PRODSIMILAR P ON P.SEQSIMILARIDADE = S.SEQSIMILARIDADE AND 1=1
                        WHERE 1=1 AND T.SEQENCARTE = psSeqEncarte
                          AND T.NROSEGMENTO = seg.Nrosegmento
                          AND T.DTAINICIO   = seg.perINI
                          AND T.DTAFIM      = seg.perFIM) BS )
  LOOP
 
  INSERT INTO MFL_PROMOCPDVITEM XI (SEQPROMOCPDV,
                                   SEQITEMPROMOC,
                                   SEQPRODUTO,
                                   QTDEMBALAGEM,
                                   QUANTIDADE,
                                   TIPOITEMPROMOC,
                                   PRECOITEM,
                                   PERCDESCONTO,
                                   STATUS,
                                   DTAALTERACAO,
                                   USUALTERACAO,
                                   SEQFAMILIA,
                                   PROMOCPORFAMILIA,
                                   NROBASEEXPORTACAO,
                                   SEQGRUPO,
                                   INDVLRREFACORDPROM)
                                  
   
  VALUES (capa.SEQPROMOCPDV,
          item.SEQITEMPROMOC,
          item.SEQPRODUTO,
          1,
          1,
         'P',
          0,
          0,
         'A',
          SYSDATE,
         'MN_ENCARTE',
          item.SEQFAMILIA,
         'N',
          0,
          0,
          2);
         
  END LOOP; -- Loop Item
    
  ---////////// Loop ITEM e LOJA / Preco
  ---////////// Insere os itens por loja de  acordo com o codpromocao da capa ///////////
      
  FOR item_loja IN (SELECT DISTINCT T.NROEMPRESA CODLOJA, PRECO_MN, item_Base.SEQITEMPROMOC,
                           PRECOVALIDNORMAL PRECO_NORMAL,  
                           PRECOVALIDNORMAL - PRECO_MN VLRDESCONTO, 
                           ROUND(((PRECOVALIDNORMAL - T.PRECO_MN) / PRECOVALIDNORMAL) * 100 ,2) PERCDESCONTO,
                           CASE WHEN F.PESAVEL = 'S' THEN 0.01 ELSE 1 END APARTIRDE -- Pesavel insere 0.01
                      FROM MFL_PROMOCPDVITEM item_base INNER JOIN NAGV_BASE_MN_ENCARTE T ON T.SEQFAMILIA = item_base.Seqfamilia AND psIndRepFam = 'S'
                                                                                         OR t.SEQPRODUTO = item_base.SeqProduto AND psIndRepFam = 'N'
                                                       INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = T.NROEMPRESA
                                                       INNER JOIN MRL_PRODEMPSEG S ON S.NROEMPRESA = M.NROEMPRESA AND S.NROSEGMENTO = M.NROSEGMENTOPRINC AND  S.SEQPRODUTO = item_base.SEQPRODUTO AND S.QTDEMBALAGEM = 1
                                                       INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = item_base.SEQFAMILIA
                                                       
                     WHERE item_base.Seqpromocpdv = vSeqPromoc
                       AND T.SEQENCARTE = psSeqEncarte
                       AND PRECOVALIDNORMAL > 0
                       AND PRECO_MN < PRECOVALIDNORMAL
                       AND T.NROSEGMENTO = seg.NroSegmento
                       AND T.DTAINICIO   = seg.perINI
                       AND T.DTAFIM      = seg.perFIM)
                       
                       
  LOOP
    
  INSERT INTO MFL_PROMOCPDVDESCAPARTDE XE (SEQDESCONTO,
                                           TIPODESCONTO,
                                           SEQPROMOCPDV,
                                           SEQITEMPROMOC,
                                           VLRDESCONTO,
                                           PERCDESCONTO,
                                           PRECOPROMOCAO,
                                           QTDAPARTIRDE,
                                           NROEMPRESA,
                                           TIPOPRECO)
      
  VALUES (1,
          1,
          capa.SEQPROMOCPDV,
          item_loja.SEQITEMPROMOC,
          item_loja.VLRDESCONTO,
          item_loja.PERCDESCONTO,
          item_loja.PRECO_MN,
          item_loja.APARTIRDE, -- Pesavel insere 0.01
          item_loja.CODLOJA,
          1);
 
   END LOOP; -- Loop Item_Loja
   
   ---////////// Loop LOJA
   ---////////// Insere as lojas ///////////
   
   FOR emp IN (SELECT DISTINCT vSeqPromoc CODPROMOCAO, T.NROEMPRESA CODLOJA
                 FROM NAGV_BASE_MN_ENCARTE T
                WHERE T.SEQENCARTE = psSeqEncarte
                  AND T.NROSEGMENTO = seg.Nrosegmento
                  AND T.DTAINICIO   = seg.perINI
                  AND T.DTAFIM      = seg.perFIM)
                  
   LOOP
    
   INSERT INTO MFL_PROMOCPDVEMP (SEQPROMOCPDV,
                                 NROEMPRESA,
                                 STATUS,
                                 DTAALTERACAO,
                                 USUALTERACAO,
                                 NROBASEEXPORTACAO)
                          
   VALUES(capa.SEQPROMOCPDV,
          emp.CODLOJA,
          capa.STATUS,
          SYSDATE,
         'MN_ENCARTE',
          0);
                       
   END LOOP; -- Loop Empresa
   
   codErro := NULL;
   
   END LOOP; -- Loop Capa
   END LOOP; -- Loop Segmento
   
   --COMMIT; -- Commit no final
   
   EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Promoc com Erro: ' || codErro);
        DBMS_OUTPUT.PUT_LINE('Error Code: '      || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: '   || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: '     || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('Call Stack: '      || DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE;
   
END;
END;

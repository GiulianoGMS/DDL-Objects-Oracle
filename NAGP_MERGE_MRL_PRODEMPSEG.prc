CREATE OR REPLACE PROCEDURE NAGP_MERGE_MRL_PRODEMPSEG (psSeqProduto NUMBER, psNroEmpresa NUMBER, psQtdEmbalagem NUMBER, psNroSegmento NUMBER) AS

BEGIN 
  -- Insere os itens na auxiliar
 INSERT INTO MRLX_PRODEMPSEG
  (SEQPRODUTO,
   QTDEMBALAGEM,
   NROSEGMENTO,
   NROEMPRESA,
   STATUSVENDA,
   MARGEMLUCROPRODEMPSEG)
 VALUES
  (psSeqProduto, psQtdEmbalagem, psNroSegmento, psNroEmpresa, 'A', NULL);
  -- Faz o merge
   CONSINCO.sp_ProdEmpSegStatusVenda('API',Null,'');
   
   COMMIT;
   
 END;

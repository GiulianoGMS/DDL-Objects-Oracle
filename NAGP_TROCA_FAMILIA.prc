CREATE OR REPLACE PROCEDURE NAGP_TROCA_FAMILIA AS

 psQtdPendente NUMBER(10);

BEGIN

SELECT COUNT(1)
  INTO psQtdPendente
  FROM MAP_ALTERAFAMILIAPRODUTO
 WHERE DTAALTERACAO >= TRUNC(SYSDATE)
   AND INDALTERACAO = 'P';
   
   IF psQtdPendente > 0 THEN

  CONSINCO.PKG_ADM_PRODUTO.SP_TROCAFAMILIASJOB('S');
  /* Chamada do Update apenas para ativar a venda da embalagem 1 na familia replicada, apenas na empresa/segto ativos
   De acordo com o produto que existe na auxiliar e que foi alterado - status 'A' - no dia atual */

  UPDATE CONSINCO.MRL_PRODEMPSEG X SET X.STATUSVENDA = 'A',
                                       X.USUALTERACAO = 'TROCAFAMILIA',
                                       X.DTAALTERACAO = SYSDATE
                                       
                                 WHERE X.SEQPRODUTO IN (SELECT SEQPRODUTO
                                                          FROM MAP_ALTERAFAMILIAPRODUTO
                                                         WHERE INDALTERACAO = 'A'
                                                           AND TRUNC(DTAALTERACAO) = TRUNC(SYSDATE))
                                   AND X.QTDEMBALAGEM = 1
                                   AND NVL(X.STATUSVENDA,'I') = 'I'
                                   AND EXISTS (SELECT 1 FROM MON_EMPRESASEGMENTO E WHERE E.NROEMPRESA = X.NROEMPRESA 
                                                              AND E.NROSEGMENTO = X.NROSEGMENTO
                                                              AND E.ATIVO = 'S');
  COMMIT;
  
   END IF;
   
END;

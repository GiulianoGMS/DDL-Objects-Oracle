Ref https://github.com/GiulianoGMS/Useful_Tools/blob/d884a55406c3eba10b5b7eaaa3ba5b76fc449503/Controle%20Promoc%20Inauguracao.sql#L5

CREATE OR REPLACE PROCEDURE NAGP_CONTROLE_PROMOC_INAUGURACAO (psNroEmpresa NUMBER, psDataAbertura DATE) AS

-- Duas necessidades:
-- 1.: Inativar as promoções que terminam ANTES da inauguração, para que as ofertas que não estarão vigentes não sejam impressas atoa.
-- 2.: Postergar o inicio das ofertas para o dia anterior da inauguração, para que as ofertas não sejam expostas antes evitando vazamento de preços

-- Inativando promocoes que terminam no dia anterior da inauguracao:

BEGIN
  FOR inativar IN (
      SELECT DISTINCT B.STATUS,
                      X.SEQPROMOCAO,
                      X.NROEMPRESA,
                      PROMOCAO,
                      DTAINICIO,
                      DTAFIM,
                      DTAINICIOPROM,
                      DTAFIMPROM,
                      SEQPRODUTO,
                      B.QTDEMBALAGEM
        FROM MRL_PROMOCAO X INNER JOIN MRL_PROMOCAOITEM B ON B.SEQPROMOCAO = X.SEQPROMOCAO AND X.NROEMPRESA = B.NROEMPRESA
       WHERE X.NROEMPRESA = psNroEmpresa
         AND (DTAFIM <= psDataAbertura -1
          OR  DTAFIMPROM <= psDataAbertura - 1)
         AND STATUS = 'A')
   
     LOOP
     
   UPDATE MRL_PROMOCAOITEM B SET B.STATUS = 'I'
                           WHERE B.SEQPROMOCAO = inativar.SEQPROMOCAO
                             AND B.NROEMPRESA  = inativar.NROEMPRESA
                             AND B.SEQPRODUTO  = inativar.SEQPRODUTO;
                                
     END LOOP;
     
-- Ofertas que começam ANTES do dia da inauguracao -1 e terminam depois
-- Ajustando o inicio e suspendendo para reativação:
     
   FOR post IN (
      SELECT DISTINCT B.STATUS,
                      X.SEQPROMOCAO,
                      X.NROEMPRESA,
                      PROMOCAO,
                      DTAINICIO,
                      DTAFIM,
                      DTAINICIOPROM,
                      DTAFIMPROM,
                      SEQPRODUTO,
                      B.QTDEMBALAGEM
        FROM MRL_PROMOCAO X INNER JOIN MRL_PROMOCAOITEM B ON B.SEQPROMOCAO = X.SEQPROMOCAO AND X.NROEMPRESA = B.NROEMPRESA
       WHERE X.NROEMPRESA = psNroEmpresa
         AND (DTAINICIO < psDataAbertura -1 AND DTAFIM >= psDataAbertura -1
          OR  B.DTAINICIOPROM < psDataAbertura -1 AND DTAFIMPROM >= psDataAbertura -1)
         AND STATUS = 'A')
   
     LOOP
     
   UPDATE MRL_PROMOCAOITEM B SET B.STATUS = 'S',
                                 B.DTAINICIOPROM = psDataAbertura - 1
                           WHERE B.SEQPROMOCAO = post.SEQPROMOCAO
                             AND B.NROEMPRESA  = post.NROEMPRESA
                             AND B.SEQPRODUTO  = post.SEQPRODUTO;
                             
   UPDATE MRL_PROMOCAO C     SET C.DTAINICIO   = psDataAbertura - 1
                           WHERE C.SEQPROMOCAO = post.SEQPROMOCAO
                             AND C.NROEMPRESA  = post.NROEMPRESA;
   
     END LOOP;
   
-- Reativando as ofertas suspensas:

   UPDATE MRL_PROMOCAOITEM B SET B.STATUS = 'A'
                           WHERE B.NROEMPRESA = psNroEmpresa
                             AND B.STATUS = 'S';
   
END;

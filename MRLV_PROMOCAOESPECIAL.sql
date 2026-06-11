CREATE OR REPLACE VIEW MRLV_PROMOCAOESPECIAL AS
SELECT A.SEQPRODUTO,
       A.QTDEMBALAGEM,
       A.NROEMPRESA,
       A.CODACESSOESPECIAL,
       A.VLRPRECOPROMOC,
       -- Alt. Giuliano - 26/08/24 - Controle de quantidade
       -- Divide sempre por 2 pois a etiqueta e dupla
       -- CEIL arredonda pra cima pois se for solicitado 11, ira impimir 6 etiquetas (resultando em 12 duplas)
       -- Traz apenas a quantidade nao emitida
       CASE WHEN NVL(A.QTDEETIQEMITIDA,0) = 0 THEN CEIL(A.QTDESOLICITADA/2) ELSE
         CEIL((QTDESOLICITADA - NVL(A.QTDEETIQEMITIDA,0))/2) END QTDESOLICITADA,
       NVL(TRUNC(A.DTAHORAPROVACAO), A.DTAINICIO) DTAINICIO, --A.DTAINICIO, -- Ajuste 11/06 para que no grid retorne na data de aprovação, e nao inicio
       A.DTAFIM,
       NVL(A.INDEMIETIQUETA,'N') AS INDEMIETIQUETA,
       A.SEQPROMOCESPECIAL,
       A.MOTIVOACAOPROMOC
FROM MRL_PROMOCESPECIALHIST A
WHERE A.STATUS = 'A'

 -- Alterado por Giuliano -- Controle de emissao
 -- Retornar apenas se a quantidade impressa for menor que a solicitada

  AND 1 - (NVL(A.QTDEETIQEMITIDA,0) * 2) <= A.QTDESOLICITADA
  AND TRUNC(SYSDATE) BETWEEN A.DTAINICIO AND A.DTAFIM
  AND A.CODACESSOESPECIAL NOT LIKE '77%'
  ORDER BY VLRPRECOPROMOC ASC
;

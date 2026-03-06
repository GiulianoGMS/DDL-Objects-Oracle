CREATE OR REPLACE PROCEDURE NAGP_CONTROLE_SELOS_PDV_v2 (psData DATE) AS

BEGIN
  
  INSERT INTO NAGT_CONTROLE_SELOS_PDV_v2

SELECT 
       NULL DTAAJUSTE,
       NULL USUARIOAJUSTE,     

       A.NROEMPRESA,
       A.NROCHECKOUT,
       C.SEQTURNO,

       SUM(CASE WHEN A.RECUSADO = 'N' THEN A.QTDSELO ELSE 0 END) SELOS_ACEITOS,
       SUM(CASE WHEN A.RECUSADO = 'S' THEN A.QTDSELO ELSE 0 END) SELOS_RECUSADOS,

       F.SELO_INICIAL,
       F.SELO_FINAL,
       F.SELO_INICIAL2,
       F.SELO_FINAL2,
       F.SELO_INICIAL3,
       F.SELO_FINAL3,
       F.SELO_INICIAL4,
       F.SELO_FINAL4,
       F.SELO_INICIAL5,
       F.SELO_FINAL5,

       C.DTAMOVIMENTO,
       C.SEQUSUARIO OPERADOR,
       U.NOME NOME_OPERADOR

FROM MONITORPDV.TB_DOCTOSELO A

JOIN MONITORPDV.TB_DOCTO C
  ON C.NROEMPRESA = A.NROEMPRESA
 AND C.NROCHECKOUT = A.NROCHECKOUT
 AND C.SEQDOCTO = A.SEQDOCTO

JOIN MONITORPDV.TB_DOCTOCUPOM D
  ON D.NROEMPRESA = A.NROEMPRESA
 AND D.NROCHECKOUT = A.NROCHECKOUT
 AND D.SEQDOCTO = A.SEQDOCTO

JOIN MONITORPDV.TB_USUARIO U
  ON U.SEQUSUARIO = C.SEQUSUARIO


LEFT JOIN (

    SELECT
           nroempresa,
           nrocheckout,
           seqturno,
           dtamovimento,
           sequsuario,

           MAX(CASE WHEN faixa = 1 THEN ultcodselo END) selo_inicial,
           MAX(CASE WHEN faixa = 1 THEN codselo END) selo_final,

           MAX(CASE WHEN faixa = 2 THEN ultcodselo END) selo_inicial2,
           MAX(CASE WHEN faixa = 2 THEN codselo END) selo_final2,

           MAX(CASE WHEN faixa = 3 THEN ultcodselo END) selo_inicial3,
           MAX(CASE WHEN faixa = 3 THEN codselo END) selo_final3,
           
           MAX(CASE WHEN faixa = 3 THEN ultcodselo END) selo_inicial4,
           MAX(CASE WHEN faixa = 3 THEN codselo END) selo_final4,
           
           MAX(CASE WHEN faixa = 3 THEN ultcodselo END) selo_inicial5,
           MAX(CASE WHEN faixa = 3 THEN codselo END) selo_final5

    FROM (

            SELECT
                   X.NROEMPRESA,
                   X.NROCHECKOUT,
                   Y.SEQTURNO,
                   Y.DTAMOVIMENTO,
                   Y.SEQUSUARIO,

                   X.ULTCODSELO,
                   X.CODSELO,

                   ROW_NUMBER() OVER(
                       PARTITION BY X.NROEMPRESA,
                                    X.NROCHECKOUT,
                                    Y.SEQTURNO,
                                    Y.DTAMOVIMENTO
                       ORDER BY X.SEQDOCTO
                   ) faixa

            FROM MONITORPDV.TB_DOCTOSELOFAIXA X

            JOIN MONITORPDV.TB_DOCTO Y
              ON Y.NROEMPRESA = X.NROEMPRESA
             AND Y.NROCHECKOUT = X.NROCHECKOUT
             AND Y.SEQDOCTO = X.SEQDOCTO

            WHERE X.TIPO = 'F'

         )

    GROUP BY
           nroempresa,
           nrocheckout,
           seqturno,
           dtamovimento,
           sequsuario

) F

ON F.NROEMPRESA = C.NROEMPRESA
AND F.NROCHECKOUT = C.NROCHECKOUT
AND F.SEQTURNO = C.SEQTURNO
AND F.DTAMOVIMENTO = C.DTAMOVIMENTO
AND F.SEQUSUARIO = C.SEQUSUARIO

-- Remove Duplicidades
WHERE C.DTAMOVIMENTO = psData
AND C.ESPECIE = 'CF'
AND D.CGO IN (76,610,48,612)
AND NOT EXISTS (SELECT 1 FROM NAGT_CONTROLE_SELOS_PDV_v2 Y WHERE Y.NROEMPRESA = A.NROEMPRESA AND Y.NROCHECKOUT = A.NROCHECKOUT AND Y.SEQTURNO = C.SEQTURNO AND Y.DTAMOVIMENTO = C.DTAMOVIMENTO)

GROUP BY
       A.NROEMPRESA,
       A.NROCHECKOUT,
       C.SEQTURNO,
       C.DTAMOVIMENTO,
       C.SEQUSUARIO,
       U.NOME,
       F.SELO_INICIAL,
       F.SELO_FINAL,
       F.SELO_INICIAL2,
       F.SELO_FINAL2,
       F.SELO_INICIAL3,
       F.SELO_FINAL3,
       F.SELO_INICIAL4,
       F.SELO_FINAL4,
       F.SELO_INICIAL5,
       F.SELO_FINAL5

ORDER BY
       3,4,5;
       
       COMMIT;
END;

CREATE OR REPLACE PROCEDURE NAGP_CONTROLE_SELOS_PDV (psData DATE) AS

BEGIN
  
  INSERT INTO NAGT_CONTROLE_SELOS_PDV 

SELECT NULL DTAAJUSTE,
       NULL USUARIOAJUSTE,     
       A.NROEMPRESA,
       A.NROCHECKOUT,
       C.SEQTURNO,
       
       SUM(CASE
             WHEN A.RECUSADO = 'N' THEN
              A.QTDSELO
             ELSE
              0
           END) AS SELOS_ACEITOS,
       
       SUM(CASE
             WHEN A.RECUSADO = 'S' THEN
              A.QTDSELO
             ELSE
              0
           END) AS SELOS_RECUSADOS,
       
       NVL(TO_CHAR(F.ULTCODSELO), 'TURNO_ABERTO') AS SELO_INICIAL,
       NVL(TO_CHAR(F.CODSELO), 'TURNO_ABERTO') AS SELO_FINAL,
       
       NVL(SUM(CASE
                 WHEN A.RECUSADO = 'N' THEN
                  A.QTDSELO
                 ELSE
                  0
               END),
           0) - (NVL(F.CODSELO, 0) - NVL(F.ULTCODSELO, 0) + 1) AS DIFERENCA,
       
       C.DTAMOVIMENTO AS DTAMOVIMENTO,
       C.SEQUSUARIO AS OPERADOR,
       U.NOME AS NOME_OPERADOR

  FROM MONITORPDV.TB_DOCTOSELO A INNER JOIN MONITORPDV.TB_DOCTO C ON C.NROEMPRESA = A.NROEMPRESA
                                                                 AND C.NROCHECKOUT = A.NROCHECKOUT
                                                                 AND C.SEQDOCTO = A.SEQDOCTO
                                 INNER JOIN MONITORPDV.TB_DOCTOCUPOM D ON D.NROEMPRESA = A.NROEMPRESA
                                                                      AND D.NROCHECKOUT = A.NROCHECKOUT
                                                                      AND D.SEQDOCTO = A.SEQDOCTO

                                 INNER JOIN MONITORPDV.TB_USUARIO U ON U.SEQUSUARIO = C.SEQUSUARIO
  LEFT JOIN (
             
             SELECT X.NROEMPRESA,
                     X.NROCHECKOUT,
                     Y.SEQUSUARIO,
                     Y.SEQTURNO,
                     Y.DTAMOVIMENTO,
                     
                     /* SOMA CONDICIONAL POR TIPO */
                     SUM(CASE
                           WHEN X.TIPO = 'F' THEN
                            X.ULTCODSELO
                           ELSE
                            0
                         END) AS ULTCODSELO,
                     
                     SUM(CASE
                           WHEN X.TIPO = 'F' THEN
                            X.CODSELO
                           ELSE
                            0
                         END) AS CODSELO
             
               FROM MONITORPDV.TB_DOCTOSELOFAIXA X
             
               JOIN MONITORPDV.TB_DOCTO Y
                 ON Y.NROEMPRESA = X.NROEMPRESA
                AND Y.NROCHECKOUT = X.NROCHECKOUT
                AND Y.SEQDOCTO = X.SEQDOCTO
             
              GROUP BY X.NROEMPRESA,
                        X.NROCHECKOUT,
                        Y.SEQUSUARIO,
                        Y.SEQTURNO,
                        Y.DTAMOVIMENTO
             
             ) F
    ON F.NROEMPRESA = C.NROEMPRESA
   AND F.NROCHECKOUT = C.NROCHECKOUT
   AND F.SEQUSUARIO = C.SEQUSUARIO
   AND F.SEQTURNO = C.SEQTURNO
   AND F.DTAMOVIMENTO = C.DTAMOVIMENTO

 WHERE 1 = 1
      --AND C.NROEMPRESA = 51
   AND C.ESPECIE = 'CF'
   AND C.DTAMOVIMENTO = psData
   AND D.CGO IN (76, 610, 48, 612)
   
   -- Remove duplicidades
   
   AND NOT EXISTS (SELECT 1 FROM NAGT_CONTROLE_SELOS_PDV Y WHERE Y.NROEMPRESA = F.NROEMPRESA AND Y.NROCHECKOUT = F.NROCHECKOUT AND Y.SEQTURNO = F.SEQTURNO AND Y.DTAMOVIMENTO = F.DTAMOVIMENTO)

 GROUP BY A.NROEMPRESA,
          A.NROCHECKOUT,
          C.SEQTURNO,
          C.DTAMOVIMENTO,
          C.SEQUSUARIO,
          U.NOME,
          F.ULTCODSELO,
          F.CODSELO;
 
 COMMIT;
END;

CREATE OR REPLACE PROCEDURE NAGP_PALIATIVO_GRED_CBSIBS AS

BEGIN
  FOR nfrej IN (

  SELECT C.SEQPRODUTO,
         C.SEQFAMILIA,
         C.NCM,
         C.UF,
         C.CODIBGE,
         C.CIDADE,
         C.CENARIOCBS,
         C.PERALIQCBS,
         C.PERALIQREDCBS,
         C.PERALIQCCREDPRESCBS,
         C.PERALIQREDCCREDPRESCBS,
         C.CSTCBS,
         C.CCLASSTRIBCBS,
         C.CCREDPRESCBS,
         C.MSGERROCBS,
         C.CENARIOIBSUF,
         C.PERALIQIBSUF,
         C.PERALIQREDIBSUF,
         C.PERALIQCCREDPRESIBSUF,
         C.PERALIQREDCCREDPRESIBSUF,
         C.CSTIBSUF,
         C.CCLASSTRIBIBSUF,
         C.CCREDPRESIBSUF,
         C.MSGERROIBSUF,
         C.CENARIOIBSMUN,
         C.PERALIQIBSMUN,
         C.PERALIQREDIBSMUN,
         C.CSTIBSMUN,
         C.CCLASSTRIBIBSMUN,
         C.MSGERROIBSMUN,
         C.CENARIOIS,
         C.PERALIQIS,
         C.PERALIQREDIS,
         C.CSTIS,
         C.CCLASSTRIBIS,
         C.MSGERROIS, A.SEQNF,A.SEQNOTAFISCAL FROM MLF_NOTAFISCAL A INNER JOIN (SELECT DESCRICAO, SEQNOTAFISCAL, ROW_NUMBER() OVER(PARTITION BY SEQNOTAFISCAL ORDER BY DTALOG DESC) RN
                                                 FROM MFL_NFELOG L WHERE 1=1 AND UPPER(L.DESCRICAO) LIKE '%RED%' ORDER BY L.DTALOG DESC) L ON L.SEQNOTAFISCAL = A.SEQNOTAFISCAL AND L.RN = 1
                                 INNER JOIN MLF_NFITEM B ON B.SEQNF = A.SEQNF
                                 INNER JOIN NAGV_PDV_CCT C ON C.SEQPRODUTO = B.SEQPRODUTO
    WHERE 1=1 AND A.STATUSNFE = 5 AND A.DTAEMISSAO >= SYSDATE - 3
      AND (SELECT COUNT(1) FROM NAGT_PALIAT_DEV D WHERE D.SEQNF = A.SEQNF AND MOT = 'Reducao') <= 3

    )

    LOOP

   --======= Insere o seq na tabela de controle =======--

   INSERT INTO NAGT_PALIAT_DEV VALUES (nfrej.SEQNF, 'Reducao');

   --======= =======--

       UPDATE MLF_NFITEM XI
             SET XI.CENARIOIBSMUN       = nfrej.CENARIOIBSMUN,
                 XI.CENARIOIBSUF        = nfrej.CENARIOIBSUF,
                 XI.CENARIOCBS          = nfrej.CENARIOCBS,

                 XI.CCLASSTRIBIBSMUN    = nfrej.CCLASSTRIBIBSMUN,
                 XI.CCLASSTRIBIBSUF     = nfrej.CCLASSTRIBIBSUF,
                 XI.CCLASSTRIBCBS       = nfrej.CCLASSTRIBCBS,

                 XI.CSTIBSMUN           = nfrej.CSTIBSMUN,
                 XI.CSTIBSUF            = nfrej.CSTIBSUF,
                 XI.CSTCBS              = nfrej.CSTCBS,

                 XI.PERALIQREDIBSMUN    = nfrej.PERALIQREDIBSMUN,
                 XI.PERALIQREDIBSUF     = nfrej.PERALIQREDIBSUF,
                 XI.PERALIQREDCBS       = nfrej.PERALIQREDCBS,

                 -- Alíquotas efetivas
                 XI.PERALIQEFETIVAIBSMUN =
                     ROUND(
                         NVL(nfrej.PERALIQIBSMUN, 0) *
                         (1 - NVL(nfrej.PERALIQREDIBSMUN, 0) / 100),
                         4
                     ),

                 XI.PERALIQEFETIVAIBSUF =
                     ROUND(
                         NVL(nfrej.PERALIQIBSUF, 0) *
                         (1 - NVL(nfrej.PERALIQREDIBSUF, 0) / 100),
                         4
                     ),

                 XI.PERALIQEFETIVACBS =
                     ROUND(
                         NVL(nfrej.PERALIQCBS, 0) *
                         (1 - NVL(nfrej.PERALIQREDCBS, 0) / 100),
                         4
                     ),

                 -- Valor do IBS UF
                 XI.VLRIMPOSTOIBSUF =
                     ROUND(
                         NVL(XI.VLRBASEIBSUF, 0) *
                         (
                             NVL(nfrej.PERALIQIBSUF, 0) *
                             (1 - NVL(nfrej.PERALIQREDIBSUF, 0) / 100)
                             / 100
                         ),
                         2
                     ),

                 -- Valor da CBS
                 XI.VLRIMPOSTOCBS =
                     ROUND(
                         NVL(XI.VLRBASECBS, 0) *
                         (
                             NVL(nfrej.PERALIQCBS, 0) *
                             (1 - NVL(nfrej.PERALIQREDCBS, 0) / 100)
                             / 100
                         ),
                         2
                     )

           WHERE XI.SEQPRODUTO = nfrej.SEQPRODUTO
             AND XI.SEQNF      = nfrej.SEQNF;

     COMMIT;
     SP_EXPORTANFE(nfrej.SEQNOTAFISCAL, 'E');
     COMMIT;
     END LOOP;

 END;

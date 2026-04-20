CREATE OR REPLACE VIEW NAGV_MASTER_VALID_CADASTROS AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       -- Criado por Giuliano durante a vida humana e valida tudo de errado que o fiscal quis juntar
       SEQPRODUTO PLU, SEQFAMILIA COD_FAMILIA, DESCCOMPLETA DESC_PRODUTO,
       'Inconsistência(s): '||INC1||
       CASE WHEN INC2  IS NOT NULL THEN ' | '||INC2  ELSE NULL END||
       CASE WHEN INC3  IS NOT NULL THEN ' | '||INC3  ELSE NULL END||
       CASE WHEN INC4  IS NOT NULL THEN ' | '||INC4  ELSE NULL END||
       CASE WHEN INC5  IS NOT NULL THEN ' | '||INC5  ELSE NULL END||
       CASE WHEN INC6  IS NOT NULL THEN ' | '||INC6  ELSE NULL END||
       CASE WHEN INC7  IS NOT NULL THEN ' | '||INC7  ELSE NULL END||
       CASE WHEN INC8  IS NOT NULL THEN ' | '||INC8  ELSE NULL END||
       CASE WHEN INC9  IS NOT NULL THEN ' | '||INC9  ELSE NULL END||
       CASE WHEN INC10 IS NOT NULL THEN ' | '||INC10 ELSE NULL END||
       CASE WHEN INC11 IS NOT NULL THEN ' | '||INC11 ELSE NULL END||
       CASE WHEN INC12 IS NOT NULL THEN ' | '||INC12 ELSE NULL END||
       CASE WHEN INC13 IS NOT NULL THEN ' | '||INC13 ELSE NULL END||
       CASE WHEN INC14 IS NOT NULL THEN ' | '||INC14 ELSE NULL END||
       CASE WHEN INC15 IS NOT NULL THEN ' | '||INC15 ELSE NULL END||
       CASE WHEN INC16 IS NOT NULL THEN ' | '||INC16 ELSE NULL END||
       CASE WHEN INC17 IS NOT NULL THEN ' | '||INC17 ELSE NULL END||
       CASE WHEN INC18 IS NOT NULL THEN ' | '||INC18 ELSE NULL END||
       CASE WHEN INC19 IS NOT NULL THEN ' | '||INC19 ELSE NULL END||
       CASE WHEN INC20 IS NOT NULL THEN ' | '||INC20 ELSE NULL END||
       CASE WHEN INC21 IS NOT NULL THEN ' | '||INC21 ELSE NULL END
       INCONSISTENCIAS
  FROM (

SELECT SEQPRODUTO, MP.SEQFAMILIA, DESCCOMPLETA,
       -- Comeca Case de Tratativas
       -- Familias sem fleg Participa Controle Estoque ST
       CASE WHEN EXISTS (
       SELECT 1 FROM CONSINCO.MAP_FAMDIVISAO X
        WHERE NVL(X.INDMERCENQUADST, 'X') != 'S'
          AND X.SEQFAMILIA =  MP.SEQFAMILIA
          AND 1=2) -- Retirado 21/01 Ticket 680964
       THEN 'Sem fleg Participa Controle Estoque ST' END INC1,
       -- Famílias sem NCM e CST PIS e COFINS
       CASE WHEN EXISTS (
       SELECT 1 FROM MAP_FAMILIA F
        WHERE F.SEQFAMILIA = MP.SEQFAMILIA
          AND (F.CODNBMSH IS NULL
           OR F.SITUACAONFPIS IS NULL
           OR F.SITUACAONFCOFINS IS NULL
           OR F.SITUACAONFIPISAI IS NULL
           OR F.SITUACAONFCOFINSSAI IS NULL)
          )
       THEN 'Sem NCM e CST PIS/COFINS'               END INC2,
       -- Prod sem EAN com fleg 'EAN TRIB DANFE'
       CASE WHEN EXISTS (
         SELECT 1 FROM MAP_PRODCODIGO X
          WHERE X.SEQPRODUTO NOT IN (SELECT DISTINCT SEQPRODUTO FROM MAP_PRODCODIGO Z WHERE Z.TIPCODIGO = 'E' AND Z.INDEANTRIBNFE = 'S' AND Z.SEQPRODUTO = X.SEQPRODUTO)
            AND X.TIPCODIGO = 'E'
            AND X.SEQPRODUTO = MP.SEQPRODUTO
            AND 1=2) -- Retirado 21/01 Ticket 680964
       THEN 'Sem EAN com fleg "EAN TRIB DANFE"'      END INC3,
       -- Saída CST IPI diferente de 50/53
       CASE WHEN EXISTS (
         SELECT 1 FROM CONSINCO.MAP_FAMILIA X
          WHERE NVL(X.SITUACAONFIPISAI, 0) NOT IN (50, 53) AND X.SEQFAMILIA =  MP.SEQFAMILIA)
       THEN 'CST IPI Saida diferente de 50/53'       END INC4,
       -- Tributação/Origem IMP x NAC
       CASE WHEN EXISTS (
         SELECT 1 FROM CONSINCO.MAP_FAMDIVISAO A LEFT JOIN CONSINCO.MAP_TRIBUTACAO B ON A.NROTRIBUTACAO = B.NROTRIBUTACAO
          WHERE A.SEQFAMILIA = MP.SEQFAMILIA
            AND ((UPPER(TRIBUTACAO) LIKE '%IMP%' OR UPPER(TRIBUTACAO) LIKE 'IM%')    AND CODORIGEMTRIB NOT IN (1,2,3,6,8,7) AND UPPER(TRIBUTACAO) NOT LIKE '%LIMP%'
             OR  UPPER(TRIBUTACAO) LIKE '%IMP.LIMP%'                                 AND CODORIGEMTRIB NOT IN (1,2,3,6,8,7)))
       THEN 'IMP/IM.D com origem NAC'                END INC5,
       -- Tributação/Origem NAC x IMP
       CASE WHEN EXISTS (
         SELECT 1 FROM CONSINCO.MAP_FAMDIVISAO A LEFT JOIN CONSINCO.MAP_TRIBUTACAO B ON A.NROTRIBUTACAO = B.NROTRIBUTACAO
          WHERE A.SEQFAMILIA = MP.SEQFAMILIA
           AND (TRIBUTACAO NOT LIKE '%IMP%'   AND CODORIGEMTRIB NOT IN (0,4,5,7) AND TRIBUTACAO NOT LIKE 'IM%'
             OR TRIBUTACAO NOT LIKE 'IM%'     AND CODORIGEMTRIB NOT IN (0,4,5,7) AND TRIBUTACAO NOT LIKE 'IMP%' AND TRIBUTACAO NOT LIKE 'IM.C%'
             OR TRIBUTACAO     LIKE '%LIMP%'  AND CODORIGEMTRIB NOT IN (0,4,5,7) AND TRIBUTACAO NOT LIKE 'IMP%' AND TRIBUTACAO NOT LIKE 'IM.C%'))

       THEN 'NAC com origem IMP'                     END INC6,
       -- Aliquota = 0 e CST IPI Diferente de 03
       CASE WHEN EXISTS (
          SELECT 1 FROM CONSINCO.MAP_PRODUTO X INNER JOIN CONSINCO.MAP_FAMILIA    Z ON X.SEQFAMILIA = Z.SEQFAMILIA
                                               INNER JOIN CONSINCO.MAP_FAMFORNEC  F ON F.SEQFAMILIA = Z.SEQFAMILIA
                                               INNER JOIN CONSINCO.GE_PESSOA      G ON G.SEQPESSOA  = F.SEQFORNECEDOR
           WHERE NVL(Z.ALIQUOTAIPI,0) = 0
             AND NVL(Z.SITUACAONFIPI, '123') != '03'
             AND F.PRINCIPAL = 'S'
             AND G.UF = 'EX'
             AND X.SEQPRODUTO = MP.SEQPRODUTO)
       THEN '(EX) Aliquota = 0 e CST IPI Diferente de 03' END INC7,
      -- Aliquota != 0 e CST IPI Diferente de 00
       CASE WHEN EXISTS (
          SELECT 1 FROM CONSINCO.MAP_PRODUTO X INNER JOIN CONSINCO.MAP_FAMILIA    Z ON X.SEQFAMILIA = Z.SEQFAMILIA
                                               INNER JOIN CONSINCO.MAP_FAMFORNEC  F ON F.SEQFAMILIA = Z.SEQFAMILIA
                                               INNER JOIN CONSINCO.GE_PESSOA      G ON G.SEQPESSOA  = F.SEQFORNECEDOR
           WHERE NVL(Z.ALIQUOTAIPI,0) > 0
             AND NVL(Z.SITUACAONFIPI, '123') != '00'
             AND F.PRINCIPAL = 'S'
             AND G.UF = 'EX'
             AND X.SEQPRODUTO = MP.SEQPRODUTO)
       THEN '(EX) Aliquota MAIOR que 0 e CST IPI Diferente de 00' END INC8,
       -- Fam sem Fleg "Usa dados regime CGO quando existe"
       CASE WHEN EXISTS (
         SELECT 1 FROM CONSINCO.MAP_FAMDIVISAO A
          WHERE NVL(A.INDUSADADOSREGCGO,'N') = 'N'
            AND A.SEQFAMILIA = MP.SEQFAMILIA)
       THEN 'Família sem Fleg "Usa Dados do Regime CGO quando existe"' END INC9,
       -- Valida se o PIS/COFINS é nulo ou igual a 1,65/7,60 (errados) | Certo é 2,10 e 9,65
       CASE WHEN EXISTS (
         SELECT 1 FROM MAP_FAMDIVISAO FD INNER JOIN MAP_FAMFORNEC FC ON FC.SEQFAMILIA = FD.SEQFAMILIA
                                         INNER JOIN MAP_TRIBUTACAOUF UF ON UF.NROTRIBUTACAO = FD.NROTRIBUTACAO
                                         INNER JOIN MAF_FORNECEDOR F ON F.SEQFORNECEDOR = FC.SEQFORNECEDOR
                                         INNER JOIN GE_PESSOA GE ON GE.SEQPESSOA = FC.SEQFORNECEDOR
          WHERE 1=1
          AND GE.UF = 'EX'
          AND UF.UFCLIENTEFORNEC = 'EX'
          AND (NVL(NULLIF(UF.PERPISDIF,0),1.65)    = 1.65 AND NVL(UF.SITUACAONFPIS,0) NOT IN (73,70)
           OR NVL(NULLIF(UF.PERCOFINSDIF,0),7.60) = 7.60  AND NVL(UF.SITUACAONFCOFINS,0) NOT IN (73,70))
          AND UF.NROREGTRIBUTACAO = 8 -- Importacao Direta
          AND UF.UFEMPRESA = 'SP'
          AND UF.TIPTRIBUTACAO = DECODE(NVL(FC.TIPFORNECEDORFAM,F.TIPFORNECEDOR) , 'I', 'EI', 'D', 'ED')
          AND FD.SEQFAMILIA = MP.SEQFAMILIA)
       THEN '(EX) PIS/COFINS nulo ou igual a 1,65/7,60' END INC10,
       -- Valida se o IPI está correto nos produtos EX
       CASE WHEN EXISTS (
         SELECT 1 FROM MAP_FAMILIA MF INNER JOIN MAP_FAMFORNEC FC ON FC.SEQFAMILIA = MF.SEQFAMILIA
                                      INNER JOIN GE_PESSOA GE ON GE.SEQPESSOA = FC.SEQFORNECEDOR
          WHERE 1=1
            AND UF = 'EX'
            AND NVL(MF.ALIQUOTAIPI,0) > 0
            AND (MF.PERISENTOIPI IS NULL
             OR MF.PEROUTROIPI IS NULL
             OR MF.PERALIQUOTAIPI IS NULL
             OR NVL(MF.PERBASEIPI,0) = 0)
            AND MF.SEQFAMILIA = MP.SEQFAMILIA)
        THEN '(EX) Produto com entrada de IPI sem saída parametrizada' END INC11,
        -- Valida se o forne na familia é Industria para produtos importados (SeqFornec 502 e 503)
        CASE WHEN EXISTS (
          SELECT * FROM MAP_FAMFORNEC FC INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = FC.SEQFAMILIA
           WHERE FC.SEQFORNECEDOR IN (502,503)
             AND NVL(FC.TIPFORNECEDORFAM, 'X') != 'I'
             AND EXISTS (SELECT 1 FROM MAP_FAMFORNEC EX INNER JOIN GE_PESSOA G ON G.SEQPESSOA = EX.SEQFORNECEDOR
                                 WHERE EX.SEQFAMILIA = FC.SEQFAMILIA
                                   AND UF = 'EX')
             --AND NVL(FD.FINALIDADEFAMILIA,'X') != 'U'
             AND FC.SEQFAMILIA = MP.SEQFAMILIA)
        THEN '(EX) Familia do Prod. EX sem parametrização de Industria (Fornec 502/503)' END INC12,

        CASE WHEN EXISTS(
          SELECT DISTINCT F.SEQFAMILIA, F.ALIQUOTAIPI, F.CODNBMSH
            FROM MAP_FAMFORNEC FC INNER JOIN MAP_FAMILIA F ON F.SEQFAMILIA = FC.SEQFAMILIA
                                   LEFT JOIN NAGT_DEPARA_TICKET464111 DP2 ON DP2.CODNBMSH = F.CODNBMSH
           WHERE FC.SEQFORNECEDOR IN (502,503)
             AND EXISTS (SELECT 1 FROM MAP_FAMFORNEC EX INNER JOIN GE_PESSOA G ON G.SEQPESSOA = EX.SEQFORNECEDOR
                          WHERE EX.SEQFAMILIA = FC.SEQFAMILIA
                            AND UF = 'EX')
             AND NOT EXISTS (SELECT 2 FROM NAGT_DEPARA_TICKET464111 DP WHERE DP.CODNBMSH = NVL(F.CODNBMSH,12345678) AND DP.ALIQUOTAIPI = NVL(F.ALIQUOTAIPI,100))
             AND DP2.CODNBMSH  IS NOT NULL
             AND F.SEQFAMILIA = MP.SEQFAMILIA)
        THEN '(EX) Aliquota da IPI na familia é diferente da Alíquota de IPI na Regra - NCM:'
             ||(SELECT FF.CODNBMSH||' Aliq. C5: '||FF.ALIQUOTAIPI||' - Regra: '||LISTAGG(XX.ALIQUOTAIPI, ' ou ') WITHIN GROUP (ORDER BY SEQFAMILIA)
                  FROM MAP_FAMILIA FF INNER JOIN (SELECT DISTINCT CODNBMSH, ALIQUOTAIPI FROM NAGT_DEPARA_TICKET464111) XX ON XX.CODNBMSH = FF.CODNBMSH
                 WHERE FF.SEQFAMILIA = MP.SEQFAMILIA
                 GROUP BY FF.ALIQUOTAIPI, FF.CODNBMSH) END                                   INC13,
        CASE WHEN EXISTS(
          SELECT 1 FROM MAP_FAMILIA MF INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = MF.SEQFAMILIA
                                       INNER JOIN MAP_TRIBUTACAOUF X ON X.NROTRIBUTACAO = FD.NROTRIBUTACAO
                                       INNER JOIN MAP_TRIBUTACAO M ON M.NROTRIBUTACAO = X.NROTRIBUTACAO
                                       INNER JOIN (SELECT *
                                        FROM MAP_TRIBUTACAOUF XC
                                       WHERE 1=1
                                         AND XC.TIPTRIBUTACAO = 'SC'
                                         AND XC.SITUACAONF NOT IN ('060', '090')) XC ON XC.UFEMPRESA = X.UFEMPRESA
                                                                       AND XC.UFEMPRESA = XC.UFCLIENTEFORNEC
                                                                       AND XC.NROREGTRIBUTACAO = X.NROREGTRIBUTACAO
                                                                       AND XC.NROTRIBUTACAO = X.NROTRIBUTACAO
                    WHERE 1=1
                      AND X.TIPTRIBUTACAO = 'EI'
                      AND X.UFEMPRESA IN ('SP','RJ')
                      AND X.NROREGTRIBUTACAO = 0
                      AND X.UFEMPRESA = X.UFCLIENTEFORNEC
                      AND NVL(X.PERACRESCST,0)   > 0
                      AND NVL(X.PERALIQUOTAST,0) > 0
                      AND NVL(X.PERTRIBUTST,0)   > 0

                   AND MF.SEQFAMILIA = MP.SEQFAMILIA)
         THEN 'Prod com Parametros ST e CST Diferente de 060, 090 na tributação' END               INC14,
         CASE WHEN EXISTS(
         SELECT 1 FROM MAP_FAMILIA MF INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = MF.SEQFAMILIA
                                       INNER JOIN MAP_TRIBUTACAOUF X ON X.NROTRIBUTACAO = FD.NROTRIBUTACAO
                                       INNER JOIN MAP_TRIBUTACAO M ON M.NROTRIBUTACAO = X.NROTRIBUTACAO
                                       INNER JOIN (SELECT *
                                        FROM MAP_TRIBUTACAOUF XC
                                       WHERE 1=1
                                         AND XC.TIPTRIBUTACAO = 'SC'
                                         AND XC.SITUACAONF NOT IN ('000','020','040','041','051','090')) XC ON XC.UFEMPRESA = X.UFEMPRESA
                                                                       AND XC.UFEMPRESA = XC.UFCLIENTEFORNEC
                                                                       AND XC.NROREGTRIBUTACAO = X.NROREGTRIBUTACAO
                                                                       AND XC.NROTRIBUTACAO = X.NROTRIBUTACAO
                    WHERE 1=1
                      AND X.TIPTRIBUTACAO = 'EI'
                      AND X.UFEMPRESA IN ('SP','RJ')
                      AND X.NROREGTRIBUTACAO = 0
                      AND X.UFEMPRESA = X.UFCLIENTEFORNEC
                      AND NVL(X.PERACRESCST,0)   = 0
                      AND NVL(X.PERALIQUOTAST,0) = 0
                      AND NVL(X.PERTRIBUTST,0)   = 0

                   AND MF.SEQFAMILIA = MP.SEQFAMILIA)
         THEN 'Prod sem Parametros ST e CST diferente de 000,020,040,041,051,090 na tributação' END        INC15,
         CASE WHEN EXISTS(
         SELECT 1
           FROM MAP_FAMILIA MF
          WHERE (NVL(MF.PERBASEPIS, 0) > 0 OR NVL(MF.PERBASECOFINS, 0) > 0)
            AND MF.SEQFAMILIA = MP.SEQFAMILIA)
         THEN 'Familia com Redução de PIS/COFINS!'                                     END INC16,
         CASE WHEN EXISTS(
         SELECT 1 FROM MAP_FAMILIA MF INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = MF.SEQFAMILIA
          WHERE NVL(MF.PMTMULTIPLICACAO, 'N') != 'S'
            AND MF.SEQFAMILIA = MP.SEQFAMILIA
            AND FD.FINALIDADEFAMILIA NOT IN ('R', 'P')
            AND 1=2) -- Retirado 21/01 Ticket 680964
         THEN 'Prod Sem fleg "Permite Multpiplicação" na Família!' END INC17,
         CASE WHEN EXISTS (
           -- Ticket 691854
           -- Giuliano 24/02/26

            -- Primeiro filtra import
           SELECT 1 FROM MAP_FAMDIVISAO B INNER JOIN CONSINCO.MAP_TRIBUTACAO C ON B.NROTRIBUTACAO = C.NROTRIBUTACAO
                                          INNER JOIN MAP_TRIBUTACAOUF T ON T.NROTRIBUTACAO = B.NROTRIBUTACAO AND T.NROREGTRIBUTACAO = 0 AND T.UFEMPRESA = 'SP' AND T.UFCLIENTEFORNEC = 'RJ' AND T.TIPTRIBUTACAO = 'SC'

            WHERE ((UPPER(TRIBUTACAO) LIKE '%IMP%' OR UPPER(TRIBUTACAO) LIKE 'IM%')      AND CODORIGEMTRIB  IN (1,2,3,6,7,8) AND UPPER(TRIBUTACAO) NOT LIKE '%LIMP%'
               OR   UPPER(TRIBUTACAO) LIKE '%IMP.LIMP%'                                  AND CODORIGEMTRIB  IN (1,2,3,6,7,8))
              AND T.PERALIQUOTA != 4 AND T.PERALIQUOTA != 0
              AND B.SEQFAMILIA = MP.SEQFAMILIA)

          THEN 'Prod Trib. IMP com Aliquota diferente de 4!' END INC18,
          CASE WHEN EXISTS (
            -- Depois filtra nacional
          SELECT 1 FROM MAP_FAMDIVISAO B INNER JOIN CONSINCO.MAP_TRIBUTACAO C ON B.NROTRIBUTACAO = C.NROTRIBUTACAO
                                         INNER JOIN MAP_TRIBUTACAOUF T ON T.NROTRIBUTACAO = B.NROTRIBUTACAO AND T.NROREGTRIBUTACAO = 0 AND T.UFEMPRESA = 'SP' AND T.UFCLIENTEFORNEC = 'RJ' AND T.TIPTRIBUTACAO = 'SC'


            WHERE (UPPER(C.TRIBUTACAO) NOT LIKE '%IM%' AND CODORIGEMTRIB IN (0,4,5,6)
              AND T.PERALIQUOTA = 4 AND PERALIQUOTA != 0)
              AND B.SEQFAMILIA = MP.SEQFAMILIA
              AND B.NROTRIBUTACAO NOT IN (1,1187))
          THEN 'Prod Trib. NAC com Aliquota igual à 4!' END INC19,
          CASE WHEN EXISTS (
          SELECT 1 FROM MAP_TRIBUTACAOUF T WHERE T.NROTRIBUTACAO = FD.NROTRIBUTACAO AND RPAD(T.SITUACAONF,3,0) IN ('020','030','040','041','050','070')
                                                                                    AND UFEMPRESA IN ('SP','RJ')
                                                                                    AND UFCLIENTEFORNEC = UFEMPRESA
                                                                                    AND T.TIPTRIBUTACAO = 'SC'
                                                                                    AND T.NROREGTRIBUTACAO = 0
                 AND (NVL(T.INDCALCICMSDESONOUTROS, 'N') = 'N'
                   OR T.CODAJUSTEINFAD IS NULL
                   OR T.MOTIVODESONERACAO IS NULL)
                   AND FD.NROTRIBUTACAO NOT IN (1,1187)
            )
          THEN 'Familia/Trib sem cBenef parametrizado - Trib: '||FD.NROTRIBUTACAO END INC20,
       -- 715679   
       CASE WHEN EXISTS (
                          SELECT 1
                            FROM MAP_TRIBUTACAOUF X
                           WHERE X.UFCLIENTEFORNEC = X.UFEMPRESA
                             AND UFEMPRESA = 'RJ'
                             AND X.SITUACAONF = '020'
                             AND X.NROREGTRIBUTACAO = 0
                             AND X.TIPTRIBUTACAO = 'SN'
                             AND X.PERTRIBUTADO != 100
                             AND X.BASEFCPICMS != X.PERTRIBUTADO
                             AND X.NROTRIBUTACAO = FD.NROTRIBUTACAO
            )
          THEN 'Perc Base FCP Diferente do Perc Tributado! Trib: '||FD.NROTRIBUTACAO END INC21

  FROM MAP_PRODUTO MP INNER JOIN MAP_FAMDIVISAO FD ON FD.SEQFAMILIA = MP.SEQFAMILIA
 WHERE FD.FINALIDADEFAMILIA NOT IN ('P') -- Solicitado Dani em 27/01/25 -- Remover MP

  ) vMaster WHERE COALESCE(INC1,  INC2,  INC3,  INC4,  INC5,  INC6,
                           INC7,  INC8,  INC9,  INC10, INC11, INC12,
                           INC13, INC14, INC15, INC16, INC17, INC18, INC19, INC20, INC21) IS NOT NULL
;

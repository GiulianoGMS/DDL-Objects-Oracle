-- Ticket 699202
-- Adicionado por Giuliano em 06/03/2026
-- Nao permite vincular NF de complemento de impostos
UNION ALL
SELECT A.IDSESSION,
       A.INST_ID,
       A.SEQNFDEVFORNEC,
       A.SEQPRODUTO,
       17 CODCRITICA,
       'Não é permitido vincular item de nota complementar. Verifique o item: '||A.SEQPRODUTO MENSAGEM,
       'B' INDBLOQUEIOLIBERA
  FROM MFLX_NFDEVFORNEC A INNER JOIN MLF_NOTAFISCAL X ON X.SEQNF = A.SEQNFREF
                          INNER JOIN MAX_CODGERALOPER CC ON CC.CODGERALOPER = X.CODGERALOPER
 WHERE 1=1
   AND CC.INDCOMPLVLRIMP = 'S'

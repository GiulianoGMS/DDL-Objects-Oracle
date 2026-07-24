CREATE OR REPLACE VIEW NAGV_ETIQ_INFNUTRIC AS
SELECT /*+OPTIMIZER_FEATURES_ENABLE('11.2.0.4')*/
       NULL MARCA, A."NROEMPRESA",A."SEQPRODUTO",A."DTABASEPRECO",A."CODACESSO",A."QTDETIQUETA",A."DTAPROMINICIO",
       A."DTAPROMFIM",A."CODACESSOPADRAO",A."EMBALAGEMPADRAO",A."PADRAOEMBVENDA",A."PRECOEMBPADRAO",A.PRECOVALIDNORMAL,A.PRECOVALIDPROMOC,A."MULTEQPEMBPADRAO",
       A."QTDUNIDEMBPADRAO",A."TIPOETIQUETA",A."TIPOPRECO",A."DESCCOMPLETA",A."DESCREDUZIDA",A."QTDEMBALAGEM1",A."MULTEQPEMB1",
       A."QTDUNIDEMB1",A."QTDEMBALAGEM2",A."MULTEQPEMB2",A."QTDUNIDEMB2",A."QTDEMBALAGEM3",A."MULTEQPEMB3",A."QTDUNIDEMB3",
       A."QTDEMBALAGEM4",A."MULTEQPEMB4",A."QTDUNIDEMB4",A."QTDEMBALAGEM5",A."MULTEQPEMB5",A."QTDUNIDEMB5",A."CODACESSO1",A."CODACESSO2",
       A."CODACESSO3",A."CODACESSO4",A."CODACESSO5",A."PRECO1",A."PRECO2",A."PRECO3",A."PRECO4",A."PRECO5",A."PRECOMIN",A."PRECOMAX",
       A."EMBALAGEM1",A."EMBALAGEM2",A."EMBALAGEM3",A."EMBALAGEM4",A."EMBALAGEM5",A."TIPOCODIGO", A.QTDEMBCODACESSO,


       '^XA' || '^PRA^FS' || '^LH00,00^FS'|| '^BY2^FS' || '^PQ' || NVL(A.QTDETIQUETA, 1) || '^FS'||

       '^XA'                                                                             || CHR(13) || CHR(10) ||
       '^CI28'                                                                           || CHR(13) || CHR(10) ||
       '^PW800'                                                                          || CHR(13) || CHR(10) ||
       '^LL1000'                                                                         || CHR(13) || CHR(10) ||  '^PQ' || NVL(A.QTDETIQUETA, 1) ||
       '^LH54,385'                                                                       || CHR(13) || CHR(10) ||

       -- TITULO
       '^FO20,23^A0N,32,34^FB480,1,0,C^FD'||UPPER(SUBSTR(P.DESCCOMPLETA,1,40))||'^FS'     || CHR(13) || CHR(10) ||
       '^FO13,55^GB490,3,3^FS'                                                            || CHR(13) || CHR(10) ||

       -- PESO
       '^FO345,70^A0N,16,16^FDPeso Liq.:^FS'                                              || CHR(13) || CHR(10) ||
       '^FO325,92^A0N,32,32^FD'||TO_CHAR(E.PESOLIQUIDO,'FM9990D000','NLS_NUMERIC_CHARACTERS='',.''')||'g^FS' || CHR(13) || CHR(10) ||

       -- DADOS (embalagem / peso emb)
       '^FO20,65^A0N,16,16^FDEmb.: '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||'^FS'                || CHR(13) || CHR(10) || 
       '^FO20,85^A0N,16,16^FDPeso Emb.: 6 g^FS'                 || CHR(13) || CHR(10) || 

       -- RASTREAMENTO / ORIGEM
       '^FO20,105^A0N,16,16^FDLote: '||
            NVL((SELECT MAX(X.SEQNF) FROM MLF_NOTAFISCAL X
                  INNER JOIN MLF_NFITEM XI ON XI.SEQNF = X.SEQNF
                 WHERE X.DTAENTRADA >= SYSDATE - 30 AND X.NROEMPRESA > 500 AND XI.SEQPRODUTO = P.SEQPRODUTO), 90000404)
            ||'^FS'                                                                       || CHR(13) || CHR(10) ||
       '^FO200,85^A0N,16,16^FDPRODUTO^FS'                                                 || CHR(13) || CHR(10) ||
       '^FO200,105^A0N,16,16^FDDO BRASIL^FS'                                              || CHR(13) || CHR(10) || -- TODO: puxar uf da nota do cd

       -- QR CODE
       '^FO425,35^BQN,2,2'                                                                || CHR(13) || CHR(10) ||
       '^FDQA,https://shre.ink/jDCi^FS'                                                   || CHR(13) || CHR(10) || 

       -- PLU VERTICAL
       '^FO488,64^A0R,14,18,C^FD'||P.SEQPRODUTO||'^FS'                                    || CHR(13) || CHR(10) || 

       -- QUADRO TABELA
       '^FO13,125^GB490,330,2^FS'                                                         || CHR(13) || CHR(10) ||
       '^FO22,155^GB470,1,1^FS'                                                           || CHR(13) || CHR(10) ||

       -- CABECALHO NUTRICIONAL
       '^FO25,135^A0N,18,20^FB480,1,0,C^FDINFORMACAO NUTRICIONAL^FS'                      || CHR(13) || CHR(10) ||
       '^FO20,166^A0N,16,18^FDPorcoes por embalagem: Cerca de '
            ||TO_CHAR(ROUND(E.PESOLIQUIDO *1000 / NULLIF(T.QTDPORCAO,0)))||'^FS'          || CHR(13) || CHR(10) ||
       '^FO20,183^A0N,16,18^FDPorcao: '||T.QTDPORCAO||' g^FS'                             || CHR(13) || CHR(10) || -- TODO: acrescentar medida caseira ("1/2 xicara de cha") -- falta de-para de MEDCASEIRA/INTMEDCASEIRA/DECMEDCASEIRA

       '^FO20,270^GB480,1,1^FS'                                                           || CHR(13) || CHR(10) ||

       -- COLUNAS
       '^FO285,210^GB1,221,1^FS'                                                          || CHR(13) || CHR(10) ||
       '^FO355,210^GB1,221,1^FS'                                                          || CHR(13) || CHR(10) ||
       '^FO425,210^GB1,221,1^FS'                                                          || CHR(13) || CHR(10) ||

       -- CABECALHO TABELA
       '^FO20,215^A0N,14,14^FDItem^FS'                                                     || CHR(13) || CHR(10) ||
       '^FO300,215^A0N,14,14^FD100g^FS'                                                    || CHR(13) || CHR(10) ||
       '^FO375,215^A0N,14,14^FD'||T.QTDPORCAO||'g^FS'                                      || CHR(13) || CHR(10) ||
       '^FO440,215^A0N,14,14^FD%VD*^FS'                                                    || CHR(13) || CHR(10) ||

       '^FO20,290^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||
       '^FO20,207^GB476,2,1^FS'                                                            || CHR(13) || CHR(10) ||
       '^FO20,230^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||
       '^FO20,250^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- LINHA Valor energetico
       '^FO20,235^A0N,14,16^FDValor energetico (kcal)^FS'                                  || CHR(13) || CHR(10) ||
       '^FO305,235^A0N,14,16^FD'||TO_CHAR(T.VE_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,235^A0N,14,16^FD'||TO_CHAR(T.VE_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO450,235^A0N,14,16^FD'||TO_CHAR(T.VE_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||

       -- LINHA Carboidratos
       '^FO20,256^A0N,14,16^FDCarboidratos (g)^FS'                                         || CHR(13) || CHR(10) ||
       '^FO305,256^A0N,14,16^FD'||TO_CHAR(T.C_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'  || CHR(13) || CHR(10) ||
       '^FO375,256^A0N,14,16^FD'||TO_CHAR(T.C_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO450,256^A0N,14,16^FD'||TO_CHAR(T.C_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||

       -- LINHA Acucares totais
       '^FO30,275^A0N,14,16^FDAcucares totais (g)^FS'                                      || CHR(13) || CHR(10) ||
       '^FO305,275^A0N,14,16^FD'||TO_CHAR(T.AT_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,275^A0N,14,16^FD'||TO_CHAR(T.AT_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,275^A0N,14,16^FD'||TO_CHAR(T.AT_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       -- LINHA Acucares adicionados
       '^FO40,296^A0N,14,16^FDAcucares adicionados (g)^FS'                                 || CHR(13) || CHR(10) ||
       '^FO305,296^A0N,14,16^FD'||TO_CHAR(T.AA_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,296^A0N,14,16^FD'||TO_CHAR(T.AA_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,296^A0N,14,16^FD'||TO_CHAR(T.AA_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       '^FO20,310^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- LINHA Proteinas
       '^FO20,315^A0N,14,16^FDProteinas (g)^FS'                                            || CHR(13) || CHR(10) ||
       '^FO305,315^A0N,14,16^FD'||TO_CHAR(T.P_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'  || CHR(13) || CHR(10) ||
       '^FO375,315^A0N,14,16^FD'||TO_CHAR(T.P_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO450,315^A0N,14,16^FD'||TO_CHAR(T.P_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||

       '^FO20,330^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- LINHA Gorduras totais
       '^FO20,335^A0N,14,16^FDGorduras totais (g)^FS'                                      || CHR(13) || CHR(10) ||
       '^FO305,335^A0N,14,16^FD'||TO_CHAR(T.GT_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,335^A0N,14,16^FD'||TO_CHAR(T.GT_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,335^A0N,14,16^FD'||TO_CHAR(T.GT_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       '^FO20,350^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- LINHA Gorduras saturadas
       '^FO30,355^A0N,14,16^FDGorduras saturadas (g)^FS'                                   || CHR(13) || CHR(10) ||
       '^FO305,355^A0N,14,16^FD'||TO_CHAR(T.GS_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,355^A0N,14,16^FD'||TO_CHAR(T.GS_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,355^A0N,14,16^FD'||TO_CHAR(T.GS_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       '^FO20,370^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- LINHA Gorduras trans
       '^FO30,376^A0N,14,16^FDGorduras trans (g)^FS'                                       || CHR(13) || CHR(10) ||
       '^FO305,376^A0N,14,16^FD'||TO_CHAR(T.GR_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,376^A0N,14,16^FD'||TO_CHAR(T.GR_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,376^A0N,14,16^FD'||TO_CHAR(T.GR_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       -- LINHA Fibras alimentares
       '^FO20,396^A0N,14,16^FDFibras alimentares (g)^FS'                                   || CHR(13) || CHR(10) ||
       '^FO305,396^A0N,14,16^FD'||TO_CHAR(T.FA_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,396^A0N,14,16^FD'||TO_CHAR(T.FA_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,396^A0N,14,16^FD'||TO_CHAR(T.FA_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       -- LINHA Sodio
       '^FO20,415^A0N,14,16^FDSodio (g)^FS'                                                || CHR(13) || CHR(10) ||
       '^FO305,415^A0N,14,16^FD'||TO_CHAR(T.SO_100G, 'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS' || CHR(13) || CHR(10) ||
       '^FO375,415^A0N,14,16^FD'||TO_CHAR(T.SO_PORCAO,'FM999990D0','NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||
       '^FO450,415^A0N,14,16^FD'||TO_CHAR(T.SO_VD,    'FM999990'  ,'NLS_NUMERIC_CHARACTERS='',.''')||'^FS'|| CHR(13) || CHR(10) ||

       '^FO20,390^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||
       '^FO20,410^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||
       '^FO20,430^GB476,1,1^FS'                                                            || CHR(13) || CHR(10) ||

       -- RODAPE NUTRICIONAL
       '^FO20,437^A0N,13,16^FB480,2,0,L^FD*Percentual de valores diarios fornecidos pela porcao.^FS' || CHR(13) || CHR(10) ||
       '^FO26,460^A0N,13,16^FB480,2,0,L^FDAntes do consumo, higienize adequadamente o produto.^FS'    || CHR(13) || CHR(10) ||

       -- CODIGO DE BARRAS
       '^FO80,478'                                                                         || CHR(13) || CHR(10) ||
       '^BY2,2,30'                                                                         || CHR(13) || CHR(10) ||
       '^BCN,30,Y,N,N'                                                                     || CHR(13) || CHR(10) ||
       '^FD'||( select   MAX(a.codacesso) codacesso
         from    consinco.map_prodcodigo a
         where   a.tipcodigo = 'E'
				 and      a.qtdembalagem = 1
         and     a.seqproduto = p.SEQPRODUTO)||'^FS'                                       || CHR(13) || CHR(10) ||

       '^XZ'  LINHA

  FROM MAP_PRODUTO P INNER JOIN MAP_FAMEMBALAGEM   E ON E.SEQFAMILIA = P.SEQFAMILIA
                     INNER JOIN MRLX_BASEETIQUETAPROD A ON A.SEQPRODUTO = P.SEQPRODUTO
                      LEFT JOIN MAP_INFNUTRICFAM   N ON N.SEQFAMILIA = P.SEQFAMILIA
                      LEFT JOIN NAGV_INFNUTRIC_PIVOT_v4 T ON TO_NUMBER(T.SEQINFNUTRIC) = TO_NUMBER(N.SEQINFNUTRIC)
                      
 WHERE E.QTDEMBALAGEM = 1
;

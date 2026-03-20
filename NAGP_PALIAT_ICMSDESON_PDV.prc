CREATE OR REPLACE PROCEDURE NAGP_PALIAT_ICMSDESON_PDV AS

  pdCGO VARCHAR2(4000);

BEGIN

  -- Correcao paliativa, pois o correto seria corrigir na trigger/insercao 
  -- Corrige o CST que deve estar incorreto (000 para 040)

  -- Busca o parâmetro dinâmico listando os CGOs
  SP_BUSCAPARAMDINAMICO('NAGUMO',
                        0,
                        'PDV_CGO_CORRIGE_DESON',
                        'S',
                        NULL,
                        'Lista de CGOs que corrige a operação de emissão de desonerado à Orgao Publico pelo PDV',
                        pdCGO);

  FOR nf IN (SELECT SEQNF, F.SEQNOTAFISCAL
               FROM MFL_DOCTOFISCAL F
              WHERE F.DTAMOVIMENTO >= TRUNC(SYSDATE)
                AND F.STATUSNFE = 5 -- Busca as rejeitadas
                AND F.CODGERALOPER IN
                    (SELECT COLUMN_VALUE
                       FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdCGO),
                                                                  0)) AS
                                       C5INSTRTABLE))))
   LOOP
  
    UPDATE MFL_DFITEM XI
       SET XI.SITUACAONF = '040' -- CST Correto
     WHERE XI.SEQNF = nf.SEQNF
       AND NVL(VLRDESCICMS, 0) > 0        -- Somente o que possui desc de icms calculado
       AND NVL(INDMOTIVODESOICMS, 0) = 8  -- Somente Orgao Publico
       AND XI.SITUACAONF = '000';         -- CST Errado
  
    COMMIT;
  
    IF SQL%ROWCOUNT > 0 THEN              -- Se deu update, reenvia
      SP_EXPORTANFE(nf.SEQNOTAFISCAL, 'E');
      COMMIT;
    END IF;
  
  END LOOP;

END;


/* Old
BEGIN
  FOR nf IN (SELECT SEQNF, F.SEQNOTAFISCAL FROM MFL_DOCTOFISCAL F WHERE F.DTAMOVIMENTO >= TRUNC(SYSDATE) AND F.STATUSNFE = 5 AND CODGERALOPER = 37)
    LOOP
      -- Corrige o CST que deve estar incorreto (000 para 040)

    UPDATE MFL_DFITEM XI
       SET XI.SITUACAONF = '040'
     WHERE XI.SEQNF = nf.SEQNF
       AND NVL(VLRDESCICMS,0) > 0
       AND NVL(INDMOTIVODESOICMS, 0) = 8
       AND XI.SITUACAONF = '000';
    
    COMMIT;
    
    IF sql%rowcount > 0 THEN
    
    SP_EXPORTANFE(nf.SEQNOTAFISCAL, 'E');
    COMMIT;
    
    END IF;
    
    END LOOP;
    
END;*/

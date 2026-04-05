CREATE OR REPLACE PROCEDURE NAGP_ALTFAM_PISCOFINS (psAliquota NUMBER, psAjuste VARCHAR2 DEFAULT 'A') AS

-- Giuliano 27/03/2026
-- Alt seguindo a orientacao do TDN https://tdn.totvs.com/pages/releaseview.action?pageId=1051259022

  psVlrDespOp NUMBER(10,2);
  i INTEGER := 0;
  vListaTributacao VARCHAR2(4000);

BEGIN
   
  /*FOR t IN (SELECT DISTINCT A.SEQFAMILIA FROM NAGT_BASE_ALT_PISCOFINS10 A \* << Tabela com os SeqFamilias a serem alterados *\ INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = A.SEQFAMILIA
              WHERE F.PERDESPESADIVISAO IS NULL*/
              
   SP_BUSCAPARAMDINAMICO('NAGUMO',0,'OBS_INFOADFISCO_TRIB','S', NULL,
                          'Lista de Tributacoes que emitem obs na tag InfoAdFisco (Operacao esta sujeita ao disposto na Lei Complementar n 224 de 2025)', vListaTributacao);
   -- Insere 
            
   FOR t IN (SELECT SEQFAMILIA FROM MAP_FAMDIVISAO C 
              WHERE C.NROTRIBUTACAO  IN (
                                        SELECT REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL)
                                          FROM DUAL
                                        CONNECT BY REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL) IS NOT NULL)
               AND NVL(C.PERDESPESADIVISAO,0) != psAliquota
            ) 
   LOOP
    i := i+1;
     UPDATE MAP_FAMDIVISAO F SET F.PERDESPESADIVISAO = NVL(F.PERDESPESADIVISAO,0) + (psAliquota * CASE WHEN psAjuste = 'A' THEN 1 ELSE -1 END), -- Outro valor no psAjuste estorna o lancamento
                                 F.USUARIOALTERACAO  = 'PISCOFINS',
                                 F.DTAHORALTERACAO   = SYSDATE
                     WHERE F.SEQFAMILIA = T.SEQFAMILIA
                       AND (psAjuste = 'A'
                        OR (psAjuste != 'A' AND NVL(F.PERDESPESADIVISAO,0) >= psAliquota));
    
    IF i  = 100 THEN COMMIT;
       i := 0;
        
    END IF;
    COMMIT;
    END LOOP;
    
    -- Exclui
    
    FOR t IN (SELECT SEQFAMILIA FROM MAP_FAMDIVISAO C 
              WHERE NOT C.NROTRIBUTACAO  IN (
                                        SELECT REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL)
                                          FROM DUAL
                                        CONNECT BY REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL) IS NOT NULL)
                AND C.PERDESPESADIVISAO > 0
            ) 
   LOOP
    i := i+1;
     UPDATE MAP_FAMDIVISAO F SET F.PERDESPESADIVISAO = 0,
                                 F.USUARIOALTERACAO  = 'PISCOFINS',
                                 F.DTAHORALTERACAO   = SYSDATE
                     WHERE F.SEQFAMILIA = T.SEQFAMILIA
                       AND psAjuste = 'A';
    
    IF i  = 100 THEN COMMIT;
       i := 0;
        
    END IF;
    COMMIT;
   END LOOP;
    
END;

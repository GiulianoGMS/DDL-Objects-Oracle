CREATE OR REPLACE PROCEDURE NAGP_ALTFAM_PISCOFINS (psAliquota NUMBER, psAjuste VARCHAR2 DEFAULT 'A') AS

-- Giuliano 27/03/2026
-- Alt seguindo a orientacao do TDN https://tdn.totvs.com/pages/releaseview.action?pageId=1051259022

  psVlrDespOp NUMBER(10,2);
  i INTEGER := 0;
  vListaTributacao VARCHAR2(4000);

BEGIN
              
   SP_BUSCAPARAMDINAMICO('NAGUMO',0,'OBS_INFOADFISCO_TRIB','S', NULL,
                          'Lista de Tributacoes que emitem obs na tag InfoAdFisco (Operacao esta sujeita ao disposto na Lei Complementar n 224 de 2025)', vListaTributacao);
   -- Insere ERP
            
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
    
    -- Insere PDV
    
    UPDATE MONITORPDV.TB_FAMILIA a
       SET a.PREENCHERINFADFISCO = 'S'
     WHERE NVL(a.PREENCHERINFADFISCO, 'N') <> 'S'
       AND A.SEQFAMILIA = t.SEQFAMILIA
       AND psAjuste = 'A';
    
    IF i  = 100 THEN COMMIT;
       i := 0;
        
    END IF;
    COMMIT;
    END LOOP;
    
    -- Inativa ERP
    
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
    
    -- Inativa PDV
        
    UPDATE MONITORPDV.TB_FAMILIA a
       SET a.PREENCHERINFADFISCO = 'N'
     WHERE NVL(a.PREENCHERINFADFISCO, 'N') <> 'N'
       AND A.SEQFAMILIA = t.SEQFAMILIA
       AND psAjuste = 'A';
    
    IF i  = 100 THEN COMMIT;
       i := 0;
        
    END IF;
    COMMIT;
   END LOOP;
    
END;

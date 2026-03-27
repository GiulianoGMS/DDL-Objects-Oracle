CREATE OR REPLACE PROCEDURE NAGP_ALTFAM_PISCOFINS (psAliquota NUMBER) AS

-- Giuliano 27/03/2026
-- Alt seguindo a orientacao do TDN https://tdn.totvs.com/pages/releaseview.action?pageId=1051259022
-- Somar PIS + COFINS e passar na variavel (0,165 + 0,760 = 0,925)
-- O campo aceita 2 decimais, ira tranformar 0,925 em 0,93

  i INTEGER := 0;

BEGIN
  FOR t IN (SELECT A.SEQFAMILIA FROM NAGT_PRODST_ABRIL A /* << Tabela com os SeqFamilias a serem alterados */ INNER JOIN MAP_FAMDIVISAO F ON F.SEQFAMILIA = A.SEQFAMILIA) 
    LOOP
    i := i+1;
     UPDATE MAP_FAMDIVISAO F SET F.PERDESPESADIVISAO = NVL(F.PERDESPESADIVISAO,0) + psAliquota,
                                 F.USUARIOALTERACAO  = 'PISCOFINS',
                                 F.DTAHORALTERACAO   = SYSDATE
                     WHERE F.SEQFAMILIA = T.SEQFAMILIA; 
    
    IF i  = 100 THEN COMMIT;
       i := 0;
        
    END IF;
    COMMIT;
    END LOOP;
    
END;

-- Adicionar em ORP_INSCONSISTENCIACUST

-- Consiste Data de Vencimento MENOR que data de lancamento
     -- Ticket 649982 -- Add Giuliano 18/03/26
     
   FOR a IN (SELECT *
               FROM OR_NFDESPESA N
              WHERE N.NROEMPRESA = vnEmpresa
                AND N.SEQNOTA = pnSeqnota
                AND EXISTS (SELECT 1 FROM OR_NFVENCIMENTO C WHERE C.SEQNOTA = N.SEQNOTA AND C.DTAVENCTO < N.DTAENTRADA))
   LOOP 
   
       INSERT INTO ORX_NFDESPESAINCOSISTCUST (SEQINCONSIST, MOTIVO, SITUACAO)
   VALUES
       (808,
        'Existe data de vencimento retroativa à data de lançamento da nota. Verifique!',
        'P');
   pnOk := 1;
   
   END LOOP;

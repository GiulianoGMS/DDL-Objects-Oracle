CREATE OR REPLACE FUNCTION NAGF_BUSCA_CST_IPI_FAM(
               psSeqFamilia     IN   map_familia.seqfamilia%TYPE)
               RETURN VARCHAR2
IS
  psCGOIPI   VARCHAR2(10);
  
BEGIN
     -- Verifica qual é o CST de IPI na família
     
         SELECT MAX(A.SITUACAONFIPISAI)
          INTO psCGOIPI
          FROM MAP_FAMILIA A
         WHERE A.SEQFAMILIA = psSeqFamilia;
         
RETURN psCGOIPI;
END NAGF_BUSCA_CST_IPI_FAM;

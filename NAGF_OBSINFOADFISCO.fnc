CREATE OR REPLACE FUNCTION NAGF_OBSINFOADFISCO (
    psSeqNF MLF_NOTAFISCAL.SEQNF%TYPE,
    psCGO NUMBER
) RETURN VARCHAR2 IS

 -- Adicionar a function na SP_EXPNFE_2g
-- Linha 772
-- END -- Alt Giuliano LC 224/2025
--              || NAGF_OBSINFOADFISCO(A.SEQNF, A.codgeraloper)
--              as M000_DS_INFO_FISCO,

    vListaTributacao VARCHAR2(4000);
    vListaCGO        VARCHAR2(4000);
    vExiste          NUMBER;
    pdDtaFixa        VARCHAR2(100);

BEGIN

    -- Busca parâmetro (lista de tributações separadas por vírgula)
    SP_BUSCAPARAMDINAMICO('NAGUMO',0,'OBS_INFOADFISCO_TRIB','S', NULL,
                          'Lista de Tributacoes que emitem obs na tag InfoAdFisco (Operacao esta sujeita ao disposto na Lei Complementar n 224 de 2025)', vListaTributacao);
    SP_BUSCAPARAMDINAMICO('NAGUMO',0,'OBS_INFOADFISCO_CGO','S', NULL,
                          'Lista de COGs de exclusao da regra da tag InfoAdFisco (Operacao esta sujeita ao disposto na Lei Complementar n 224 de 2025)', vListaCGO);
     SP_BUSCAPARAMDINAMICO('NAGUMO',0,'OBS_INFOADFISCO_DATA','S', NULL,
                          'Data limite para emissao da tag InfoAdFisco LC 2242025', pdDtaFixa);
                          
    IF TRUNC(SYSDATE) <= TO_DATE(pdDtaFixa, 'DD/MM/YYYY') THEN
    -- Verifica se existe pelo menos 1 item com tributação da lista
    SELECT COUNT(1)
      INTO vExiste
      FROM MFLV_BASEDFITEM C
     WHERE C.SEQNF = psSeqNF
     
       AND C.codtributacao IN (
            SELECT REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL)
              FROM DUAL
            CONNECT BY REGEXP_SUBSTR(vListaTributacao, '[^,]+', 1, LEVEL) IS NOT NULL)
            
       AND psCGO NOT IN (
            SELECT REGEXP_SUBSTR(vListaCGO, '[^,]+', 1, LEVEL)
              FROM DUAL
            CONNECT BY REGEXP_SUBSTR(vListaCGO, '[^,]+', 1, LEVEL) IS NOT NULL)
       
       AND ROWNUM = 1;

    IF vExiste > 0 THEN
    -- Se entrou aqui, encontrou
    RETURN 'Operacao esta sujeita ao disposto na Lei Complementar n 224 de 2025';
    ELSE
     RETURN NULL;
    END IF;
    
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
        RETURN NULL;
END;

CREATE OR REPLACE PROCEDURE NAGP_ATU_FAM_DADOS_FISCAIS_v2 (vSeqFamilia     MAP_FAMILIA.SEQFAMILIA%TYPE,
                                                           vAliqIPI        MAP_FAMILIA.ALIQUOTAIPI%TYPE,
                                                           vCSTIPI_Entrada MAP_FAMILIA.SITUACAONFIPI%TYPE,
                                                           vCSTIPI_Saida   MAP_FAMILIA.SITUACAONFIPISAI%TYPE,
                                                           vCodNatReceita  MAP_FAMILIA.FAMILIA%TYPE,
                                                           vCalcIPISaida   VARCHAR2,
                                                           vAliqII         MAP_FAMILIA.PERIMPOSTOIMPORT%TYPE
                                                           )

 IS vSQL       VARCHAR2(4000);
    vSetClause VARCHAR2(4000);
    vSeqRec    VARCHAR2(4000);

BEGIN
    vSetClause := 'ALIQUOTAIPI = NVL(' || vAliqIPI || ', 0)';

    -- Para vCSTIPI_Entrada: Se for 0, deve ser substituído por NULL
    IF vCSTIPI_Entrada = '0' THEN
        vSetClause := vSetClause || ', SITUACAONFIPI = NULL';
    ELSIF vCSTIPI_Entrada IS NOT NULL THEN
        vSetClause := vSetClause || ', SITUACAONFIPI = ''' || LPAD(vCSTIPI_Entrada, 2, '0') || '''';
    END IF;

    -- Para vCSTIPI_Saida: Se for 0, deve ser substituído por NULL
    IF vCSTIPI_Saida = '0' THEN
        vSetClause := vSetClause || ', SITUACAONFIPISAI = NULL';
    ELSIF vCSTIPI_Saida IS NOT NULL THEN
        vSetClause := vSetClause || ', SITUACAONFIPISAI = ''' || LPAD(vCSTIPI_Saida, 2, '0') || '''';
    END IF;

    -- Para vCodNatReceita: Se for 0, deve ser substituído por NULL
    IF vCodNatReceita = '0' THEN
        vSetClause := vSetClause || ', CODNATREC = NULL, SEQNATREC = NULL';
    ELSIF vCodNatReceita IS NOT NULL
      THEN
        SELECT NAGF_BUSCASEQREC(vCodNatReceita) INTO vSeqRec FROM DUAL;
        
        IF vSeqRec IS NOT NULL THEN
        vSetClause := vSetClause || ', CODNATREC = ' || vCodNatReceita;
        vSetClause := vSetClause || ', SEQNATREC = ' || vSeqRec;
        END IF;
    END IF;
    
    -- Para vAliqII
    IF vAliqII = '0' THEN
        vSetClause := vSetClause || ', PERIMPOSTOIMPORT = NULL';
    ELSIF vAliqII IS NOT NULL THEN
        vSetClause := vSetClause || ', PERIMPOSTOIMPORT = ''' || vAliqII || '''';
    END IF;
    
    -- Para vCalcIPISaida
    IF vCalcIPISaida = '0' THEN
        vSetClause := vSetClause || ', INDCALCIPISAIDA = NULL';
    ELSIF vCalcIPISaida = 'S' THEN
        vSetClause := vSetClause || ', INDCALCIPISAIDA = ''' || vCalcIPISaida || '''';
        vSetClause := vSetClause || ', PERALIQUOTAIPI = '''  || vAliqIPI || '''';
        vSetClause := vSetClause || ', PERBASEIPI = '''  || 100  || '''';
        vSetClause := vSetClause || ', PERISENTOIPI = '''|| 0  || '''';
        vSetClause := vSetClause || ', PEROUTROIPI = ''' || 0  || '''';
    END IF;

    vSQL := 'UPDATE MAP_FAMILIA SET ' || vSetClause || ' WHERE SEQFAMILIA = ' || vSeqFamilia;

    EXECUTE IMMEDIATE vSQL;
   -- COMMIT;
END;

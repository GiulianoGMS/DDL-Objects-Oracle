CREATE OR REPLACE TRIGGER NAGTRG_BI_MAC_GERCOMPRAITEM_CALCESP
FOR INSERT ON MAC_GERCOMPRAITEM
COMPOUND TRIGGER

  -- Precisa ser compound (mesmo so atuando no AFTER STATEMENT) porque
  -- :NEW.SEQGERCOMPRA so existe em contexto de linha (AFTER EACH ROW).
  -- Todas as linhas de um mesmo INSERT pertencem a mesma compra, entao
  -- basta capturar o valor uma vez por linha (sobrescrever e barato).
  v_seqgercompra MAC_GERCOMPRAITEM.SEQGERCOMPRA%TYPE;

--------------------------------------------------------------------------
-- CAPTURA A COMPRA (mesmo SEQGERCOMPRA em todas as linhas do INSERT)
--------------------------------------------------------------------------
AFTER EACH ROW IS
BEGIN
    v_seqgercompra := :NEW.SEQGERCOMPRA;
END AFTER EACH ROW;

--------------------------------------------------------------------------
-- DISPARA O CALCULO ESPECIAL (TIPOCALCESP 'AL' OU 'AP'), SE CONFIGURADO
--------------------------------------------------------------------------
AFTER STATEMENT IS
    psSeqFornec    MAF_FORNECEDOR.SEQFORNECEDOR%TYPE;
    psSeqComprador MAX_COMPRADOR.SEQCOMPRADOR%TYPE;
    --psOrigem       NUMBER(13);
    psFormaCalcEsp VARCHAR2(10);
BEGIN
    ------------------------------------------------------------------
    -- FORNECEDOR DA COMPRA
    ------------------------------------------------------------------
    SELECT MAX(F.SEQFORNECEDOR)
      INTO psSeqFornec
      FROM MAC_GERCOMPRAFORN F
     WHERE F.SEQGERCOMPRA = v_seqgercompra;

    ------------------------------------------------------------------
    -- COMPRADOR DA COMPRA CONSOLIDADA
    ------------------------------------------------------------------
    SELECT MAX(C.SEQCOMPRADOR)--, MAX(C.SEQGERCOMPORIGEM)
      INTO psSeqComprador--, psOrigem
      FROM MAC_GERCOMPRA C
     WHERE C.SEQGERCOMPRA = v_seqgercompra
       AND C.TIPOLOTE = 'C'
       AND C.SEQGERCOMPORIGEM IS NULL;

    ------------------------------------------------------------------
    -- DESCOBRE SE USA FORMULA DE CALCULO ESPECIAL
    ------------------------------------------------------------------
    SELECT MAX(X.TIPOCALCESP)
      INTO psFormaCalcEsp
      FROM NAGT_COMP_FORN_SUGESTAUTO X
     WHERE X.SEQCOMPRADOR = psSeqComprador
       AND psSeqFornec = NVL(X.SEQFORNECEDOR, psSeqFornec)
       AND X.TIPOCALCESP IS NOT NULL;

    IF psFormaCalcEsp IN ('AL', 'AP', 'AC') THEN
        NAGPKG_SUGESTAO_COMPRA.NAGP_ATUALIZA_SUGESTAO(psSeqGerCompra => v_seqgercompra,
                                                       psTipoAt       => psFormaCalcEsp,
                                                       psIndCommit    => 'N');
    END IF;
END AFTER STATEMENT;

END;

CREATE OR REPLACE TRIGGER NAGTRG_BI_MAC_GERCOMPRAITEM_CDARRED
FOR INSERT ON MAC_GERCOMPRAITEM
COMPOUND TRIGGER

    TYPE t_item IS RECORD (
        seqgercompra MAC_GERCOMPRAITEM.SEQGERCOMPRA%TYPE,
        seqproduto   MAC_GERCOMPRAITEM.SEQPRODUTO%TYPE,
        nroempresa   MAC_GERCOMPRAITEM.NROEMPRESA%TYPE,
        perc_arred   NUMBER,
        ind_arred    VARCHAR2(1)
    );

    TYPE t_itens IS TABLE OF t_item INDEX BY PLS_INTEGER;

    v_itens t_itens;
    v_count NUMBER := 0;

    -------------------------------------------------------------------------
    -- CAPTURA OS ITENS INSERIDOS
    --------------------------------------------------------------------------
    AFTER EACH ROW IS

        psSeqFornec       MAF_FORNECEDOR.SEQFORNECEDOR%TYPE;
        psSeqComprador    MAX_COMPRADOR.SEQCOMPRADOR%TYPE;
        psIndAcataSug     NUMBER(10);

        v_cd_consolidacao NUMBER;
        v_perc_arred      NUMBER;
        v_ind_arred       VARCHAR2(1);

    BEGIN

        ----------------------------------------------------------------------
        -- FORNECEDOR DA COMPRA
        ----------------------------------------------------------------------
        SELECT MAX(F.SEQFORNECEDOR)
          INTO psSeqFornec
          FROM MAC_GERCOMPRAFORN F
         WHERE F.SEQGERCOMPRA = :NEW.SEQGERCOMPRA;

        ----------------------------------------------------------------------
        -- COMPRADOR DA COMPRA CONSOLIDADA
        ----------------------------------------------------------------------
        SELECT MAX(C.SEQCOMPRADOR)
          INTO psSeqComprador
          FROM MAC_GERCOMPRA C
         WHERE C.SEQGERCOMPRA = :NEW.SEQGERCOMPRA
           AND C.TIPOLOTE = 'C';

        ----------------------------------------------------------------------
        -- VERIFICA SE EXISTE CONFIGURAÇÃO PARA
        -- FORNECEDOR / COMPRADOR
        ----------------------------------------------------------------------
        IF psSeqComprador IS NOT NULL THEN

            SELECT COUNT(1),
                   MAX(X.CD_AGRUP),
                   MAX(X.PERC_ARRED),
                   MAX(X.IND_ARRED)
              INTO psIndAcataSug,
                   v_cd_consolidacao,
                   v_perc_arred,
                   v_ind_arred
              FROM NAGT_COMP_FORN_SUGESTAUTO X
             WHERE X.SEQCOMPRADOR = psSeqComprador
               AND psSeqFornec = NVL(X.SEQFORNECEDOR, psSeqFornec);

            ------------------------------------------------------------------
            -- SOMENTE A EMPRESA DE CONSOLIDAÇÃO
            -- E SOMENTE SE EXISTIR CONFIGURAÇÃO
            ------------------------------------------------------------------
            IF psIndAcataSug > 0
               AND v_cd_consolidacao = :NEW.NROEMPRESA
            THEN

                v_count := v_count + 1;

                v_itens(v_count).seqgercompra := :NEW.SEQGERCOMPRA;
                v_itens(v_count).seqproduto   := :NEW.SEQPRODUTO;
                v_itens(v_count).nroempresa   := :NEW.NROEMPRESA;
                v_itens(v_count).perc_arred   := v_perc_arred;
                v_itens(v_count).ind_arred    := v_ind_arred;

            END IF;

        END IF;

    END AFTER EACH ROW;

    --------------------------------------------------------------------------
    -- PROCESSAMENTO APÓS O INSERT
    --------------------------------------------------------------------------
    AFTER STATEMENT IS

        v_total          NUMBER;
        v_total_calc     NUMBER;
        v_palete         NUMBER;
        v_lastro         NUMBER;
        v_qtdeembalagem  NUMBER;
        v_resto          NUMBER;

    BEGIN

        ----------------------------------------------------------------------
        -- PROCESSA OS ITENS QUE FORAM IDENTIFICADOS
        ----------------------------------------------------------------------
        FOR i IN 1 .. v_count LOOP

            ------------------------------------------------------------------
            -- SOMA A QUANTIDADE SUGERIDA DAS LOJAS
            ------------------------------------------------------------------
            SELECT NVL(SUM(XI.QTDSUGERIDAFORNEC), 0)
              INTO v_total
              FROM MAC_GERCOMPRAITEM XI
             WHERE XI.SEQGERCOMPRA = v_itens(i).seqgercompra
               AND XI.SEQPRODUTO   = v_itens(i).seqproduto
               AND XI.NROEMPRESA  <> v_itens(i).nroempresa;

            ------------------------------------------------------------------
            -- DADOS DE LASTRO E PALETE
            ------------------------------------------------------------------
            SELECT MAX(M.PALETELASTRO),
                   MAX(M.PALETELASTRO * M.PALETEALTURA)
              INTO v_lastro,
                   v_palete
              FROM MRL_PRODEMPRESAWM M
             WHERE M.NROEMPRESA = v_itens(i).nroempresa
               AND M.SEQPRODUTO = v_itens(i).seqproduto;


            ------------------------------------------------------------------
            -- QUANTIDADE DE EMBALAGEM
            ------------------------------------------------------------------
            SELECT MAX(I.QTDEMBALAGEM)
              INTO v_qtdeembalagem
              FROM MAC_GERCOMPRAITEM I
             WHERE I.SEQGERCOMPRA = v_itens(i).seqgercompra
               AND I.SEQPRODUTO   = v_itens(i).seqproduto
               AND I.NROEMPRESA   = v_itens(i).nroempresa;


            ------------------------------------------------------------------
            -- SE IND_ARRED = 'S' E O PERCENTUAL GERAL ESTIVER NULL,
            -- BUSCA O PERCENTUAL ESPECÍFICO DO PRODUTO
            ------------------------------------------------------------------
            IF v_itens(i).ind_arred = 'S'
               AND v_itens(i).perc_arred IS NULL
            THEN

                SELECT MAX(P.PERCVARIACAOSUG)
                  INTO v_itens(i).perc_arred
                  FROM MRL_PRODUTOEMPRESA P
                 WHERE P.NROEMPRESA = v_itens(i).nroempresa
                   AND P.SEQPRODUTO = v_itens(i).seqproduto;

            END IF;

            ------------------------------------------------------------------
            -- POR PADRÃO, MANTÉM O VALOR ORIGINAL
            ------------------------------------------------------------------
            v_total_calc := v_total;

            ------------------------------------------------------------------
            -- ARREDONDAMENTO
            --
            -- SOMENTE ACONTECE SE:
            -- IND_ARRED = 'S'
            -- E EXISTIR PERCENTUAL
            ------------------------------------------------------------------
            IF v_itens(i).ind_arred = 'S'
               AND v_itens(i).perc_arred IS NOT NULL
               AND v_qtdeembalagem > 0
               AND v_palete > 0
            THEN

                --------------------------------------------------------------
                -- CONVERTE PARA QUANTIDADE DE EMBALAGENS
                --------------------------------------------------------------
                v_total_calc := v_total / v_qtdeembalagem;
                --------------------------------------------------------------
                -- CALCULA O RESTANTE DO ÚLTIMO PALETE
                --------------------------------------------------------------
                v_resto :=
                      v_total_calc
                    - FLOOR(v_total_calc / v_palete) * v_palete;
                --------------------------------------------------------------
                -- ATINGIU O PERCENTUAL DO PALETE?
                --
                -- SIM:
                -- COMPLETA MAIS UM PALETE
                --------------------------------------------------------------
                IF (v_resto / v_palete) * 100 >= v_itens(i).perc_arred
                THEN

                    v_total_calc :=
                          FLOOR(v_total_calc / v_palete) * v_palete
                        + v_palete;
                --------------------------------------------------------------
                -- NÃO:
                -- ARREDONDA PARA CIMA NO ÚLTIMO LASTRO
                --------------------------------------------------------------
               ELSIF v_lastro > 0
                 AND (
                       (
                         v_total_calc
                         - FLOOR(v_total_calc / v_lastro) * v_lastro
                       ) / v_lastro
                     ) * 100 >= v_itens(i).perc_arred
                THEN

                  v_total_calc :=
                      CEIL(v_total_calc / v_lastro) * v_lastro;

               END IF;
                --------------------------------------------------------------
                -- VOLTA PARA A UNIDADE ORIGINAL
                --------------------------------------------------------------
                v_total_calc :=
                    v_total_calc * v_qtdeembalagem;
            END IF;
            ------------------------------------------------------------------
            -- ATUALIZA QTDPEDIDA DA CONSOLIDAÇÃO
            ------------------------------------------------------------------
            UPDATE MAC_GERCOMPRAITEM
               SET QTDPEDIDA = v_total_calc
             WHERE SEQGERCOMPRA = v_itens(i).seqgercompra
               AND SEQPRODUTO   = v_itens(i).seqproduto
               AND NROEMPRESA   = v_itens(i).nroempresa;

        END LOOP;

    END AFTER STATEMENT;

END;

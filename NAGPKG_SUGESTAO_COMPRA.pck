CREATE OR REPLACE PACKAGE NAGPKG_SUGESTAO_COMPRA AS

  FUNCTION NAGF_CALC_SUGEST_COMPRA (
    pdSeqFornecedor IN MAF_FORNECEDOR.SEQFORNECEDOR%TYPE,
    pdNroEmpresa    IN MAX_EMPRESA.NROEMPRESA%TYPE,
    pdSeqProduto    IN MAP_PRODUTO.SEQPRODUTO%TYPE,
    pdPeriodoCalc   IN MAC_GERCOMPRA.QTDMEDVDA%TYPE,
    pdSeqGerCompra  IN MAC_GERCOMPRA.SEQGERCOMPRA%TYPE,
    pdIndTipoMedVda IN MAC_GERCOMPRA.INDTIPOMEDVDA%TYPE,
    pdTipoRetorno   IN VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE NAGP_ATUALIZA_SUGESTAO (
    psSeqGerCompra IN NUMBER,
    psTipoAt       IN VARCHAR2,
    psIndCommit    IN VARCHAR2
  );
  
  PROCEDURE NAGP_RATEIA_ACRESC_SUGEST (psSeqGerCompra IN NUMBER,
                                                       psSeqProduto   IN NUMBER,
                                                       psQtdEmb       IN NUMBER,
                                                       psQtdUnidade   IN NUMBER,
                                                       pdIndTipoMedVda IN VARCHAR2,
                                                       psIndCommit     IN VARCHAR2,
                                                       psQtdSobraReduz IN NUMBER DEFAULT NULL
                                       );
  PROCEDURE NAGP_CONTROLE_SL_CD(psSeqGerCompra NUMBER);

END NAGPKG_SUGESTAO_COMPRA;

/

CREATE OR REPLACE PACKAGE BODY NAGPKG_SUGESTAO_COMPRA AS

FUNCTION NAGF_CALC_SUGEST_COMPRA (pdSeqFornecedor IN MAF_FORNECEDOR.SEQFORNECEDOR%TYPE,
                                                    pdNroEmpresa    IN MAX_EMPRESA.NROEMPRESA%TYPE,
                                                    pdSeqProduto    IN MAP_PRODUTO.SEQPRODUTO%TYPE,
                                                    pdPeriodoCalc   IN MAC_GERCOMPRA.QTDMEDVDA%TYPE,
                                                    pdSeqGerCompra  IN MAC_GERCOMPRA.SEQGERCOMPRA%TYPE,
                                                    pdIndTipoMedVda IN MAC_GERCOMPRA.INDTIPOMEDVDA%TYPE,
                                                    pdTipoRetorno   IN VARCHAR2)
                                                    
   RETURN NUMBER IS
 
      vsSugestaoFinal NUMBER(10);
      pcEstoque       MRL_PRODUTOEMPRESA.ESTQLOJA%TYPE;
      pcMediaVendaFim NUMBER(10);
      pcEstqmin       MRL_PRODUTOEMPRESA.ESTQMINIMODV%TYPE;
      pcEstqmax       MRL_PRODUTOEMPRESA.ESTQMAXIMODV%TYPE;
      pcPrevEstq      NUMBER(10);
      pcPrevOrig      NUMBER(10);
      pcPrevLim       NUMBER(10);
      pcPrevExtraLim  NUMBER(10);
      pdTipoEmp       VARCHAR2(10);
      pdDiasAtraso    MAF_FORNECDIVISAO.PZOMEDATRASO%TYPE;
      pdConsEmpAbast  VARCHAR(1);
      pdReturn        NUMBER(10);
      
   BEGIN
         
   -- Pega os dias de atraso para utilizar na formula
         
      SELECT MAX(F.PZOMEDATRASO)
        INTO pdDiasAtraso
        FROM MAF_FORNECDIVISAO F
       WHERE SEQFORNECEDOR = pdSeqFornecedor;
       
   -- Valida se a empresa que esta entrando na variavel é LOJA ou CD para utilizar na formula
   
      SELECT TIPO 
        INTO pdTipoEmp
        FROM DWNAGT_DADOSEMPRESA E
       WHERE E.NROEMPRESA = pdNroEmpresa;
       
   -- Valida se considera estoque da empresa abatecedora no calculo
      
      SELECT NVL(INDCONSESTOQUECENTRALSUG, 'N')
        INTO pdConsEmpAbast
        FROM MAC_GERCOMPRA GER
       WHERE GER.SEQGERCOMPRA = pdSeqGerCompra;
        
   -- Formula do Calculo para Sugestao
   -- Se a empresa for CD, calcula o excedente do limite (Parametrizado em estoque max odv)
   
    pcEstoque         := 0;
    pcMediaVendaFim   := 0;
    pcEstqmin         := 0;
    pcEstqmax         := 0;
    pcPrevEstq        := 0;
    pcPrevOrig        := 0;
    pcPrevLim         := 0;
    pcPrevExtraLim    := 0;

    FOR emp IN ( SELECT NROEMPRESA FROM DWNAGT_DADOSEMPRESA X WHERE (X.NROEMPRESA = pdNroEmpresa AND pdTipoEmp = 'LOJA')
                                                                 OR (X.TIPO = 'LOJA' AND pdTipoEmp = 'CD')
               )
    LOOP
      
      DECLARE
        vEstoque        NUMBER := 0;
        vMediaVendaFim  NUMBER := 0;
        vEstqmin        NUMBER := 0;
        vEstqmax        NUMBER := 0;
        vPrevEstq       NUMBER := 0;
        vPrevOrig       NUMBER := 0;
        vPrevLim        NUMBER := 0;
        vPrevExtraLim   NUMBER := 0;
        
      BEGIN
        SELECT NVL(ESTQ,0), NVL(MED_PREV_VDA_FIM,0), NVL(ESTQMIN,0), NVL(ESTQMAX,0), NVL(PREV_ESTQ,0),
               NVL((ESTQMIN - PREV_ESTQ),0) PREV_ORIGINAL,
               NVL(CASE WHEN ESTQMAX > (ESTQMIN - PREV_ESTQ) THEN (ESTQMIN - PREV_ESTQ) ELSE ESTQMAX END,0)     PREV_SUG_LIM,
               NVL(CASE WHEN ESTQMAX < (ESTQMIN - PREV_ESTQ) THEN (ESTQMIN - PREV_ESTQ) - ESTQMAX ELSE 0 END,0) PREV_EXTRA_LIM
                 
          INTO vEstoque, vMediaVendaFim, vEstqmin, vEstqmax, vPrevEstq, vPrevOrig, vPrevLim, vPrevExtraLim
               
          FROM (
          
            SELECT FC5ESTOQUEDISPONIVEL(pdSeqProduto, emp.NROEMPRESA) ESTQ, 
                   MAX(PREVISAO)                   MED_PREV_VDA_FIM,
                   AVG(ESTQMINIMODV)               ESTQMIN, 
                   AVG(ESTQMAXIMODV)               ESTQMAX,
                   MIN(PREV_ESTQ)                  PREV_ESTQ
              FROM (
                SELECT X.DTA, P.NROEMPRESA, 
                       ROUND(
                       -- Pega a media de acordo com o param da capa do lote
                       CASE WHEN pdIndTipoMedVda = 'N' THEN P.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(P.MEDVDIAPROMOC,0),P.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(P.MEDVDIAFORAPROMOC,0),P.MEDVDIAGERAL) END
                        * ROWNUM) PREVISAO,
                       --
                       P.ESTQMINIMODV,
                       P.ESTQMAXIMODV,
                       FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, P.NROEMPRESA) ESTQ,
                       -- Pega o estoque da Loja para calculo
                       (FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, P.NROEMPRESA) + 
                       -- Informa se considera estoque da empresa abatecedora no calculo
                       CASE WHEN pdConsEmpAbast = 'S' AND P.NROEMPRESA < 500 THEN
                       FC5ESTOQUEDISPONIVEL(P.SEQPRODUTO, M.NROEMPRESAABASTEC)
                       ELSE 0 END) -
                       -- Pega a media de acordo com o param da capa do lote
                 ROUND(CASE WHEN pdIndTipoMedVda = 'N' THEN P.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(P.MEDVDIAPROMOC,0),P.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(P.MEDVDIAFORAPROMOC,0),P.MEDVDIAGERAL) END
                       --
                       * ROWNUM) PREV_ESTQ
                  FROM DIM_TEMPO X 
                       INNER JOIN MRL_PRODUTOEMPRESA P ON 1=1
                       INNER JOIN MAX_EMPRESA M ON M.NROEMPRESA = P.NROEMPRESA
                       
                 WHERE X.DTA BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) - 1 + NVL(pdPeriodoCalc,0) + NVL(pdDiasAtraso,0)
                   AND P.NROEMPRESA = emp.NROEMPRESA
                   AND P.SEQPRODUTO = pdSeqProduto
                   AND P.ESTQMINIMODV > 0
                   AND P.ESTQMAXIMODV > 0
                   AND EXISTS (SELECT 1 FROM MAC_GERCOMPRAEMP EM WHERE EM.SEQGERCOMPRA = pdSeqGerCompra AND EM.NROEMPRESA = P.NROEMPRESA)
              )
          );

        -- Soma acumulada nas variáveis principais
        pcEstoque        := pcEstoque        + vEstoque;
        pcMediaVendaFim  := pcMediaVendaFim  + vMediaVendaFim;
        pcEstqmin        := pcEstqmin        + vEstqmin;
        pcEstqmax        := pcEstqmax        + vEstqmax;
        pcPrevEstq       := pcPrevEstq       + vPrevEstq;
        pcPrevOrig       := pcPrevOrig       + vPrevOrig;
        pcPrevLim        := pcPrevLim        + vPrevLim;
        pcPrevExtraLim   := pcPrevExtraLim   + vPrevExtraLim;
        
       END;
       
      END LOOP;
        
     -- Se é Loja, retorna a sugestao ate o limite da loja
        IF pdTipoEmp = 'LOJA' THEN
     vsSugestaoFinal := pcPrevLim;
     
     -- Se for CD, retorna o extra calculado para as lojas
     ELSIF pdTIpoEmp = 'CD'   THEN
     vsSugestaoFinal := pcPrevExtraLim;
     
    END IF;
    
    IF pdTipoRetorno = 'S' -- Sugestao
    THEN pdReturn := vsSugestaoFinal;
    
    ELSIF pdTipoRetorno = 'T' -- Total
    THEN pdReturn := pcPrevOrig;
    
    END IF;
    
    RETURN pdReturn;
    
    END NAGF_CALC_SUGEST_COMPRA;
    
PROCEDURE NAGP_ATUALIZA_SUGESTAO (psSeqGerCompra IN NUMBER,
                                  psTipoAt       IN VARCHAR2,
                                  psIndCommit    IN VARCHAR2)
                                  
                   -- De acordo com o PD psTipoAt
                   -- QP - Arredonda a compra final no CD com o que ja esta populado no lote, sem alterar nas lojas.
                   -- AP - Arredonda a compra final no CD com o que ja esta populado no lote, sem alterar nas lojas, de acordo com o percentual (Apontando se e mais prox de LASTRO ou PALETE)
                   -- AL - Arredonda a compra final nas LOJAS com o que ja esta populado no lote, sem popular no CD, de acordo com o percentual (Apontando se e mais prox de LASTRO ou PALETE)
                   -- AC - Arredonda a compra final nas LOJAS com o que ja esta populado no lote, sem popular no CD, de acordo com os parametros (Apontando se e mais prox de LASTRO ou PALETE)
                   -- para AP/AL, a FormaArredSugAbast no CD precisa ser diferente de 'E', se for E nao entrará na regra
                   -- CA - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, arredondando a compra final no CD (Altera Lojas e CD)
                   -- CN - Utiliza o calculo de MIN MAX desenvolvido internamente pelo Nagumo, SEM arredondar a compra final on CD (Altera Lojas e CD)

  IS vsQtdTotalCalc  NUMBER(38);
     vcQtdTotalUpd   NUMBER(38);
     vsPercSugestao  NUMBER(38);
     vcEmbCalc       NUMBER(38);
     indAtualiza     VARCHAR2(1);
     vcSobra         NUMBER(38);
     vTipoAt         VARCHAR2(10);
     psQtdSobraReduz NUMBER(30);

BEGIN
  vsQtdTotalCalc := 0;
  vcQtdTotalUpd  := 0;
  vsPercSugestao := 0;
  
  FOR t IN (SELECT G.SEQGERCOMPRA, GI.SEQPRODUTO, GI.NROEMPRESA,
                   NVL(CASE WHEN psTipoAt IN ('QP','AP','AL','AC') THEN GI.QTDPEDIDA 
                            WHEN psTipoAt IN ('NAP','NAL','NAC')   THEN GI.QTDSUGERIDAFORNEC
                            WHEN psTipoAt IN ('CN','CA') THEN
                   -- Cálculo de caixas (arredondado para cima) 
                   CASE WHEN NVL(FORMAARREDSUGABAST, 'E') = 'E' OR TIPO = 'CD' THEN -- Embalagem Normal
                   CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA,
                       pdTipoRetorno   => 'S'
                     ) / GI.QTDEMBALAGEM) * QTDEMBALAGEM 
                     
                   ELSE
                  (CEIL(CEIL(
                     NAGF_CALC_SUGEST_COMPRA(
                       pdSeqFornecedor => GF.SEQFORNECEDOR,
                       pdNroEmpresa    => GI.NROEMPRESA,
                       pdSeqProduto    => GI.SEQPRODUTO,
                       pdPeriodoCalc   => G.QTDMEDVDA,
                       pdSeqGerCompra  => G.SEQGERCOMPRA,
                       pdIndTipoMedVda => G.INDTIPOMEDVDA,
                       pdTipoRetorno   => 'S'
                     ) / GI.QTDEMBALAGEM) / --< Descobre Qtd de Caixas
                     -- Arredonda embalagem palete ou lastro
                     -- Descobre se o total de caixas é igual ao palete ou lastro
                     (CASE WHEN P.FORMAARREDSUGABAST = 'L' THEN W.PALETELASTRO
                           WHEN P.FORMAARREDSUGABAST = 'P' THEN W.PALETELASTRO * W.PALETEALTURA
                           ELSE GI.QTDEMBALAGEM END)) *
                     (CASE WHEN P.FORMAARREDSUGABAST = 'L' THEN W.PALETELASTRO
                           WHEN P.FORMAARREDSUGABAST = 'P' THEN W.PALETELASTRO * W.PALETEALTURA
                           ELSE GI.QTDEMBALAGEM END)) *
                             
                     QTDEMBALAGEM -- Multiplica para ter o total de unidades
                     END
                     END,0) QTY_FINAL,
                     QTDEMBALAGEM qtdEmb,
                     CASE WHEN P.FORMAARREDSUGABAST = 'E' THEN GI.QTDEMBALAGEM 
                          WHEN P.FORMAARREDSUGABAST = 'L' THEN w.PALETELASTRO 
                          WHEN P.FORMAARREDSUGABAST = 'P' THEN w.PALETELASTRO * w.PALETEALTURA END qtdArred,
                     TIPO,
                     NVL(P.PERCVARIACAOSUG,0) PERCVARIACAOSUG,
                     w.PALETELASTRO QTY_LASTRO,
                     w.PALETELASTRO * w.PALETEALTURA QTY_PALETE,
                     NVL(FORMAARREDSUGABAST, 'E') FormaAbastec
                     
                   
                   
              FROM MAC_GERCOMPRA G INNER JOIN MAC_GERCOMPRAITEM GI  ON G.SEQGERCOMPRA = GI.SEQGERCOMPRA
                                   INNER JOIN MAC_GERCOMPRAFORN GF  ON GF.SEQGERCOMPRA = G.SEQGERCOMPRA
                                   INNER JOIN MRL_PRODUTOEMPRESA P  ON P.SEQPRODUTO = GI.SEQPRODUTO AND P.NROEMPRESA = GI.NROEMPRESA
                                    LEFT JOIN MRL_PRODEMPRESAWM  W  ON W.SEQPRODUTO = GI.SEQPRODUTO AND W.NROEMPRESA = GI.NROEMPRESA
                                   INNER JOIN DWNAGT_DADOSEMPRESA D ON D.NROEMPRESA = GI.NROEMPRESA
                                   
                                   WHERE G.SEQGERCOMPRA  = psSeqGerCompra
                                     --AND G.SITUACAOLOTE  = 'A'
                                     --AND G.TIPOSUGCOMPRA = 'M'
                                     
             ORDER BY GI.SEQPRODUTO, GI.NROEMPRESA ASC -- Nao remover
             
                                     --AND G.SEQGERMODELOCOMPRA IS NOT NULL
           )
  LOOP
    vsQtdTotalCalc := vsQtdTotalCalc + T.QTY_FINAL;
    indAtualiza := 'N';
    
    -- decode para NAP NAL NAC
    
     vTipoAt := CASE psTipoAt
             WHEN 'NAC' THEN 'AC'
             WHEN 'NAP' THEN 'AP'
             WHEN 'NAL' THEN 'AL'
             ELSE psTipoAt
           END;
    -- Aqui vai entrar a regra para arredondar a compra completa em paletes ou lastros
    -- Apenas arredonda nos PDs 'CA', 'QP', 'AP', 'AL', 'AC'
    
    IF t.TIPO = 'CD' THEN
   
      IF vTipoAt IN ('AP','AL','AC')  AND t.FormaAbastec != 'E' AND NVL(t.QTY_LASTRO,0) > 0 AND NVL(t.QTY_PALETE,0) > 0 AND t.PERCVARIACAOSUG > 0 THEN 
      vsPercSugestao := t.PERCVARIACAOSUG;
      -- AP/AL - Arredonda de acordo com percentual para definir se calcula Palete ou Lastro, apenas se FormaArredSugAbast for L ou P
      -- Exemplo: Se o total nas lojas passa de 80% do perc de sugestao, sobe o arredondamento para palete, se nao mantem lastro
      IF vTipoAt IN ('AP','AL') THEN
        IF    ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_PALETE) * t.QTY_PALETE) / t.QTY_PALETE * 100 >= vsPercSugestao THEN
        vcEmbCalc := t.QTY_PALETE;
        indAtualiza := 'S';
        ELSIF ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_LASTRO) * t.QTY_LASTRO) / t.QTY_LASTRO * 100 >= vsPercSugestao THEN
        vcEmbCalc := T.QTY_LASTRO;
        indAtualiza := 'S';
        -- [NOVO] nao atingiu o percentual p/ completar o proximo palete/lastro.
        -- Se a sobra do lastro for de ate 10%, guarda a sobra (em unidades) pra
        -- reduzir nas lojas via NAGP_RATEIA_ACRESC_SUGEST -- tratamento la dentro.
        ELSIF ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_LASTRO) * t.QTY_LASTRO) / t.QTY_LASTRO * 100 <= 10 THEN
                psQtdSobraReduz := ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_LASTRO) * t.QTY_LASTRO) * t.qtdEmb;
        END IF;
     -- AC - Arredonda para Palete ou Lastro conforme parametro na mrl_produtoempresa no CD
      ELSIF vTipoAt IN ('AC') THEN
        IF    t.FormaAbastec = 'P' AND ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_PALETE) * t.QTY_PALETE) / t.QTY_PALETE * 100 >= vsPercSugestao THEN
        vcEmbCalc := t.QTY_PALETE;
        indAtualiza := 'S';
        ELSIF t.FormaAbastec = 'L' AND ((vsQtdTotalCalc / t.qtdEmb) - FLOOR((vsQtdTotalCalc / t.qtdEmb) / t.QTY_LASTRO) * t.QTY_LASTRO) / t.QTY_LASTRO * 100 >= vsPercSugestao THEN
        vcEmbCalc := T.QTY_LASTRO;
        indAtualiza := 'S';
        ELSE
        indAtualiza := 'N';
        END IF;
      END IF;
      
          -- Bloco final do IF para update no CD ou rateio nas lojas
          IF indAtualiza = 'S' THEN
          vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.qtdEmb) / vcEmbCalc) * vcEmbCalc) * t.qtdEmb) - vsQtdTotalCalc + t.QTY_FINAL;
            -- Arredonda nas lojas se o PD for igual a AL/AC e o update é atraves da Proc NAGP_RATEIA_ACRESC_SUGEST
            IF vTipoAt IN ('AL','AC') THEN
                  NAGP_RATEIA_ACRESC_SUGEST(t.SEQGERCOMPRA, t.SEQPRODUTO, t.qtdEmb, vcQtdTotalUpd, 'N', psIndCommit,0);
                  indAtualiza := 'N';
            END IF;
          -- [NOVO] mesmo sem arredondar p/ cima (indAtualiza = 'N'), se ficou
          -- sobra pra reduzir, manda pra proc de rateio tratar
          ELSIF psQtdSobraReduz > 0 AND vTipoAt IN ('AL','AC') THEN
              NAGP_RATEIA_ACRESC_SUGEST(psSeqGerCompra  => t.SEQGERCOMPRA,
                                        psSeqProduto    => t.SEQPRODUTO,
                                        psQtdEmb        => t.qtdEmb,
                                        psQtdUnidade    => 0,
                                        pdIndTipoMedVda => 'N',
                                        psIndCommit     => psIndCommit,
                                        psQtdSobraReduz => psQtdSobraReduz);
          END IF;
    
      END IF; 
   --Arredonda de acordo com a config no CD (Palete/Lastro)
    ELSIF vTipoAt IN('CA','QP') THEN 
    vcQtdTotalUpd := ((CEIL((vsQtdTotalCalc / t.qtdEmb) / t.qtdArred) * t.qtdArred) * t.qtdEmb) - vsQtdTotalCalc + t.QTY_FINAL;
    indAtualiza := 'S';
   -- Nao Arredonda
    ELSIF vTipoAt = 'CN' THEN 
    vcQtdTotalUpd := t.QTY_FINAL;
    indAtualiza := 'S';
       
    ELSIF t.TIPO = 'LOJA' THEN
    vcQtdTotalUpd := t.QTY_FINAL;
    indAtualiza := 'S'; 
    
  END IF;
     IF indAtualiza = 'S' AND vTipoAt NOT IN ('AL','AC') THEN
       
     UPDATE MAC_GERCOMPRAITEM XI SET XI.QTDSUGERIDAORIGINAL = vcQtdTotalUpd,
                                     XI.QTDPEDIDA           = vcQtdTotalUpd
                               WHERE XI.NROEMPRESA          = T.NROEMPRESA
                                 AND XI.SEQPRODUTO          = CASE WHEN t.FormaAbastec = 'E' AND vTipoAt = 'AP'  
                                                                OR vTipoAt IN ('AP','CA','QP','AL') AND (NVL(t.QTY_LASTRO,0) = 0 OR NVL(t.QTY_PALETE,0) = 0 OR vcEmbCalc = 0)
                                                                OR indAtualiza = 'N' THEN 0 -- Se Lastro ou Palete forem zero, nao atualiza
                                                              ELSE T.SEQPRODUTO END -- 'AP' nao atualiza se FormaAbastec for igual a 'E'
                                 AND XI.SEQGERCOMPRA        = T.SEQGERCOMPRA
                                 -- Este Case é para arredonrar apenas o CD quando for informado o PD psTipoAlt como 'QP'
                                 AND XI.NROEMPRESA = CASE WHEN vTipoAt IN ('QP','AP') THEN 507 
                                                          WHEN vTipoAt IN ('CN','CA') THEN t.NROEMPRESA ELSE 99999 END;
     END IF;                
    -- Reseta os valores após atualizar o valor do primeiro CD e primeiro Produto
    IF 1=1 AND t.TIPO = 'CD' THEN  
      
     vsQtdTotalCalc := 0;
     vcQtdTotalUpd  := 0;
     vsPercSugestao := 0;
     vcEmbCalc := 0;
     
    END IF;
     
  END LOOP;
  
  IF psIndCommit = 'S' THEN
  COMMIT;
  END IF;
  
  END NAGP_ATUALIZA_SUGESTAO;
  
PROCEDURE NAGP_RATEIA_ACRESC_SUGEST (
    psSeqGerCompra  IN NUMBER,
    psSeqProduto    IN NUMBER,
    psQtdEmb        IN NUMBER,
    psQtdUnidade    IN NUMBER,
    pdIndTipoMedVda IN VARCHAR2,
    psIndCommit     IN VARCHAR2,
    psQtdSobraReduz IN NUMBER DEFAULT NULL -- sobra (em unidades) p/ reduzir das lojas; default NULL preserva chamadas existentes
)
IS
    -- Caixas arredondadas para evitar diferenças de precisão
    pcQtdCxs NUMBER := ROUND(psQtdUnidade / psQtdEmb, 6);

    -- [NOVO] quantidade "assinada" que efetivamente sera rateada entre as lojas:
    -- soma normal (psQtdUnidade) OU reducao (psQtdSobraReduz, tratada como negativo).
    -- Sao mutuamente exclusivas (quem chama so preenche uma por vez).
    -- O rateio por maior resto (FLOOR + sobra) e correto matematicamente tanto
    -- pra positivo quanto pra negativo -- FLOOR sempre "sobra" o residuo certo.
    v_qtd_rateio  NUMBER := CASE WHEN NVL(psQtdSobraReduz, 0) <> 0 THEN -psQtdSobraReduz ELSE psQtdUnidade END;

    -- [NOVO] piso em zero: aplicado no UPDATE, pra reducao nunca deixar
    -- QTDPEDIDA negativo. No caminho de soma isso nunca dispara (somar
    -- positivo nao derruba abaixo de zero), entao e seguro pros dois casos.
    v_qtd_atual   NUMBER;
    v_qtd_nova    NUMBER;
    v_sobra_corte NUMBER := 0;
BEGIN
    FOR t IN (
        WITH BASE AS (
            SELECT
                NROEMPRESA,
                MEDIA,
                MEDIA / SUM(MEDIA) OVER() PERC,
                FLOOR(TO_NUMBER(ROUND(v_qtd_rateio / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER()) CX,
                ( (TO_NUMBER(ROUND(v_qtd_rateio / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER())
                  - FLOOR(TO_NUMBER(ROUND(v_qtd_rateio / psQtdEmb, 6)) * MEDIA / SUM(MEDIA) OVER()) ) FRACAO,
                SEQPRODUTO
            FROM (
                SELECT
                    A.NROEMPRESA,
                    CASE
                        WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                        WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                        WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                    END MEDIA,
                    A.SEQPRODUTO
                FROM MRL_PRODUTOEMPRESA A
                WHERE SEQPRODUTO = psSeqProduto
                  AND CASE
                        WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                        WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                        WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                      END > 0
                  AND A.NROEMPRESA < 100
                ORDER BY CASE
                            WHEN pdIndTipoMedVda = 'N' THEN A.MEDVDIAGERAL
                            WHEN pdIndTipoMedVda = 'P' THEN NVL(NULLIF(A.MEDVDIAPROMOC,0), A.MEDVDIAGERAL)
                            WHEN pdIndTipoMedVda = 'E' THEN NVL(NULLIF(A.MEDVDIAFORAPROMOC,0), A.MEDVDIAGERAL)
                         END DESC
                FETCH FIRST 3 ROWS ONLY
            )
        ),
        COM_SOBRA AS (
            SELECT
                BASE.*,
                ROW_NUMBER() OVER(ORDER BY FRACAO DESC) RANK_SOBRA,
                (TO_NUMBER(ROUND(v_qtd_rateio / psQtdEmb, 6)) - SUM(CX) OVER()) SOBRAM
            FROM BASE
        )
        SELECT
            NROEMPRESA,
            MEDIA,
            SEQPRODUTO,
            (CX + CASE WHEN RANK_SOBRA <= SOBRAM THEN 1 ELSE 0 END)
                * psQtdEmb AS QtdCalculada
        FROM COM_SOBRA
        ORDER BY MEDIA DESC
    )
    LOOP
        ------------------------------------------------------------------
        -- [NOVO] aplica com piso em zero; o que nao couber (so acontece
        -- na reducao) e repassado pra proxima loja do loop (MEDIA DESC)
        ------------------------------------------------------------------
                -- [FIX] MAX(...) agregado sempre retorna 1 linha (NULL se a loja nao
        -- tiver registro pra esse produto/compra) -- SELECT INTO direto sem
        -- agregacao estourava ORA-01403 (NO_DATA_FOUND) nesse cenario.
        SELECT NVL(MAX(QTDPEDIDA), 0)
          INTO v_qtd_atual
          FROM MAC_GERCOMPRAITEM
         WHERE NROEMPRESA   = t.NROEMPRESA
           AND SEQPRODUTO   = t.SEQPRODUTO
           AND SEQGERCOMPRA = psSeqGerCompra;

        v_qtd_nova := v_qtd_atual + t.QtdCalculada + v_sobra_corte;

        IF v_qtd_nova < 0 THEN
            v_sobra_corte := v_qtd_nova; -- o que nao coube, tenta na proxima loja
            v_qtd_nova := 0;
        ELSE
            v_sobra_corte := 0;
        END IF;

        UPDATE MAC_GERCOMPRAITEM XI
           SET XI.QTDPEDIDA = v_qtd_nova
         WHERE XI.NROEMPRESA   = t.NROEMPRESA
           AND XI.SEQPRODUTO   = t.SEQPRODUTO
           AND XI.SEQGERCOMPRA = psSeqGerCompra;
    END LOOP;

    -- [NOVO] se ainda sobrou corte apos a ultima loja (reducao pedida maior
    -- do que as 3 lojas tinham disponivel), fica sem aplicar o excedente --
    -- nao ha pra onde mais cortar dentro do escopo desta proc (so top-3).
    -- v_sobra_corte aqui reflete esse residual, caso queira logar/auditar.

    IF psIndCommit = 'S' THEN
    COMMIT;
    END IF;
END;


PROCEDURE NAGP_CONTROLE_SL_CD (psSeqGerCompra NUMBER) AS

BEGIN
  -- Apaga da tabela de registro de sugestao
  DELETE FROM NAGT_GERCOMPRAITEM_SUG_ORIG D 
    WHERE D.SEQGERCOMPRA = psSeqGerCompra;
  -- Insere o atual
  INSERT INTO NAGT_GERCOMPRAITEM_SUG_ORIG (SELECT SEQGERCOMPRA, NROEMPRESA, SEQPRODUTO, QTDPEDIDA, QTDEMBALAGEM FROM MAC_GERCOMPRAITEM XI WHERE XI.SEQGERCOMPRA = psSeqGerCompra);

  -- Faz as alteracoes pra descer pra linha do CD
  FOR item IN (   
  SELECT SEQGERCOMPRA, SEQPRODUTO,
         SUM(XI.QTDPEDIDA) QtyLojas,
         SUM(XI.TFVLRVERBABONIF) / NULLIF(SUM(XI.QTDPEDIDA),0) tfVlrVerbaBonif,
         SUM(XI.TFVLRVERBABONIF) / NULLIF(SUM(XI.QTDPEDIDA),0) vlrUnitVerba,
         SUM(XI.TFVLRVERBABONIFACR) / NULLIF(SUM(XI.QTDPEDIDA),0) tfVlrVerbaBonifAcr
        
    FROM MAC_GERCOMPRAITEM XI INNER JOIN DWNAGT_DADOSEMPRESA E ON E.NROEMPRESA = XI.NROEMPRESA
   WHERE XI.SEQGERCOMPRA = psSeqGerCompra
    AND XI.QTDPEDIDA > 0
    AND E.TIPO != 'CD'
   GROUP BY SEQGERCOMPRA, SEQPRODUTO)
     
    LOOP
  -- Joga pro CD
  UPDATE MAC_GERCOMPRAITEM XI
     SET XI.QTDPEDIDA = item.QtyLojas,
         XI.TFVLRVERBABONIF = item.tfVlrVerbaBonif * XI.QTDEMBALAGEM,
         XI.VLRUNITVERBA = item.vlrUnitVerba * XI.QTDEMBALAGEM,
         XI.TFVLRVERBABONIFACR = item.tfVlrVerbaBonifAcr * XI.QTDEMBALAGEM
   WHERE XI.NROEMPRESA = 507 --<<<<<<<<<<<<<<<<<<<<<< Nao pensei de onde pegar, entao so passa 507 por enquanto
     AND XI.SEQGERCOMPRA = psSeqGerCompra
     AND XI.SEQPRODUTO = item.SEQPRODUTO;
     
   -- Zera as lojas
  UPDATE MAC_GERCOMPRAITEM XI
     SET XI.QTDPEDIDA = 0
   WHERE XI.NROEMPRESA != 507 --<<<<<<<<<<<<<<<<<<<<<< Nao pensei de onde pegar, entao so passa 507 por enquanto
     AND XI.SEQGERCOMPRA = psSeqGerCompra
     AND XI.SEQPRODUTO = item.SEQPRODUTO;
         
   END LOOP;
   COMMIT;
END;
  
END NAGPKG_SUGESTAO_COMPRA;
          

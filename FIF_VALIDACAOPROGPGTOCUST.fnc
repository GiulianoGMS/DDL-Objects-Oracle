CREATE OR REPLACE FUNCTION FIF_VALIDACAOPROGPGTOCUST(pObj IN PKG_FIPROGPGTO.TP_FI_VALIDACAOPROGPGTO)
RETURN VARCHAR2
IS

  Retorno VARCHAR2(4000);
  
BEGIN
  /*Função para ser utilizada pela customização para criar mensagens de Alerta/Erro para ser exibido no Título durante a programação de pagamento FIPROGPGTO.
    Deve retornar o contéudo da string entre os sinais <>.
    Pode retornar mais de uma msg por tipo.
    Ex.:
    <Mensagem 1><Mensagem 2>
  */
  
  SELECT CASE
           WHEN USUALTERACAO LIKE '%JOB%' AND 
               (UPPER(OBSERVACAO) LIKE '%CANC%' 
             OR UPPER(OBSERVACAO) LIKE '%REJEI%'
             OR UPPER(OBSERVACAO) LIKE '%DESPRO%')
            THEN '<Título Inconsistente, progamação retornada!>'
           ELSE 'OK'
         END AS STATUS
    INTO Retorno
    FROM (
        SELECT X.*,
               ROW_NUMBER() OVER (
                   PARTITION BY X.SEQIDENTIFICA
                   ORDER BY X.DTAALTERACAO DESC
               ) AS RN
        FROM FI_MOVOCOR X INNER JOIN FI_TITULO F ON F.SEQTITULO = X.SEQIDENTIFICA
        WHERE X.SEQIDENTIFICA =  pObj.cnSEQTITULO
          AND NOT EXISTS (SELECT 1 FROM NAGT_LIB_CRIT_PROG XX WHERE XX.NROEMPRESA = F.NROEMPRESA AND XX.NROTITULO = F.NROTITULO)
    )
    WHERE RN = 1 AND 1=1;
  
  IF  Retorno = 'OK' THEN
    RETURN '';
  ELSE
  RETURN Retorno;
  
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END FIF_VALIDACAOPROGPGTOCUST;

CREATE OR REPLACE TRIGGER NAGTRG_VALID_TRIB_FAMDIV
BEFORE UPDATE OF NROTRIBUTACAO ON MAP_FAMDIVISAO
FOR EACH ROW
DECLARE
   vCGO76   NUMBER(10);
   vCGO910  NUMBER(10);
   vCGOFinal VARCHAR2(100);
BEGIN

      SELECT MAX('76')
        INTO vCGO76
        FROM MAP_TRIBUTACAOUF X
       WHERE X.NROTRIBUTACAO = :NEW.NROTRIBUTACAO
         AND X.TIPTRIBUTACAO = 'SC'
         AND X.UFEMPRESA = 'SP'
         AND X.UFCLIENTEFORNEC = X.UFEMPRESA
         AND X.NROREGTRIBUTACAO = 0
         AND X.SITUACAONF <> '060'
         AND NOT EXISTS (
               SELECT 1
                 FROM MAX_CODGERALCFOP C
                WHERE C.CODGERALOPER = 76
                  AND C.NROTRIBUTACAO = X.NROTRIBUTACAO
         );

       SELECT MAX('910')
         INTO vCGO910
         FROM MAP_TRIBUTACAOUF X
        WHERE X.NROTRIBUTACAO = :NEW.NROTRIBUTACAO
          AND X.TIPTRIBUTACAO = 'SC'
          AND X.UFEMPRESA = 'RJ'
          AND X.UFCLIENTEFORNEC = X.UFEMPRESA
          AND X.NROREGTRIBUTACAO = 0
          AND X.SITUACAONF <> '060'
          AND NOT EXISTS (
                SELECT 1
                  FROM MAX_CODGERALCFOP C
                 WHERE C.CODGERALOPER = 910
                   AND C.NROTRIBUTACAO = X.NROTRIBUTACAO
          );
            
         vCGOFinal := NULL;

            IF vCGO76 IS NOT NULL THEN
               vCGOFinal := vCGO76;
            END IF;

            IF vCGO910 IS NOT NULL THEN
               vCGOFinal := NVL(vCGOFinal || '/', '') || vCGO910;
            END IF;

   IF vCGOFinal IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(
         -20001,
         'Não foi possível atualizar a tributação. Configure a nova tributação no(s) CGO(s): '
         || vCGOFinal
         || ' e tente novamente.'
         || RPAD(CHR(10), 500, CHR(10))
      );
   END IF;
   
   EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;

END;

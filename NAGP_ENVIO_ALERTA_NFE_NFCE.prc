CREATE OR REPLACE PROCEDURE NAGP_ENVIO_ALERTA_NFE_NFCE AS

-- Job: CONSINCO.NAGJ_EMAILAUTO_ALERTA_NFE_NFCE
-- GLPI: 746723
-- Giuliano 14/08/26

    vsQtdCupons       NUMBER := 0;
    vsQtdCriticas     NUMBER := 0;
    vsEmail           VARCHAR2(4000);
    vsTable            CLOB := EMPTY_CLOB();
    vsHtml             CLOB := EMPTY_CLOB();
    psCodRetPD         VARCHAR2(3000);

BEGIN
    
    -- Checka PD
    SP_BUSCAPARAMDINAMICO('NAGUMO',0,'CODRET_REMOV_EMAILNFE','S', NULL,
                          'Lista de codigos de retorno que nao enviam notificacoes ao time Fiscal sobre NFe/NFCe (NAGP_ENVIO_ALERTA_NFE_NFCE)', psCodRetPD);
                        
    ----------------------------------------------------------------------
    -- Verifica se existem cupons pendentes
    ----------------------------------------------------------------------
    SELECT COUNT(*),
           COUNT(DISTINCT B.CODRETORNO)
      INTO vsQtdCupons,
           vsQtdCriticas
      FROM MONITORPDV.TB_DOCTO A
           INNER JOIN MONITORPDV.TB_DOCTONFE B
              ON A.NROEMPRESA  = B.NROEMPRESA
             AND A.NROCHECKOUT = B.NROCHECKOUT
             AND A.SEQDOCTO    = B.SEQDOCTO
     WHERE A.DTAMOVIMENTO >= TRUNC(SYSDATE - 3)
       AND B.PROTOCOLOENVIO IS NULL
       AND B.CODRETORNO > 110
       AND NOT EXISTS (
                        SELECT 1
                          FROM TABLE(
                                   CAST(
                                       C5_COMPLEXIN.C5INTABLE(
                                           NVL(TRIM(psCodRetPD), 0)
                                       ) AS C5INSTRTABLE
                                   )
                               ) X
                         WHERE X.COLUMN_VALUE = B.CODRETORNO
                    );

    ----------------------------------------------------------------------
    -- Não existem ocorrências
    ----------------------------------------------------------------------
    IF vsQtdCupons = 0 THEN
        RETURN;
    END IF;


    ----------------------------------------------------------------------
    -- Monta as linhas da tabela
    ----------------------------------------------------------------------
    FOR t IN (

        SELECT A.DTAMOVIMENTO,
               B.CODRETORNO,

               REGEXP_REPLACE(
                   B.RETORNO,
                   '\[[^]]*\]',
                   ''
               ) AS RETORNO,

               LISTAGG(
                   DISTINCT B.NROEMPRESA,
                   ', '
               ) WITHIN GROUP (
                   ORDER BY B.NROEMPRESA
               ) AS LOJAS,

               COUNT(*) AS QTDE_CUPONS

          FROM MONITORPDV.TB_DOCTO A

               INNER JOIN MONITORPDV.TB_DOCTONFE B
                  ON A.NROEMPRESA  = B.NROEMPRESA
                 AND A.NROCHECKOUT = B.NROCHECKOUT
                 AND A.SEQDOCTO    = B.SEQDOCTO

         WHERE A.DTAMOVIMENTO >= TRUNC(SYSDATE - 3)
           AND B.PROTOCOLOENVIO IS NULL
           AND B.CODRETORNO > 110
           AND NOT EXISTS (
                        SELECT 1
                          FROM TABLE(
                                   CAST(
                                       C5_COMPLEXIN.C5INTABLE(
                                           NVL(TRIM(psCodRetPD), 0)
                                       ) AS C5INSTRTABLE
                                   )
                               ) X
                         WHERE X.COLUMN_VALUE = B.CODRETORNO
                    )

         GROUP BY A.DTAMOVIMENTO,
                  B.CODRETORNO,
                  REGEXP_REPLACE(
                      B.RETORNO,
                      '\[[^]]*\]',
                      ''
                  )

         ORDER BY A.DTAMOVIMENTO,
                  B.CODRETORNO

    )
    LOOP

        vsTable := vsTable ||

            '<tr>' ||

            ----------------------------------------------------------------
            -- DATA
            ----------------------------------------------------------------
            '<td style="width:80px;' ||
            'padding:8px 6px;' ||
            'font-family:Arial,Helvetica,sans-serif;' ||
            'font-size:13px;' ||
            'line-height:16px;' ||
            'color:#374151;' ||
            'border-bottom:1px solid #e5e7eb;' ||
            'vertical-align:middle;' ||
            'white-space:nowrap;">' ||

            TO_CHAR(
                t.DTAMOVIMENTO,
                'DD/MM/YYYY'
            ) ||

            '</td>' ||


            ----------------------------------------------------------------
            -- LOJAS
            ----------------------------------------------------------------
            '<td style="width:170px;' ||
            'padding:8px 8px;' ||
            'font-family:Arial,Helvetica,sans-serif;' ||
            'font-size:13px;' ||
            'line-height:16px;' ||
            'color:#374151;' ||
            'border-bottom:1px solid #e5e7eb;' ||
            'vertical-align:middle;' ||
            'word-break:break-word;">' ||

            t.LOJAS ||

            '</td>' ||


            ----------------------------------------------------------------
            -- CÓDIGO
            ----------------------------------------------------------------
            '<td style="width:65px;' ||
            'padding:8px 5px;' ||
            'font-family:Arial,Helvetica,sans-serif;' ||
            'font-size:13px;' ||
            'line-height:16px;' ||
            'color:#374151;' ||
            'border-bottom:1px solid #e5e7eb;' ||
            'vertical-align:middle;' ||
            'text-align:center;' ||
            'white-space:nowrap;">' ||

            t.CODRETORNO ||

            '</td>' ||


            ----------------------------------------------------------------
            -- REJEIÇÃO / RETORNO
            ----------------------------------------------------------------
            '<td style="padding:8px 10px;' ||
            'font-family:Arial,Helvetica,sans-serif;' ||
            'font-size:13px;' ||
            'line-height:17px;' ||
            'color:#374151;' ||
            'border-bottom:1px solid #e5e7eb;' ||
            'vertical-align:top;' ||
            'word-break:break-word;' ||
            'overflow-wrap:anywhere;">' ||

            REGEXP_REPLACE(
                t.RETORNO,
                '\[[^]]*\]',
                ''
            ) ||

            '</td>' ||


            ----------------------------------------------------------------
            -- CUPONS
            ----------------------------------------------------------------
            '<td style="width:65px;' ||
            'padding:8px 5px;' ||
            'font-family:Arial,Helvetica,sans-serif;' ||
            'font-size:13px;' ||
            'line-height:16px;' ||
            'color:#374151;' ||
            'border-bottom:1px solid #e5e7eb;' ||
            'vertical-align:middle;' ||
            'text-align:right;' ||
            'white-space:nowrap;">' ||

            t.QTDE_CUPONS ||

            '</td>' ||

            '</tr>';

    END LOOP;


    ----------------------------------------------------------------------
    -- Monta o HTML completo do e-mail
    ----------------------------------------------------------------------
    vsHtml :=

        '<!doctype html>' ||

        '<html lang="pt-BR">' ||

        '<head>' ||

        '<meta charset="utf-8">' ||

        '<meta name="viewport" content="width=device-width,initial-scale=1">' ||

        '</head>' ||

        '<body style="margin:0;padding:0;' ||
        'background:#f3f4f6;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'color:#111;">' ||


        ------------------------------------------------------------------
        -- CONTAINER EXTERNO
        ------------------------------------------------------------------
        '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" ' ||
        'border="0" style="background:#f3f4f6;">' ||

        '<tr>' ||

        '<td align="center" style="padding:24px 10px;">' ||


        ------------------------------------------------------------------
        -- CONTAINER PRINCIPAL
        ------------------------------------------------------------------
        '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" ' ||
        'border="0" style="max-width:1300px;' ||
        'background:#ffffff;' ||
        'border-radius:8px;' ||
        'overflow:hidden;' ||
        'box-shadow:0 6px 18px rgba(17,24,39,0.08);">' ||


        ------------------------------------------------------------------
        -- HEADER
        ------------------------------------------------------------------
        '<tr>' ||

        '<td style="padding:24px 28px;' ||
        'background:#ffffff;' ||
        'color:#111111;">' ||

        '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">' ||

        '<tr>' ||

        '<td style="vertical-align:middle;">' ||

        '<img src="https://blog.nagumo.com.br/wp-content/uploads/2023/04/Horizontal_positivo800px.png" ' ||
        'alt="Supermercados Nagumo" width="120">' ||

        '</td>' ||

        '<td align="right" style="vertical-align:middle;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:14px;' ||
        'color:#374151;">' ||

        '<strong style="font-size:15px;">' ||
        'Fiscal/TI | Supermercados Nagumo' ||
        '</strong>' ||

        '<br>' ||

        'Monitoramento de NFe/NFCe.' ||

        '</td>' ||

        '</tr>' ||

        '</table>' ||

        '</td>' ||

        '</tr>' ||


        ------------------------------------------------------------------
        -- TÍTULO / RESUMO
        ------------------------------------------------------------------
        '<tr>' ||

        '<td style="padding:20px 28px 8px 28px;">' ||

        '<h2 style="margin:0 0 8px 0;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:20px;' ||
        'font-weight:bold;' ||
        'color:#7f1d1d;">' ||

        'Alerta de NFe/NFCe' ||

        '</h2>' ||

        '<p style="margin:0;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:14px;' ||
        'line-height:21px;' ||
        'color:#374151;">' ||

        'Foram identificados ' ||

        '<strong style="color:#b91c1c;">' ||
        vsQtdCupons ||
        '</strong>' ||

        ' cupom(ns) rejeitados ou com pendência no processamento da NFe/NFCe ' ||

        'nos últimos 3 dias, distribuídos em ' ||

        '<strong style="color:#b91c1c;">' ||
        vsQtdCriticas ||
        '</strong>' ||

        ' código(s) de retorno.' ||

        '</p>' ||

        '</td>' ||

        '</tr>' ||


        ------------------------------------------------------------------
        -- TABELA
        ------------------------------------------------------------------
        '<tr>' ||

        '<td style="padding:18px 20px;">' ||

        '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ' ||
        'style="border-collapse:collapse;' ||
        'table-layout:fixed;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:13px;">' ||


        '<thead>' ||

        '<tr>' ||


        -- DATA
        '<th width="80" style="width:80px;' ||
        'padding:9px 6px;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'font-weight:bold;' ||
        'line-height:15px;' ||
        'color:#6b7280;' ||
        'text-align:left;' ||
        'white-space:nowrap;' ||
        'border-bottom:2px solid #d1d5db;">' ||

        'Data' ||

        '</th>' ||


        -- LOJAS
        '<th width="170" style="width:170px;' ||
        'padding:9px 8px;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'font-weight:bold;' ||
        'line-height:15px;' ||
        'color:#6b7280;' ||
        'text-align:left;' ||
        'border-bottom:2px solid #d1d5db;">' ||

        'Lojas' ||

        '</th>' ||


        -- CÓDIGO
        '<th width="65" style="width:65px;' ||
        'padding:9px 5px;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'font-weight:bold;' ||
        'line-height:15px;' ||
        'color:#6b7280;' ||
        'text-align:center;' ||
        'white-space:nowrap;' ||
        'border-bottom:2px solid #d1d5db;">' ||

        'Código' ||

        '</th>' ||


        -- REJEIÇÃO
        '<th style="padding:9px 10px;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'font-weight:bold;' ||
        'line-height:15px;' ||
        'color:#6b7280;' ||
        'text-align:left;' ||
        'border-bottom:2px solid #d1d5db;">' ||

        'Rejeição / Retorno' ||

        '</th>' ||


        -- CUPONS
        '<th width="65" style="width:65px;' ||
        'padding:9px 5px;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'font-weight:bold;' ||
        'line-height:15px;' ||
        'color:#6b7280;' ||
        'text-align:right;' ||
        'white-space:nowrap;' ||
        'border-bottom:2px solid #d1d5db;">' ||

        'Cupons' ||

        '</th>' ||

        '</tr>' ||

        '</thead>' ||


        ------------------------------------------------------------------
        -- CORPO DA TABELA
        ------------------------------------------------------------------
        '<tbody>' ||

        vsTable ||

        '</tbody>' ||

        '</table>' ||

        '</td>' ||

        '</tr>' ||


        ------------------------------------------------------------------
        -- FOOTER
        ------------------------------------------------------------------
        '<tr>' ||

        '<td style="padding:0;background:#f9fafb;' ||
        'border-top:1px solid #eef2f7;">' ||

        '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ' ||
        'style="background:#f9fafb;">' ||

        '<tr>' ||

        '<td style="padding:18px 28px;' ||
        'background:#f9fafb;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:12px;' ||
        'line-height:18px;' ||
        'color:#6b7280;">' ||

        '<strong>SUPERMERCADOS NAGUMO</strong>' ||

        '<br>' ||

        'Alerta automático de monitoramento de NFe/NFCe.' ||

        '</td>' ||

        '<td align="right" style="padding:18px 28px;' ||
        'background:#f9fafb;' ||
        'font-family:Arial,Helvetica,sans-serif;' ||
        'font-size:11px;' ||
        'line-height:17px;' ||
        'color:#9ca3af;' ||
        'white-space:nowrap;">' ||

        'Enviado automaticamente.' ||

        '<br>' ||

        TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') ||

        '</td>' ||

        '</tr>' ||

        '</table>' ||

        '</td>' ||

        '</tr>' ||


        ------------------------------------------------------------------
        -- FECHAMENTO
        ------------------------------------------------------------------
        '</table>' ||

        '</td>' ||

        '</tr>' ||

        '</table>' ||

        '</body>' ||

        '</html>';


    ----------------------------------------------------------------------
    -- ENVIO DO E-MAIL
    ----------------------------------------------------------------------
    vsEmail := 'xxxxxxxxxxxxxxxxxxxxx';

    CONSINCO.SP_ENVIA_EMAIL(
        CONSINCO.C5_TP_PARAM_SMTP(1),
        vsEmail,
        'Monitoramento - NFe/NFCe',
        vsHtml,
        'N'
    );


    ----------------------------------------------------------------------
    -- COMMIT
    ----------------------------------------------------------------------
    COMMIT;


EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        RAISE;

END;

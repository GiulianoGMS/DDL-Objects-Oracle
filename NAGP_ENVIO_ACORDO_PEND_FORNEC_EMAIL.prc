CREATE OR REPLACE PROCEDURE NAGP_ENVIO_ACORDO_PEND_FORNEC_EMAIL (psEmail VARCHAR2, psEnviaTICopia VARCHAR2) AS
    vsQtd    NUMBER(30);
    vsEmail  VARCHAR2(200);
    psFornec VARCHAR2(2000);
    psComprador VARCHAR2(2000);
    psRepresentante VARCHAR2(2000);
    vsTable  CLOB := EMPTY_CLOB();
    vsHtml   CLOB := EMPTY_CLOB();
    psEmailTI VARCHAR2(1000);
    psNroAcordo   NUMBER(30);
    vBtnWhatsapp CLOB := EMPTY_CLOB();
    --psIndEnvio    VARCHAR2(1);
    --psExiste VARCHAR2(1);

BEGIN
    -- Envia para TI em copia
    IF psEnviaTICopia = 'S' 
      THEN
        psEmailTI := fEmailTI();
    END IF;
    
    -- Quantidade de acordos
    SELECT COUNT(DISTINCT A.NRO_ACORDO), MAX(A.FORNECEDOR), MAX(INITCAP(COMPRADOR)), MAX(INITCAP(A.RESPACORDONOME))
      INTO vsQtd, psFornec, psComprador, psRepresentante
      FROM NAGV_TAE_ACORDOS_v4 A
     WHERE A.EMAIL = psEmail
       AND A.VENCIMENTO >= TRUNC(SYSDATE)
       AND STATUS IN ('Aguardando assinatura do envelope','Pendente');

    IF vsQtd = 0 THEN
       RETURN; -- não há acordos
    END IF;

    -- Pega dados do Fornecedor
    SELECT 'giuliano.gomes@nagumo.com.br' --MAX(A.EMAIL)
      INTO vsEmail
      FROM DUAL;/* NAGV_TAE_ACORDOS_v4 A
     WHERE A.EMAIL = psEmail
       AND A.VENCIMENTO >= TRUNC(SYSDATE)
       AND STATUS IN ('Aguardando assinatura do envelope','Pendente');*/

    -- Monta as linhas da tabela
    -- o LOOP vai lupar apenas para agregar os dados!
    -- O email será um agrupado (unico)
    
    FOR t IN (
        SELECT DISTINCT A.NRO_ACORDO, A.FORNECEDOR EMPRESA,
               TO_CHAR(A.VLR_ACORDO,'FM999G999G990D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ACORDO,
               TO_CHAR(A.VENCIMENTO, 'DD/MM/YYYY') VENCIMENTO,
               TO_CHAR(A.DATA_EMISSAO, 'DD/MM/YYYY') EMISSAO,
               INITCAP(A.TIPO_ACORDO) TIPO_ACORDO, STATUS, SUBSTR(A.FORNECEDOR,0,30)||'..' FORNEC,
               A.URL_ACO, INITCAP(A.COMPRADOR) COMPRADOR
          FROM NAGV_TAE_ACORDOS_v4 A
         WHERE A.EMAIL = psEmail
           AND A.VENCIMENTO >= TRUNC(SYSDATE)
           AND STATUS IN ('Aguardando assinatura do envelope','Pendente')
           
           ORDER BY STATUS, TO_CHAR(A.DATA_EMISSAO, 'DD/MM/YYYY'), SUBSTR(A.FORNECEDOR,0,30)||'..'
    )
    LOOP
      psNroAcordo := t.Nro_Acordo;
      -- Monta o link pro zap se tiver acordo no tae
      IF t.URL_ACO IS NOT NULL THEN
        IF t.STATUS IN ('Envelope Cancelado', 'Envelope rejeitado') 
        THEN
        vBtnWhatsapp := '<img src="https://img.icons8.com/color/20/000000/high-importance.png" 
                          alt="Alerta" width="20" height="20" 
                          style="margin-left:8px;vertical-align:middle;border:none;">';
        ELSE
        vBtnWhatsapp := ' <a href="'||t.URL_ACO||'" target="_blank" style="margin-left:8px;display:inline-block;">
                          <img src="https://img.icons8.com/color/20/000000/whatsapp.png" alt="WhatsApp" style="vertical-align:middle;border:none;">
                        </a>';
        END IF;
      ELSE 
      vBtnWhatsapp := '<img src="https://img.icons8.com/?size=100&id=dKMGP5XqWxob&format=png" 
                          alt="Alerta" width="20" height="20" 
                          style="margin-left:8px;vertical-align:middle;border:none;">';
      END IF;
      
            vsTable := vsTable ||
                '<tr>
                   <td style="padding:10px;border-bottom:1px solid #f3f4f6;">' || t.NRO_ACORDO || '</td>
                   <td style="padding:10px;border-bottom:1px solid #f3f4f6;">' || T.EMPRESA || '</td>
                   <td style="padding:10px;border-bottom:1px solid #f3f4f6;">' || t.COMPRADOR || '</td>
                   <td style="padding:10px;border-bottom:1px solid #f3f4f6;">
                      <a href="' || t.URL_ACO || '">Assinar documento</a>
                   </td>
                 </tr>';
    END LOOP;

    -- Monta o corpo completo do e-mail
    vsHtml := '<!doctype html>
          <html lang="pt-BR">
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
          </head>
          <body style="margin:0;padding:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;color:#111;">
            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:24px 0;">
              <tr>
                <td align="center">
                  <table role="presentation" width="1100" style="max-width:1100px;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 6px 18px rgba(17,24,39,0.08);">

                    <!-- Header -->
                    <tr>
                      <td style="padding:24px 28px;background:linear-gradient(90deg,#0b6efd,#1e90ff);color:#fff;">
                        <table role="presentation" width="100%">
                          <tr>
                            <td>
                              <img src="https://blog.nagumo.com.br/wp-content/uploads/2023/04/Horizontal_positivo800px.png" alt="Nagumo" width="120">
                            </td>
                            <td align="right" style="font-size:14px;background:#ffffff;color:#111827">
                              <strong>Administração Nagumo</strong><br>
                              Assinatura de Acordos Pendentes
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>

                    <!-- Greeting -->
                    <tr>
                      <td style="padding:24px 28px 12px 28px;">
                        <h2 style="margin:0 0 12px 0;font-size:20px;color:#0b2545;">
                          Prezado(a), ' || psRepresentante || '
                        </h2>

                        <p style="margin:0 0 12px 0;font-size:14px;color:#374151;line-height:1.6;">
                          Verificamos que há <strong>' || vsQtd || '</strong> acordo(s) vinculado(s) à sua(s) empresa(s) aguardando assinatura em nossa plataforma.
                        </p>

                        <p style="margin:0 0 12px 0;font-size:14px;color:#dc2626;line-height:1.6;">
                          Regularize o quanto antes para evitar bloqueio no recebimento das mercadorias.
                        </p>

                        <p style="margin:0;font-size:14px;color:#374151;line-height:1.6;">
                          Para dar continuidade ao processo, solicitamos a revisão e assinatura dos documentos abaixo:
                        </p>
                      </td>
                    </tr>

                    <!-- Agreements list -->
                    <tr>
                      <td style="padding:18px 28px;">
                        <table role="presentation" width="100%" cellpadding="10" cellspacing="0" style="border-collapse:collapse;">
                          <thead>
                            <tr>
                              <th style="text-align:left;font-size:12px;color:#6b7280;border-bottom:1px solid #e5e7eb;">Acordo</th>
                              <th style="text-align:left;font-size:12px;color:#6b7280;border-bottom:1px solid #e5e7eb;">Empresa</th>
                              <th style="text-align:left;font-size:12px;color:#6b7280;border-bottom:1px solid #e5e7eb;">Comprador</th>
                              <th style="text-align:left;font-size:12px;color:#6b7280;border-bottom:1px solid #e5e7eb;">Link para Assinatura</th>
                            </tr>
                          </thead>
                          <tbody>
                            ' || vsTable || '
                          </tbody>
                        </table>
                      </td>
                    </tr>

                    <!-- CTA -->
                    <tr>
                      <td style="padding:12px 28px 24px 28px;">
                        <a href="' || fUrlTAE() || '" 
                           style="display:inline-block;padding:12px 20px;border-radius:8px;background:#10b981;color:#fff;text-decoration:none;font-weight:600;">
                           Acessar Plataforma de Assinatura
                        </a>
                      </td>
                    </tr>

                    <!-- Final text -->
                    <tr>
                      <td style="padding:0 28px 24px 28px;">
                        <p style="font-size:14px;color:#374151;line-height:1.6;margin:0 0 12px 0;">
                          Caso já tenha concluído a assinatura, por favor desconsidere este e-mail.
                        </p>

                      <p style="font-size:14px;color:#374151;line-height:1.6;margin:0 0 12px 0;">
                                      Em caso de dúvidas ou necessidade de suporte, por favor entre em contato com respectivo comprador(a).
                                    </p>

                        <p style="font-size:14px;color:#374151;line-height:1.6;margin:0;">
                          Atenciosamente,<br>
                          <strong>Administração Nagumo</strong>
                        </p>
                      </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                      <td style="padding:18px 28px;background:#f9fafb;border-top:1px solid #eef2f7;">
                        <table role="presentation" width="100%">
                          <tr>
                            <td style="font-size:12px;color:#9ca3af;">
                              Enviado automaticamente, não responda este e-mail.
                            </td>
                            <td align="right" style="font-size:12px;color:#9ca3af;">
                              ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI') || '
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>

                  </table>
                </td>
              </tr>
            </table>
          </body>
          </html>';
    
    IF vsEmail IS NOT NULL THEN

    -- Envia apenas 1 e-mail consolidado
    CONSINCO.SP_ENVIA_EMAIL(
        CONSINCO.C5_TP_PARAM_SMTP(1),
        psEmailTI||vsEmail,
        'Acordos Pendentes no TAE - Totvs Assinatura Eletrônica',
        vsHtml,
        'N');
        
     -- Grava log

    INSERT INTO NAGT_LOG_ENVIO_ACO_EMAIL (
        NRO_ACORDO,
        COD_COMPRADOR,
        EMAIL_DESTINO,
        QTDE_ACORDOS,
        HTML_EMAIL,
        DATA_ENVIO
    ) VALUES (
        psNroAcordo,
        0,
        psEmailTI||vsEmail,
        vsQtd,
        vsHtml,
        SYSDATE
        
    );
    COMMIT;
    
    END IF;
    
END;

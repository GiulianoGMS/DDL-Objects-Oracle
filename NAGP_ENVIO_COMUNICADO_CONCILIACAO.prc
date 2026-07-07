CREATE OR REPLACE PROCEDURE NAGP_ENVIO_COMUNICADO_CONCILIACAO
(
   psEmail         VARCHAR2,
   psEnviaTICopia  VARCHAR2 DEFAULT 'S'
) AS

   vsHtml      CLOB := EMPTY_CLOB();
   vsAssunto   VARCHAR2(200);
   psEmailTI   VARCHAR2(1000);
   psEMailEnviado NUMBER(10);

BEGIN
   
   SELECT COUNT(1) INTO psEMailEnviado FROM NAGT_LOG_ENVIO_ACO_EMAIL X WHERE X.EMAIL_DESTINO = psEmail AND TRUNC(X.DATA_ENVIO) = TRUNC(SYSDATE);
   
   IF psEMailEnviado = 0 THEN

   ------------------------------------------------------------------
   -- ENVIA TI EM CÓPIA
   ------------------------------------------------------------------
   IF psEnviaTICopia = 'S' THEN
      psEmailTI := fEmailTI();
   ELSE
      psEmailTI := NULL;
   END IF;

   ------------------------------------------------------------------
   -- ASSUNTO
   ------------------------------------------------------------------
   vsAssunto := 'Comunicado Importante - Procedimento de Identificação de Pagamentos';

   ------------------------------------------------------------------
   -- HTML
   ------------------------------------------------------------------
   vsHtml :=

'<!doctype html>
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
                  <img src="https://blog.nagumo.com.br/wp-content/uploads/2023/04/Horizontal_positivo800px.png"
                       alt="Grupo Nagumo"
                       width="120">
               </td>

               <td align="right" style="background:#ffffff;color:#111827;">
                  <strong style="font-size:14px;">Grupo Nagumo</strong><br>
                  <span style="font-size:10px;color:#9ca3af;">
                     Comunicado Financeiro
                  </span>
               </td>
            </tr>
         </table>
      </td>
   </tr>

   <!-- Conteúdo -->
   <tr>
      <td style="padding:28px;">

         <h2 style="margin:0 0 20px 0;font-size:20px;color:#0b2545;">
            Prezados Fornecedores,
         </h2>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            Com o objetivo de assegurar maior eficiência, rastreabilidade e segurança nos processos de conciliação financeira,
            comunicamos uma alteração no procedimento de identificação e direcionamento dos valores recebidos para quitação de
            contratos e acordos comerciais e logísticos.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            <strong>A partir de 27/06/2026</strong>, todo pagamento efetuado pelo fornecedor deverá ser acompanhado da respectiva
            identificação da obrigação que se pretende liquidar, mediante comunicação formal pelos canais disponibilizados pelo Nagumo:
         </p>

         <div style="
               background:#f9fafb;
               border-left:4px solid #0b6efd;
               padding:16px;
               margin:20px 0;
               line-height:1.8;
               font-size:14px;
               color:#374151;">

            <strong>E-mail:</strong><br>
            lista.contasareceber@nagumocombr.onmicrosoft.com

            <br><br>

            <strong>Telefone:</strong><br>
            2413-7212 (solicitar contato com o setor Contas a Receber)

         </div>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            O fornecedor terá o prazo de <strong>5 dias corridos</strong>, contados da data de efetivação do pagamento,
            para informar formalmente a qual contrato, acordo ou débito o valor deverá ser vinculado.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            Após o prazo estabelecido acima, o Grupo Nagumo realizará a conciliação dos valores do acordo com vencimento mais antigo
            para o mais novo, independentemente da natureza da obrigação, da existência de negociações paralelas ou da intenção
            originalmente atribuída pelo fornecedor ao pagamento realizado.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            Reforçamos que, após a efetivação da quitação do pagamento em conformidade com o presente procedimento,
            não poderemos receber solicitações de alteração da destinação dos valores.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            O presente procedimento aplica-se a todos os pagamentos realizados após sua entrada em vigor e passa a integrar
            as regras operacionais de relacionamento financeiro entre as partes, sem prejuízo das demais disposições
            contratuais vigentes.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            Em caso de dúvidas ou necessidade de esclarecimentos, solicitamos que entrem em contato com
            <strong>lista.contasareceber@nagumocombr.onmicrosoft.com</strong>.
         </p>

         <p style="font-size:14px;color:#374151;line-height:1.8;">
            Atenciosamente,<br>
            <strong>Grupo Nagumo</strong>
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
                  '||TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI')||'
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

   ------------------------------------------------------------------
   -- ENVIO
   ------------------------------------------------------------------
   CONSINCO.SP_ENVIA_EMAIL(
      CONSINCO.C5_TP_PARAM_SMTP(1),
      psEmailTI || psEmail,
      vsAssunto,
      vsHtml,
      'N'
   );
   
    INSERT INTO NAGT_LOG_ENVIO_ACO_EMAIL (
        NRO_ACORDO,
        COD_COMPRADOR,
        EMAIL_DESTINO,
        QTDE_ACORDOS,
        HTML_EMAIL,
        DATA_ENVIO
    ) VALUES (
        0,
        0,
        psEmailTI||psEmail,
        1,
        vsHtml,
        SYSDATE
        
    );
    
   COMMIT;
   
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(
         -20001,
         'Erro ao enviar comunicado de conciliação financeira: ' ||psEmail||' - '|| SQLERRM
      );
END;

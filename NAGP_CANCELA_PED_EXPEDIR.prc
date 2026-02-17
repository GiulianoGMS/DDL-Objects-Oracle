CREATE OR REPLACE PROCEDURE NAGP_CANCELA_PED_EXPEDIR (psNroPedVenda NUMBER, psNroEmpresa NUMBER) AS
-- Replica do job SM_CANCELA_PEDIDO_EXPEDIR
-- Para cancelar determinado pedido
-- Giuliano

/*
Alterado em 16/05/2024 por Giuliano - Alterado para nao excluir pedidos da 503
Alterado em 20/05/2021 para realizar o cancelamento apenas dos pedidos a expedir de 
abastecimento e transferência interna dentro de 4 dias depois de aberto, conforme solicitação do ticket 11563489*/
--- Alterado po Cipolla em 09/10/2024 CD com atraso nas expedições. para 5 para 10 dias.

BEGIN
  FOR T IN (SELECT A.NROPEDVENDA, A.DTAINCLUSAO, A.NROEMPRESA, A.TIPPEDIDO
              FROM CONSINCO.MAD_PEDVENDA A
             WHERE A.SITUACAOPED != 'F'
               AND A.NROPEDVENDA = psNroPedVenda
               AND A.NROEMPRESA = psNroEmpresa
               AND A.DTAINCLUSAO >= SYSDATE - 30
             ORDER BY A.DTAINCLUSAO) LOOP

    UPDATE CONSINCO.MAD_PEDVENDAITEM B
       SET B.QTDATENDIDA = 0
     WHERE B.NROPEDVENDA = T.NROPEDVENDA;
  
    UPDATE CONSINCO.MAD_PEDVENDA
       SET SITUACAOPED     = 'C',
           DTACANCELAMENTO = SYSDATE,
           USUCANCELAMENTO = 'CancManual',
           MOTCANCELAMENTO = 'Cancelamento de Pedido Manual',
           OBSCANCELAMENTO = 'PRC_GLN',
           INDREPLICAFV    = 'S'
     WHERE NROPEDVENDA = T.NROPEDVENDA;
  
   
      COMMIT;
     
  END LOOP;
  
END;

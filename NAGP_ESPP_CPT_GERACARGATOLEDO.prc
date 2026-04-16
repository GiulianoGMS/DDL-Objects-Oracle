CREATE OR REPLACE PROCEDURE NAGP_ESPP_CPT_GERACARGATOLEDO(pdDtaBaseExportacao in mrl_logexportacao.dtamovimento%type,
                                                          psDiretorio         IN VARCHAR2 DEFAULT NULL) IS
                                                          
  -- Versao Giuliano para geracao de carga para CD agrupado

  vhWndFile            sys.utl_file.File_type;
  vsFileName           mrlx_cargapdvemporium.arquivo%type := ' ';
  vsQuebraLinha        varchar2(2);
  pdListaEmp           VARCHAR2(4000);

BEGIN
  
-- Busca lista de empresas
  SP_BUSCAPARAMDINAMICO('NAGUMO',0,'EMP_EXP_CARGA_BAL_CD','S', NULL,
                        'Empresas para exportacao da carga de balanca agrupada no CD', pdListaEmp);
  vsFileName := ' ';
  vsQuebraLinha := chr(13) || chr(10);

  for t in (SELECT /*+ ORDERED */  DISTINCT A.arquivo, A.linha
              FROM ESPV_CPT_PRODUTOS A
             WHERE A.NROEMPRESA IN (SELECT COLUMN_VALUE
                       FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLE(NVL(TRIM(pdListaEmp),0)) AS C5INSTRTABLE)))
               AND trunc(NVL(a.dtavalidacaopreco,DATE '1990-01-01')) between
                   trunc(pdDtaBaseExportacao) and trunc(sysdate)) loop
    if vsFileName != t.arquivo then
      if vsFileName != ' ' then
        sys.utl_file.FClose(vhWndFile);
      end if;
      vhWndFile  := sys.utl_file.FOpen(psDiretorio,
                                       t.arquivo,
                                       'w',
                                       4000);
      vsFileName := t.arquivo;
    end if;
    sys.utl_file.Put(vhWndFile, t.linha || vsQuebraLinha);
    sys.utl_file.fflush(vhWndFile);

  end loop;
  
  if sys.utl_file.is_open(vhWndFile) then
     sys.utl_file.fclose(vhWndFile);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20200, sqlerrm);
END;

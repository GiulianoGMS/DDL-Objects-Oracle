CREATE OR REPLACE PROCEDURE NAGP_EXT_CAT28 (psNroEmpresa NUMBER) IS

    v_file UTL_FILE.file_type;

BEGIN
    -- Abre o arquivo
    v_file := UTL_FILE.fopen('EXT_CAT28',
                             'Ext_ExclusaoCat28_LJ_'||LPAD(psNroEmpresa,3,0)||'.txt',
                             'w', 32767);

    -- Loop linha a linha
    FOR bs IN (
        SELECT X.LINHA_ARQ
          FROM NAGV_APURACAO_CAT28_V3 X
         WHERE X.LJ = psNroEmpresa
    )
    LOOP
        UTL_FILE.put_line(v_file, bs.LINHA_ARQ);
    END LOOP;

    -- Fecha o arquivo fora do loop
    UTL_FILE.fclose(v_file);

EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;
        RAISE;
END;

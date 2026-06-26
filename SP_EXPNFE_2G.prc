CREATE OR REPLACE PROCEDURE SP_EXPNFE_2G(
                 pnSeqNotaFiscal IN MFL_DOCTOFISCAL.SEQNOTAFISCAL%TYPE,
                 psSoftwarePDV   IN MRL_EMPSOFTPDV.SOFTPDV%TYPE)
IS
    vnCount                         integer;
    vsResultado                     varchar2(1);
    vsEmite_IE_ST                   VARCHAR2(1);
    vsTipoTabela                    varchar2(1);
    vnNroEmpresa                    mflv_basenf.nroempresa%type;
    vsGERA_ITEM_LIQ_DESC            max_parametro.valor%type;
    vsEMITE_QTDVOLUME_WMS           max_parametro.valor%type;
    vsEMITE_TRANSPOR_CIF            max_parametro.valor%type;
    vsPD_InfoEspecVolume            max_parametro.valor%type;
    vsPD_InfoMarcaVolume            max_parametro.valor%type;
    vsPD_InfoNumVolume              max_parametro.valor%type;
    vsPDIndGeraRefFabricCodProd     max_parametro.valor%type;
    vsPDConcSeqProdDescrProd        max_parametro.valor%type;
    vsPDTipoNumeracaoTitulo         max_parametro.valor%type;
    vsPDDataPadraoEmissaoNF         max_parametro.valor%type;
    vsPDConsideraDescSFDuplic       max_parametro.valor%type;
    vsPDConsidVlrDescEspecialItem   max_parametro.valor%type;
    vsPDGeraSeparacaoPed            max_parametro.valor%type;
    vsPDInscRgPesFisicaContribIcms  max_parametro.valor%type;
    vsPDGeraTabelaTMPM011Info       max_parametro.valor%type;
    vsPDInscRgPesFisicaPrdRural     max_parametro.valor%type;
    vsPDInscRgPesFisicaTransp       max_parametro.valor%type;
    vsIndEmiteIcms                  max_codgeraloper.indemiteicms%type;
    vsIndEmiteIcmsSt                max_codgeraloper.indemiteicmsst%type;
    vsIndVlrIpiDadoAdic             max_codgeraloper.indvlripidadoadicional%type;
    vsSelect                        varchar2(4000);
    vsPDGeraLocEntPessoaFisica      max_parametro.valor%type;
    vsPDGeraValorFreteNFCif         max_parametro.valor%type;
    vsPDDeduzDescComercDuplic       max_parametro.valor%type;
    vsPDDeduzVlrIndenizacaoDuplic   max_parametro.valor%type;
    vsPDDeduzDescFunRuralDuplic     max_parametro.valor%type;
    vsPDDeduzDescIcmsDuplic         max_parametro.valor%type;
    vsPDDeduzDescPisDuplic          max_parametro.valor%type;
    vsPDDeduzDescCofinsDuplic       max_parametro.valor%type;
    vsPDDeduzDescCSLLDuplic         max_parametro.valor%type;
    vsPDDeduzDescIRDuplic           max_parametro.valor%type;
    vsPDDeduzDescINSSDuplic         max_parametro.valor%type;
    vsPDDeduzDescISSDuplic          max_parametro.valor%type;
    vsPDDeduzDescFinancDuplic       max_parametro.valor%type;
    vnRegimeTribut                  rf_parametro.regimetribut%type;
    vsRowID_TMP_SEQUENCE            rowid;
    vnSeqNFeDuplicata               number(38);
    vnSeqNFeItemMed                 number(38);
    vsPD_SitDescPisSuspZFM          max_parametro.valor%type;
    vsPD_SitDescCofinsSuspZFM       max_parametro.valor%type;
    vsIndSuspPisCofins              mfl_doctofiscal.indsusppiscofins%type;
    vnSeqPessoaNota                 ge_pessoa.seqpessoa%type;
    vnCountCidadeZFM                number;
    vnSeqM000_ID_NF                 number(38) := 0;
    vnSeqM013_ID_CHAVE_REF          number(38) := 0;
    vnSeqM005_ID_LOCAL              number(38) := 0;
    vnM019_id_di                    integer :=0;
    vnM020_id_adicao                integer :=0;
    vsPDUsuEmitiuPDV                MAX_PARAMETRO.VALOR%type;
    vnAppOrigem                     MFLV_BASENF.APPORIGEM%type;
    vsUsuEmitiuPDV                  MFLV_BASENF.USUEMITIU%type;
    vsPDGeraDuplicata               max_parametro.valor%type;
    vsIndConvEmbalagem              mrl_cargaexped.indconvembalagem%type;
    vnNroRegTribDevol               mfl_doctofiscal.nroregtributacao%type;
    vnCountNF                       number := 0;
    vsPDEmiteFreteDocTransp         max_parametro.valor%type;
    vsGeraFreteTipoEntrega          max_parametro.valor%type;
    vsIndConvEmbNFe                 max_empresa.indconverteembnfe%type;
    vsIndIipoEmbDanfeClie           mrl_cliente.indtipoembdanfe%type;
    vnCodGeralOper                 mfl_doctofiscal.codgeraloper%type;
    vsPDTipoNFEmissaoVolume        varchar2(1);
    vsPDEmiteInfoLoteProd          max_parametro.Valor%TYPE;
    vsPDGeraFCI                    varchar2(1);
    vsPDTipGeraCartaoDanfe         MAX_PARAMETRO.PARAMETRO%TYPE;
    vsTipoDoctoFiscal              MAX_CODGERALOPER.TIPDOCFISCAL%TYPE;
    vsPD_ConcatNfRefObsNF          MAX_PARAMETRO.PARAMETRO%TYPE;
    vsPDVersaoXml                  max_parametro.valor%type;
    vnIdDuplicata                  number;
    vbInseriuDuplicata             boolean := false;
    vsTipNotaFiscal                max_codgeraloper.tipdocfiscal%type;
    vsTipUso                       max_codgeraloper.tipuso%type;
    vnSeqAuxNotaFiscal             mlf_notafiscal.seqauxnotafiscal%type;
    vsTipoFrete                    mlf_notafiscal.tipfretetransp%type;
    vnExisteConhecimento           integer;
    vsUsuEmitiuNFe                 MFLV_BASENF.USUEMITIU%type;
    vnUsuPainel                    number;
    vsSoftwarePDV                  mrl_empsoftpdv.softpdv%type;
    vsModeloDF                     mflv_basenf.modelodf%type;
    vsPD_SomaVlrFECPAcrescimo      max_parametro.Valor%TYPE;
    vsIndPrecoEmbalagem            Mad_Segmento.Indprecoembalagem%TYPE;
    vnPrecoMaxConsumidor           Mrl_Prodempseg.Precomaxconsumidor%TYPE;
    vsPDUsaPercDescDANFE               max_parametro.valor%type;
    vsPDCgo_N_GeraDuplicataNfe     max_parametro.valor%type;
    vsPDFormaPagtoNaoGeraFatura    max_parametro.valor%type;
    vsPD_ListaCfopEstPisCof        max_parametro.valor%type;
    vsPDExibeSeqTransportDanfe     max_parametro.valor%type;
    vnEntradaSaida                 TMP_M000_NF.M000_DM_ENTRADA_SAIDA%type;
    vsUfDestino                    TMP_M000_NF.UFDESTINOC5%type;
    vsIndGeraIPIDevXML             max_parametro.valor%type;
    vsPD_ConsOrigemMercNfRef       MAX_PARAMETRO.VALOR%TYPE;
    vsNatOper                      tmp_m000_nf.m000_ds_nat_oper%type;
    vsIndUtilCalcFCP               max_empresa.indutilcalcfcp%type;
    vnSeqNotaFiscalVolume          number(15);
    vsPDGeraCestGenerico           max_parametro.valor%type;
    vsIndEmiteSTRefUltEntrada      MRL_CLIENTE.INDEMITESTREFULTENTRADA%TYPE;
    vnIndNFIntegraFiscal           MFLV_BASENF.INDNFINTEGRAFISCAL%TYPE;
    vsPDEmiteObsImpostoRetidoSP    max_parametro.valor%type;
    vsUfOrigem                     MAX_EMPRESA.UF%TYPE;
    vsTipdocfiscal                 MAX_CODGERALOPER.TIPDOCFISCAL%TYPE;
    vnCfop_Dev_Vend_N_Reconhec     TMP_M000_NF.CFOP_DEV_VEND_N_RECONHEC%TYPE;
    pObjfc5_RazaoSocialCust tp_fc5_RazaoSocialCust := tp_fc5_RazaoSocialCust(null);
    vsPDConsisteDetPagtoTpIntegra  MAX_PARAMETRO.VALOR%TYPE;
    vsPDUtilTribUFMotDesonerado    MAX_PARAMETRO.VALOR%TYPE;
    vdPDGeraTagMed                 MAX_PARAMETRO.VALOR%TYPE;
    vsPDConsInfSeloIpi             MAX_PARAMETRO.VALOR%TYPE;
    voTP_SP_EXPNFE_2G              TP_SP_EXPNFE_2G := TP_SP_EXPNFE_2G(NULL, NULL, NULL, NULL);
    vsPDTrocaCstPisCfXml           MAX_PARAMETRO.VALOR%TYPE;
    vsPDSubtraiICMSDesonTotItem    MAX_PARAMETRO.VALOR%TYPE;
    vsPDCalcBaseIcmsAFRMM          MAX_PARAMETRO.VALOR%TYPE;
    vsIndConsideraImposto          CCT_PAINELCONFIGURACAO.INDCONSIDERAIMPOSTO%TYPE;
    vsPDConsid_Imp_VlrOutras       MAX_PARAMETRO.VALOR%TYPE;
    vsGeraNFRefDetItem             VARCHAR2(1);
    vsIndGeraHash                  MAX_EMPRESA.INDHASHCSRT%TYPE;
    vsIndImportExport              MAX_CODGERALOPER.INDIMPORTEXPORT%TYPE;
    vsObsPorProduto                VARCHAR2(1000);
    vnIndTipoFinalidadeNfe         MAX_CODGERALOPER.TIPOFINALIDADENFE%TYPE;
    vnIndTipoNfCreditoDebitodet    MLF_NOTAFISCAL.INDTIPONFCREDITODEBITODET%TYPE;
BEGIN
    SELECT MAX(A.NROEMPRESA), A.codgeraloper, A.tipdocfiscal
    INTO   VNNROEMPRESA, vnCodGeralOper, vsTipoDoctoFiscal
    FROM   MFLV_BASENF A
    WHERE  A.SEQNOTAFISCAL = pnSeqNotaFiscal
    and    a.tipuso != 'R'
    GROUP BY a.nroempresa, a.codgeraloper, A.tipdocfiscal;
    select nvl(a.indconverteembnfe, 'N'), nvl(a.indutilcalcfcp, 'N'), a.uf, a.indhashcsrt
    into vsIndConvEmbNFe, vsIndUtilCalcFCP, vsUfOrigem, vsIndGeraHash
    from max_empresa a
    where a.nroempresa = vnNroEmpresa;
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',0,'EMITE_COD_DESTINATARIO','S','N',
                          'EMITE CÓDIGO DO CLIENTE JUNTO A RAZÃO SOCIAL NA DANFE (S/N)?', vsResultado);
    SP_BUSCAPARAMDINAMICO('EMISSAO_NF',VNNROEMPRESA,'EMITE_INSCRICAO_ST','S','N',
                          'EMITE INSCRIÇÃO DE ST NA NOTA FISCAL? (S-SIM, N-NÃO, I-SOMENTE QUANDO POSSUIR ITENS COM ICMS ST NA NF).', vsEmite_IE_ST);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'GERA_ITEM_LIQ_DESC','S','N',
                          'GERA VALOR DO ÍTEM LIQUIDO DO DESCONTO? (S-SIM, N-NAO).', vsGERA_ITEM_LIQ_DESC);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'EMITE_QTDVOLUME_WMS','S','N',
                          'INDICA SE UTILIZA O VOLUME RETORNADO PELO LOCUS. (S-SIM, N-NAO).' ||
                          'SÓ FUNCINA QUEM USA SISTEMA INTEGRADO COM LOCUS', vsEMITE_QTDVOLUME_WMS);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'EMITE_TRANSPORTADOR_CIF','S','N',
                          'GERA INFORMAÇÕES DO TRANSPORTADOR NA NOTA MESMO QUANDO FRETE FOR CIF? (S-SIM, N-NAO). ' ||
                          'QUANDO FRETE É FOB, AS INFORMAÇÕES JÁ SÃO GERADAS', vsEMITE_TRANSPOR_CIF);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'INFO_ESPEC_VOLUME','S','N',
                         'INFORMA O TEXTO QUE DEVERÁ SER PASSADO PARA INFORMAÇÃO REFERENTE A ESPÉCIE DE VOLUME CASO O MESMO NÃO ESTEJA INFORMADO NA NOTA FISCAL.' ||
                         'CASO A NOTA NÃO TENHA A ESPECIE VOLUME INFORMADA E O PARAMETRO ESTIVER CONFIGURADO N, SERÁ GERADO NULO NO ARQUIVO', vsPD_InfoEspecVolume);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'GERA_REF_FABRIC_CODPROD','S','N',
                          'GERA A REF DO FABRICANTE NO CAMPO CÓD PRODUTO(M014_CD_PRODUTO) OU CONCATENADO NA DESC DO PRODUTO(M014_DS_PRODUTO)?' ||chr(13)||
                           'S-SIM, NO CÓDIGO DO PRODUTO'||chr(13)||
                           'N-NÃO GERA(PADRÃO)'||chr(13)||
                           'D-SIM, NA DESC DO PROD' ||chr(13)||
                           'R-SIM, NA DESC DO PROD COM "REF" ANTES', vsPDIndGeraRefFabricCodProd);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'CONC_SEQPROD_DESCRPROD','S','N',
                          'CONCATENA O SEQPRODUTO NO CAMPO DESCRICAO DO PRODUTO (M014_DS_PRODUTO)? (S-SIM, N-NAO).', vsPDConcSeqProdDescrProd);
    SP_CHECAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'EMITE_ASTER_DESCPROD_PISCOFINS','S','N',
                          'EMITE ASTERISCO JUNTO A DESCRIÇÃO QUANDO O PRODUTO FOR PIS/COFINS? (S-SIM, N-NAO).');
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'TIPO_NUMER_TITULO_PARCELAS','S','S',
                          'TIPO DE NUMERACAO A SER EMITIDA NAS PARCELAS DO DANFE: S - SEQTITULO(PADRAO) / N - NRODOCUMENTO.', vsPDTipoNumeracaoTitulo);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'DATA_PADRAO_EMISSAO_NOTA','S','E',
                          'TIPO DE DATA PARA EMISSÃO DA DANFE:
                          E - DATA DE EMISSÃO (PADRÃO)
                          S - DATA HORA DE SAÍDA, QUANDO A MESMA FOR NULA PASSA DATA DE EMISSÃO
                          D - SOMENTE DATA HORA DE SAÍDA.
                          P - DTAHORA DE IMP QDO A DATA SAIDA NAO POSSUIR HORA', vsPDDataPadraoEmissaoNF);
    SP_BUSCAPARAMDINAMICO('SILLUS_INTEGRA_CAPITIS', 0,'CONSID_VLR_DESC_ESPECIAL_ITEM','S','N',
                          'CONSIDERA O VLR DESC ESPECIAL CLIE NA INTEGRAÇÃO DO VLR DO ITEM P/ O FISCI(S/N)?'||chr(13) ||
                          'QDO (S) O QRP DA NF DEVERÁ SER CONFIG P/ TRATAR O VLR DO ITEM SUBTRAÍDO DESTE DESC.'||chr(13) ||
                          'OBS:USADO NA NFE. ESSE PD NÃO É APLICADO QDO DESC SF NA EMPRESA FOR GERA/NÃO GERA',vsPDConsidVlrDescEspecialItem);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'CONSIDERA_DESC_SF_DUPLIC','S','S',
                          'CONSIDERA O DESCONTO RESERVADO NO TÍTULO? '||chr(13) ||
                          '( S ) - SUBTRAI O DESCONTO '||chr(13) ||
                          '( N ) - NÃO MOSTRA O TITULO '||chr(13) ||
                          '( M ) - MOSTRA TITULO SEM DESCONTO '||chr(13) ||
                          'DEFAULT ( S ).',vsPDConsideraDescSFDuplic);
    SP_BUSCAPARAMDINAMICO( 'ROTEIRIZACAO', VNNROEMPRESA,
                           'GERA_SEPARACAO_POR_PEDIDO','S','N',
                           'GERA SEPARAÇÃO POR PEDIDO? (S/N)',vsPDGeraSeparacaoPed );
    SP_BUSCAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'INSCRG_PESFISICA_CONTRIBICMS','S','N',
                           'TRATA PESSOA FÍSICA E CONTRIBUINTE DE ICMS PARA INFORMAR INSCRIÇÃO RG. (S-SIM, N-NAO), PADRÃO N.', vsPDInscRgPesFisicaContribIcms );
    SP_BUSCAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'INSCRG_PESFISICA_PRDRURAL','S','N',
                           'TRATA PESSOA FÍSICA PRODUTOR RURAL E CONTRIBUINTE DE ICMS PARA INFORMAR INSCRIÇÃO RG? (S-SIM, N-NAO), PADRÃO N.  '||chr(13) ||
                           'OBS: QUANDO A PESSOA ESTA CADASTRADA COMO PRODUTOR RURAL NÃO SERÁ VERIFICADO O PD INSCRG_PESFISICA_CONTRIBICMS', vsPDInscRgPesFisicaPrdRural );
    SP_BUSCAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'INSCRG_PESFISICA_TRANSPORTADOR','S','N',
                           'TRATA TRANSPORTADOR PESSOA FÍSICA INFORMAR INSCRIÇÃO RG NA TABELA TMP_M006_TRANSPORTE.M006_NR_IE? (S-SIM, N-NAO), PADRÃO N. '||chr(13) ||
                           'OBS: QUANDO N FAZ VERIFICAR DO TIPO DE FRETE QUANDO S NÃO FAZ ESSA VERIFICAÇÃO', vsPDInscRgPesFisicaTransp );
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'GERA_TABELA_TMP_M011_INFO','S','N',
                          'GERA INFORMAÇÕES DA TABELA TMP_M011_INFO COM BASE NA VIEW DEFINIDA? (N=NÃO GERA\PARA GERAR INFORMAR O NOME DA VIEW) '||
                          'VALOR PADRÃO N.', vsPDGeraTabelaTMPM011Info);
    SP_CHECAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'EMITE_INFO_OBSITEM_DESC','S','N',
                           'EMITE INFORMAÇÕES DA TABELA MLF_NFITEMOBS NA DESCRIÇÃO DO ITEM? (S=SIM/N=NÃO (VALOR PADRÃO))' );
    SP_CHECAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'GERA_INFO_TRANSPORTADOR','S','F',
                           'GERA INFORMAÇÕES DO TRANSPORTADOR(TMP_M006_TRANSPORTE)?'||chr(13) ||
                           'T-NA ORDEM DE FRETE TERCEIRIZADO, FRETE TRANSPORTADOR, TIPO DE FRETE CIF/FOB.'||chr(13) ||
                           'C-SOMENTE TERCEIRIZADO.'||chr(13) ||
                           'R-SOMENTE TRANSPORTADOR.'||chr(13) ||
                           'F-CIF/FOB PD(EMITE_TRANSPORTADOR_CIF).'||chr(13) ||
                           'VALOR PADRÃO F.');
    SP_BUSCAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'GERA_LOC_ENT_PESSOA_FISICA','S','S',
                           'GERA LOCAL DE ENTREGA(TABELA TMP_M005_LOCAL) PARA PESSOA DESTINATÁRIO DO TIPO FÍSICA? (S=SIM/N=NÃO)'||chr(13) ||
                           'VALOR PADRÃO S.', vsPDGeraLocEntPessoaFisica );
    SP_CHECAPARAMDINAMICO( 'EMISSAO_NF', VNNROEMPRESA,'EMITE_ESPEC_DETALHADA_NF','S','N',
                           'DESEJA QUE SEJA EMITIDA A ESPECIFICAÇÃO DETALHADA DO PRODUTO NA NF? (S=SIM/N=NÃO) (DEFAULT=N)');
    SP_BUSCAPARAMDINAMICO( 'EXPORT_NFE', VNNROEMPRESA,'GERA_VALOR_FRETE_NF_CIF','S','N',
                           'GERA VALOR DE FRETE(PRODUTO FINALIDADE FRETE) NA NOTA MESMO QUANDO FRETE FOR CIF? (S-SIM, N-NAO). VALOR PADRÃO N',vsPDGeraValorFreteNFCif );
    SP_CHECAPARAMDINAMICO('EXPORT_NFE',vnNroEmpresa,'SITUACAO_PIS_ASTERISCO','S','N',
                          'INFORMA QUAL SITUAÇÃO DE PIS SERÁ IMPRESSO ASTERISCO JUNTO A DESCRIÇÃO DO PRODUTO?'||chr(13)||
                          'N-NÃO USA, SOMENTE TRATAMENTO ANTIGO(INDISENTOPIS DEFINIDO NA FAMÍLIA)'||chr(13)||
                          'OBS:PD DEPENDE DO PD EMITE_ASTER_DESCPROD_PISCOFINS.'||chr(13)||
                          'OBS2:SEPARAR POR VÍRGULA AS SITUAÇÕES.');
    SP_CHECAPARAMDINAMICO('EXPORT_NFE',vnNroEmpresa,'SITUACAO_COFINS_ASTERISCO','S','N',
                          'INFORMA QUAL SITUAÇÃO DE COFINS SERÁ IMPRESSO ASTERISCO JUNTO A DESCRIÇÃO DO PRODUTO?'||chr(13)||
                          'N-NÃO USA, SOMENTE TRATAMENTO ANTIGO(INDISENTOPIS DEFINIDO NA FAMÍLIA)'||chr(13)||
                          'OBS:PD DEPENDE DO PD EMITE_ASTER_DESCPROD_PISCOFINS.'||chr(13)||
                          'OBS2:SEPARAR POR VÍRGULA AS SITUAÇÕES.');
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCCOMERC_DUPLIC','S','N',
                          'DEDUZ O DESCONTO COMERCIAL NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescComercDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_VLRINDENIZACAO_DUPLIC','S','N',
                          'DEDUZ O VALOR DA INDENIZAÇÃO NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzVlrIndenizacaoDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCFUNRURAL_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE FUNRURAL NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescFunRuralDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCICMS_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE ICMS NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescIcmsDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCPIS_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE PIS NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescPisDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCCOFINS_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE COFINS NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescCofinsDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCCSLL_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE CSLL NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescCSLLDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCIR_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE IR NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescIRDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCINSS_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE INSS NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescINSSDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCISS_DUPLIC','S','N',
                          'DEDUZ O DESCONTO DE ISS NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescISSDuplic);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'DEDUZ_DESCFINANC_DUPLIC','S','N',
                          'DEDUZ O DESCONTO FINANCEIRO NO TÍTULO?'||chr(13)||
                          '( S ) - SIM'||chr(13)||
                          '( N ) - NÃO'||chr(13)||
                          'DEFAULT ( N ).',vsPDDeduzDescFinancDuplic);
    SP_CHECAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA,'GERA_FIXO_CODEAN_NFE','S','N',
                          'GERAR FIXO UM CÓDIGO EAN DO PRODUTO NA INTEGRAÇÃO COM NFe ? ( S/N ). VALOR PADRÃO N.');
    SP_BUSCAPARAMDINAMICO('SILLUS_FATURAMENTO', VNNROEMPRESA,'SIT_DESC_COFINS_SUSP_ZFM','S','00',
                          'INFORMA A SITUAÇÃO DE COFINS A SER GERADA QUANDO O CLIENTE FOR SUSPENSO DE COFINS E RESIDIR NA ZFM?
                          00- MANTEM A SITUAÇÃO ATUAL. VALOR PADRÃO 00.',vsPD_SitDescCofinsSuspZFM);
    SP_BUSCAPARAMDINAMICO('SILLUS_FATURAMENTO', VNNROEMPRESA,'SIT_DESC_COFINS_SUSP_ZFM','S','00',
                          'INFORMA A SITUAÇÃO DE PIS A SER GERADA QUANDO O CLIENTE FOR SUSPENSO DE PIS E RESIDIR NA ZFM?
                          00- MANTEM A SITUAÇÃO ATUAL. VALOR PADRÃO 00.',vsPD_SitDescPisSuspZFM);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'INFO_MARCA_VOLUME','S','N',
                         'INFORME O TEXTO QUE DEVERÁ SER PASSADO PARA INFORMAÇÃO REFERENTE A '||
                         'MARCA DE VOLUME. VALOR PADRÃO: N (NÃO EMITE O TEXTO).', vsPD_InfoMarcaVolume);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'INFO_NUM_VOLUME','S','N',
                         'INFORME O TEXTO QUE DEVERÁ SER PASSADO PARA INFORMAÇÃO REFERENTE A '||
                         'NUMERAÇÃO DE VOLUME. VALOR PADRÃO: N (NÃO EMITE O TEXTO).',vsPD_InfoNumVolume);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'USU_EMITIU_PDV','S','0',
                         'INFORMAR O USUÁRIO PADRÃO PARA EMISSÃO DE NOTA NO PDV?'||chr(13)||'
                         VALOR PADRÃO 0'||chr(13)||'
                         OBS: INFORMAR 0(ZERO) PARA NÃO UTILIZA. PD APENAS PARA PDV CONSINCO',vsPDUsuEmitiuPDV);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'GERA_DUPLICATA_NFE','S','S',
                          'GERA INFORMAÇÕES NA TABELA TMP_M004_DUPLICATA'||chr(13)||'
                          ( S ) - SIM'||chr(13)||'
                          ( N ) - NÃO'||chr(13)||'
                          ( C ) - SIM E TRATA EXCEÇÃO DE CGO(PARÂMETRO: CGO_GERA_DUPLICATA_NFE)'||chr(13)||'
                          DEFAULT ( S ).', vsPDGeraDuplicata);
   SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'CGO_NAO_GERA_DUPLICATA_NFE','S','',
                          'LISTA DE CGO QUE NÃO VÃO GERAR DUPLICATA PARA NFE.'||chr(13)||chr(10)||'
                          OBS: DEPENDE DO PARÂMETRO DINÂMICO "GERA_DUPLICATA_NFE".'||chr(13)||chr(10)||'
                          INFORMAR SEPARADO POR VÍRGULA.', vsPDCgo_N_GeraDuplicataNfe);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'TIP_GERA_CARTAO_DANFE','S','C',
                          'TIPO GERAÇÃO VENCIMENTO CARTÃO DE CRÉDITO E DÉBITO NA DANFE?'||chr(13)||'
                          C-RESPEITA O VENCIMENTO DA CONDIÇÃO DE PAGAMENTO(PADRÃO)' ||chr(13)||'
                          A-GERA APENAS UMA PARCELA AVISTA', vsPDTipGeraCartaoDanfe);
    SP_CHECAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'ENVIA_EMAIL_TRANSP','S','N',
                          'ENVIA E-MAIL COM XML/PDF DA NF-E PARA O TRANSPORTADOR QUANDO ELE FOR INFORMADO NA NOTA E TIVER E-MAIL EM SEU CADASTRO DE PESSOA?' || chr(13) || chr(10) ||
                          'S=SIM' || chr(13) || chr(10) ||
                          'F=APENAS QUANDO O FRETE FOR FOB' || chr(13) || chr(10) ||
                          'C=APENAS QUANDO O FRETE FOR CIF' || chr(13) || chr(10) ||
                          'R=TRANSPORTADOR REDESPACHO' || chr(13) || chr(10) ||
                          'N=NÃO(PADRÃO)');
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'EMITE_FRETE_DOCTRANSP', 'S', 'N',
                          'EMITE VALOR DE FRETE GERADO NO MÓDULO DOCUMENTOS DE TRANSPORTE, NOS DADOS ADICIONAIS DA NOTA?' || CHR(13) || CHR(10) ||
                          'S - SIM' || CHR(13) || CHR(10) ||
                          'N - NÃO (VALOR PADRÃO)' || CHR(13) || CHR(10) ||
                          'OBS: QDO UTILIZADO ESSE PD O VALOR DE FRETE NÃO VAI COMPOR O TOTAL DA NOTA.', vsPDEmiteFreteDocTransp);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',VNNROEMPRESA,'GERA_FRETE_TIPO_ENTREGA_PED','S','N',
                          'GERA INDICADOR FRETE POR CONTA DA NFE CONFORME TIPO DE ENTREGA DO PEDIDO DE VENDA? (S-SIM/N-NÃO(PADRÃO))
                          OBS: ENTREGA: GERAR FRETE POR CONTA DO EMITENTE,
                          RETIRA: GERAR FRETE POR CONTA DO DESTINATÁRIO/REMETENTE', vsGeraFreteTipoEntrega);
    SP_CHECAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA,'GERA_REG_TOT_IMP_NFE','S','S',
                          'GERA REGISTROS TOTAL DE IMPOSTOS DOS PRODUTOS(LEI NRO 12.741) NA NFE?' || chr(13) || chr(10) ||
                          'S-SIM, VERIFICANDO REGRAS DO CGO E CONTRIBUINTE(PADRÃO).' ||chr(13) || chr(10) ||
                          'N-NÃO GERA.' ||chr(13) || chr(10) ||
                          'C-APENAS NÃO CONTRIBUINTES.' ||chr(13) || chr(10) ||
                          'O-APENAS CONTRIBUINTES.' ||chr(13) || chr(10) ||
                          'E-GERAR SEMPRE SEM VERIFICAR REGRA.');
    SP_CHECAPARAMETROOBSNF(VNNROEMPRESA);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'TIPO_NF_EMISSAO_VOLUME', 'S', 'T',
                          'INDICA O TIPO DE NF PARA EMISSÃO DE VOLUMES NA DANFE.' || chr(13) || chr(10) ||
                          'T-TODAS AS NOTAS(PADRÃO)' ||chr(13) || chr(10) ||
                          'I-SOMENTE NOTAS DE IMPORTAÇÃO', vsPDTipoNFEmissaoVolume );
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'GERA_FCI', 'S', 'N',
                          'GERA INFORMAÇÃO DA FCI NO ITEM?' || CHR(13) || CHR(10)  ||
                          'N-NÃO GERA(PADRÃO).' || CHR(13) || CHR(10)  ||
                          'S-GERA NA INF. ADIC. DO ITEM SOMENTE O NRO DA FCI.' || CHR(13) || CHR(10) ||
                          'P-GERA NA INF. ADIC. DO ITEM O NRO DA FCI E PERC.' || CHR(13) || CHR(10) ||
                          'D-NO CAMPO PRÓPRIO DA FCI. ESSA OPÇÃO ESTA DISPONÍVEL PARA NDDIGITAL VERSÃO 4.3.2.0 OU SUPERIOR.', vsPDGeraFCI);
    SP_CHECAPARAMETROOBSNF(VNNROEMPRESA);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'EMITE_INFO_LOTE_PROD', 'S', 'N',
                          'EMITE INFORMAÇÕES DO LOTE DO PRODUTO NAS OBSERVAÇÕES DO ITEM?' || chr(13) || chr(10) ||
                          'S-SIM' ||chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO).', vsPDEmiteInfoLoteProd);
    SP_BUSCAPARAMDINAMICO( 'RECEBTO_NF', 0, 'CONCAT_NFREF_OBS_NF', 'S', 'N',
                           'CONCATENA DESCRIÇÃO DA NOTA FISCAL DE REFERÊNCIA NA OBSERVAÇÃO DA NF DE SAÍDA? VALORES:(S-SIM/N-NÃO(VALOR PADRÃO))', vsPD_ConcatNfRefObsNF );
    SP_CHECAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'EMITE_DADOS_BOLETO', 'S', 'N',
                          'EMITE DADOS DO BOLETO BANCARIO NOS DADOS ADICIONAIS DA NOTA?' || chr(13) || chr(10) ||
                          'S-SIM.' || chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO).');
    SP_BUSCAPARAMDINAMICO('REGRA_INCENTIVO', 0, 'USA_PERC_DESC_DANFE', 'S', 'N',
                         'PERMITE INFORMAR SE A REGRA CADASTRADA IRÁ MOSTRAR O PERCENTUAL DE DESCONTO NA DANFE?' || CHR(13) || CHR(10) ||
                         'OBS: PARA O FUNCIONAMENTO TOTAL DO RECURSO A DANFE DEVE SER CUSTOMIZADA JUNTO COM A NDD.' || CHR(13) || CHR(10) ||
                         'S-SIM' || CHR(13) || CHR(10) ||
                         'N-NÃO(PADRÃO)', vsPDUsaPercDescDANFE);
   SP_BUSCAPARAMDINAMICO('EXPORT_NFE', VNNROEMPRESA, 'FORMA_PAGTO_NAO_GERA_FATURA', 'S', '',
                         ' INFORMAR AS FORMAS DE PAGAMENTO QUE NÃO PERMITIRÃO GERAR INFORMAÇÕES DE FATURA.' ||
                          CHR(13) || CHR(10) || 'OBS: SEPARAR POR VÍRGULA.', vsPDFormaPagtoNaoGeraFatura );
    vsPDVersaoXml := fc5maxparametro('EXPORT_NFE', VNNROEMPRESA, 'VERSAO_XML');
    vsPD_SomaVlrFECPAcrescimo:= nvl(fc5maxparametro('FAT_CARGA', VNNROEMPRESA, 'SOMA_VLR_FECP_ACRESCIMO'), 'S');
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE',0,'LISTA_CFOP_ESTORNO_PISCOF','S','0',
                          'INFORMA QUAL CFOP SERÁ UTILIZADO PARA DETERMINAR SE AS INFORMAÇÕES DE PIS/COFINS SERÃO GERADAS NA DANFE? '||chr(13)||
                          '0-NÃO REALIZA CONSISTÊNCIA COM NENHUM CFOP '||chr(13)||
                          'OBS:AS INFORMAÇÕES DE PIS/COFINS SERÃO GERADAS NOS DADOS ADICIONAIS '||chr(13)||
                          'OBS2:SEPARAR POR VÍRGULA OS CFOPS', vsPD_ListaCfopEstPisCof);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0,'EXIBE_SEQ_TRANSPORT_DANFE','S','N',
                          'EXIBE O SEQUENCIAL DO TRANSPORTADOR CONCATENADO À DIREITA DE SUA RAZÃO SOCIAL NA DANFE?'||chr(13)||chr(10)||
                          'S - SIM'||chr(13)||chr(10)||
                          'N - NÃO(PADRÃO)', vsPDExibeSeqTransportDanfe);
    SP_BUSCAPARAMDINAMICO('RECEBTO_NF', 0,'CONSID_ORIGEM_MERCADORIA_NFREF','S','N',
                          'INDICA SE CONSIDERA A ORIGEM DA MERCADORIA DA NOTA DE REFERÊNCIA AO EMITIR NOTA DE DEVOLUÇÃO AO FORNECEDOR.'||chr(13)||chr(10)||
                          'VALORES:'||chr(13)||chr(10)||
                          'N-NÃO(PADRÃO)'||chr(13)||chr(10)||
                          'S-SIM', vsPD_ConsOrigemMercNfRef);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa,'GERA_CEST_GENERICO','S','N',
                          'GERA CEST GENERICO.'|| chr(13) || chr(10) ||
                          'S-SIM' ||chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO)', vsPDGeraCestGenerico);
    SP_CHECAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa, 'EMITE_OBS_IMPOSTO_RETIDO_SP', 'S', 'N',
                          'EMITE NOS DADOS ADICIONAIS DA DANFE O PRODUTO E VALOR DA PARCELA DO IMPOSTO RETIDO COBRÁVEL DO DESTINATÁRIO EM OPERAÇÕES DESTINADAS AO TERRITÓRIO PAULISTA.' || chr(13) || chr(10) ||
                          'S-SIM' || chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO)');
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa,'EMITE_OBS_IMPOSTO_RETIDO_SP', 'S', 'N',
                          'EMITE NOS DADOS ADICIONAIS DA DANFE O PRODUTO E VALOR DA PARCELA DO IMPOSTO RETIDO COBRÁVEL DO DESTINATÁRIO EM OPERAÇÕES DESTINADAS AO TERRITÓRIO PAULISTA.' || chr(13) || chr(10) ||
                          'S-SIM' || chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO)', vsPDEmiteObsImpostoRetidoSP);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa,'CONSISTE_DETPAGTO_TPINTEGRA', 'S', 'N',
                          'INFORMA O DETALHAMENTO DA FORMA DE PAGAMENTO PARA CARTÃO DE CRÉDITO/DÉBITO PARA VALORES OBTIDOS PELO PDV E/OU ECOMMERCE.' || CHR(13) || CHR(10) ||
                          'OBS: SOMENTE CASO O DOCUMENTO TENHA OS DADOS DE CNPJ DA INSTITUIÇÃO DE PAGAMENTO PREENCHIDOS.' || CHR(13) || CHR(10) ||
                          'S-SIM' || CHR(13) || CHR(10) ||
                          'N-NÃO(PADRÃO)', vsPDConsisteDetPagtoTpIntegra);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa,'UTIL_TRIB_UF_DESONERADO', 'S', 'G',
                          'INFORMA SE O CODIGO DO MOTIVO ICMS DESONERADO ENVIADO SERÁ O CONFIGURADO NA TRIBUTAÇÃO POR UF, OU GERADO PELO SISTEMA' || CHR(13) || CHR(10) ||
                          'T-TRIBUTAÇÂO POR UF' || CHR(13) || CHR(10) ||
                          'G-GERADO PELO SISTEMA(PADRÃO)', vsPDUtilTribUFMotDesonerado);
    vdPDGeraTagMed:= '31/12/2050';
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa,'DTA_INI_TAGMED', 'D', vdPDGeraTagMed,
                          'DATA PARA INÍCIO DA REGRA K01-10 - MEDICAMENTOS - NCMs QUE COMEÇAM COM 3001, 3002, 3003, 3004, 3005 E 3006 REFERNETE A NT2021-004.' || CHR(13) || CHR(10) ||
                          '31/12/2050 - (PADRÃO)', vdPDGeraTagMed);
    vsPDConsInfSeloIpi := fc5maxparametro('PED_VENDA', vnNroEmpresa, 'CONS_INF_SELOIPI');
    vsPDTrocaCstPisCfXml := 'N';
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa, 'TROCA_CST_PIS_COFINS_XML', 'S', 'N',
                          'TROCA A CST DE PIS E COFINS NAS NOTAS DE TRANSFERENCIA (08 Para 49) E BONIFICAÇÃO (74 PARA 98).' || chr(13) || chr(10) ||
                          'OBS: AS CST DE PIS E COFINS SERÃO TROCADAS SOMENTE QUANDO O ITEM NÃO POSSUIR VALOR DE PIS E COFINS' || chr(13) || chr(10) ||
                          'OBS2: AS CST SERÃO TROCADAS SOMENTE QUANDO NÃO ESTIVEREM COM VALOR DE CST FIXO NO CGO' || chr(13) || chr(10) ||
                          'S-SIM' || chr(13) || chr(10) ||
                          'N-NÃO(PADRÃO)', vsPDTrocaCstPisCfXml);
    vsPDSubtraiICMSDesonTotItem := 'S';
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', vnNroEmpresa, 'SUBTRAI_ICMSDESON_TOTITEM', 'S', 'S',
                          'SUBTRAI VALOR DE ICMS DESONERADO DO VALOR TOTAL DO ITEM AO EMITIR UMA NFE?' || chr(13) || chr(10) ||
                          'S-SIM(PADRÃO)' || chr(13) || chr(10) ||
                          'N-NÃO',vsPDSubtraiICMSDesonTotItem);
    SP_BUSCAPARAMDINAMICO('DECLARACAO_IMPORT', 0, 'CALC_BASE_ICMS_AFRMM', 'S', 'N',
                          'CONSIDERA O VALOR AFRMM NA BASE DE CÁLCULO DO ICMS QUANDO A VIA DE TRANSPORTE INTERNACIONAL FOR "MARÍTIMA"? VALORES:(S-SIM/N-NÃO(PADRÃO))',
                          vsPDCalcBaseIcmsAFRMM);
    SP_BUSCAPARAMDINAMICO('EXPORT_NFE', 0, 'CONSID_IMP_VLROUTRAS', 'S', 'T',
                          'CONSIDERA OS IMPOSTOS PIS, COFINS, VALOR DE IMPORTAÇÃO E AFRMM PARA A GERAÇÃO DO VALOR OUTRAS E VALOR OUTRAS DESPESAS' || chr(13) || chr(10) ||
                          'PARA TODAS AS NOTAS DO PROCESSO DE IMPORTAÇÃO?' || chr(13) || chr(10) ||
                          'T-TODAS AS NOTAS (PADRÃO)' || chr(13) || chr(10) ||
                          'M-SOMENTE NOTA MÃE' || chr(13) || chr(10) ||
                          'N-NENHUMA',
                          vsPDConsid_Imp_VlrOutras);
    vsIndConsideraImposto := PKG_CCTMOTOR.CCTF_BUSCACONFIGPAINEL(vnNroEmpresa);
    if  psSoftwarePDV = 'OPHOSNFE' and vsPDVersaoXml IN ( '3', '4')  then
        vsSoftwarePDV := 'NDDIGITAL';
    else
         vsSoftwarePDV := psSoftwarePDV;
    end if;
    select max(A.APPORIGEM), max(decode(a.tipdocfiscal, 'D', a.nroregtributacao)),
           max(a.modelodf)
    into   vnAppOrigem, vnNroRegTribDevol,
           vsModeloDF
    from   MFLV_BASENF A
    where  A.SEQNOTAFISCAL = pnSeqNotaFiscal
    and    a.tipuso != 'R';
    if  vnAppOrigem = 7 and
        vsPDUsuEmitiuPDV != '0' then
        vsUsuEmitiuPDV := vsPDUsuEmitiuPDV;
    else
        vsUsuEmitiuPDV := NULL;
    end if;
    SELECT DECODE(A.INDGERADESCSF, 'C', vsPDConsidVlrDescEspecialItem, 'N') IND
    INTO   vsPDConsidVlrDescEspecialItem
    FROM   MAD_PARAMETRO A
    WHERE  A.NROEMPRESA = VNNROEMPRESA;
    if vsSoftwarePDV =  'OPHOSNFE' then
       SELECT MAX(A.USUEMITIU)
       INTO   vsUsuEmitiuNFe
       FROM   MFLV_BASENF A
       WHERE  A.SEQNOTAFISCAL = pnSeqNotaFiscal  AND
              A.tipuso != 'R';
      vnUsuPainel :=  nvl(fRetornaUsuarioOphos(nvl(vsUsuEmitiuNFe, vsUsuEmitiuPDV), VNNROEMPRESA),0) ;
      if vnUsuPainel > 0 then
         vnCount := 0;
      else
         vnCount := 1;
      end if;
    else
       vnCount := 0;
    end if;
    If vnCount > 0 Then
      SP_GRAVALOGDOCELETRONICO('NFE', pnSeqNotaFiscal, 'Usuário de emissão da nota não está configurado no software OPHOS');
      UPDATE MLF_NOTAFISCAL
      SET    STATUSNFE = 99
      WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
      UPDATE MFL_DOCTOFISCAL
      SET    STATUSNFE = 99
      WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
    Elsif vsModeloDF = '65' then
      SP_GRAVALOGDOCELETRONICO('NFE', pnSeqNotaFiscal, 'Não é possível gerar NF-e de Nota Fiscal de Consumidor Eletrônica(NFC-e).');
    Else
      SELECT NVL(A.INDEMITEICMS, 'N'), NVL(A.INDEMITEICMSST, 'N'),
             NVL(A.INDVLRIPIDADOADICIONAL, 'N'), B.seqpessoa,
             B.INDSUSPPISCOFINS, b.tipnotafiscal,
             a.tipuso, nvl(b.seqauxnotafiscal,0), b.tipofrete,
             NVL(A.INDGERIPIDEVXML, 'N'),
             NVL(B.INDNFINTEGRAFISCAL,0),
             A.TIPDOCFISCAL,
             NVL(A.INDIMPORTEXPORT,'N'),
             A.TIPOFINALIDADENFE,
             B.INDTIPONFCREDITODEBITODET
      INTO   vsIndEmiteIcms, vsIndEmiteIcmsSt,
             vsIndVlrIpiDadoAdic, vnSeqPessoaNota,
             vsIndSuspPisCofins, vsTipNotaFiscal,
             vsTipUso, vnSeqAuxNotaFiscal, vsTipoFrete,
             vsIndGeraIPIDevXML,
             vnIndNFIntegraFiscal,
             vsTipdocfiscal,
             vsIndImportExport,
             vnIndTipoFinalidadeNfe,
             vnIndTipoNfCreditoDebitodet
      FROM   MAX_CODGERALOPER A, MFLV_BASENF B
      WHERE  A.CODGERALOPER = B.CODGERALOPER
      AND    B.SEQNOTAFISCAL = pnSeqNotaFiscal
      AND    A.TIPUSO != 'R';
      SELECT NVL(MAX(A.INDEMITESTREFULTENTRADA), 'N')
      INTO   vsIndEmiteSTRefUltEntrada
      FROM   MRL_CLIENTE A
      WHERE  A.SEQPESSOA = vnSeqPessoaNota;
      vnExisteConhecimento:= 0;
      if vsTipNotaFiscal = 'E' and vsTipUso = 'E' and vnSeqAuxNotaFiscal != 0 and vsTipoFrete = 'F' then
         select count(1)
           into vnExisteConhecimento
           from mlf_conhecimentonotas a
          where a.SEQAUXNOTACONHEC = vnSeqAuxNotaFiscal;
      end if;
      if vsTipNotaFiscal = 'E' and vsTipUso = 'E' and vsTipdocfiscal = 'D' and vnAppOrigem in ( 2, 18 ) then
          Select Max(x.Cfop_Dev_Vend_N_Reconhec)
          Into   vnCfop_Dev_Vend_N_Reconhec
          From (
                -- Referência é MFL_DOCTOFISCAL
                Select MAX(  NVL( (SELECT NVL(G.CFOPFORAESTADO, H.CFOPFORAESTADO)
                                     FROM   MAX_CODGERALCFOP H,
                                            MAX_CODGERALCFOPUF G
                                     WHERE  h.codgeraloper            = F.codgeraloper
                                     and    h.nrotributacao           = B.CODTRIBUTACAO
                                     and    h.indcontribicms          = e.indcontribicms
                                     and    g.codgeraloper(+)         = h.codgeraloper
                                     and    g.nrotributacao(+)        = h.nrotributacao
                                     and    g.indcontribicms(+)       = h.indcontribicms
                                     and    g.status(+) = 'A'
                                     and    (g.UF(+) = C.UF or g.UF(+) = 'ZZ')
                                     and    (g.UFEMPRESA(+) = C.UF or g.ufempresa(+) = 'ZZ')
                                     and    (g.NROREGTRIBUTACAO(+) = C.NROREGTRIBUTACAO or g.nroregtributacao(+) is null)),
                                   F.CFOPFORAESTADO )) Cfop_Dev_Vend_N_Reconhec
                From   MLF_NOTAFISCAL      A,
                       MLF_NFITEM          B,
                       MAX_EMPRESA         C,
                       MFL_DOCTOFISCAL     D,
                       GE_PESSOA           E,
                       MAX_CODGERALOPER    F
                Where  A.SEQNOTAFISCAL     = pnSeqNotaFiscal
                And    A.SEQNF             = B.SEQNF
                And    A.NROEMPRESA        = C.NROEMPRESA
                And    A.SEQPESSOA         = C.SEQPESSOAEMP
                And    B.SEQNFREF          = D.SEQNF
                And    A.NROEMPRESA        = D.NROEMPRESA
                And    D.SEQPESSOA         = E.SEQPESSOA
                And    A.CODGERALOPER      = F.CODGERALOPER
                And    C.UF                <> E.UF
                And    E.UF                <> 'EX'
                Union
                -- Referência é MLF_NOTAFISCAL
                Select MAX(  NVL( (SELECT NVL(G.CFOPFORAESTADO, H.CFOPFORAESTADO)
                                     FROM   MAX_CODGERALCFOP H,
                                            MAX_CODGERALCFOPUF G
                                     WHERE  h.codgeraloper            = F.codgeraloper
                                     and    h.nrotributacao           = B.CODTRIBUTACAO
                                     and    h.indcontribicms          = e.indcontribicms
                                     and    g.codgeraloper(+)         = h.codgeraloper
                                     and    g.nrotributacao(+)        = h.nrotributacao
                                     and    g.indcontribicms(+)       = h.indcontribicms
                                     and    g.status(+) = 'A'
                                     and    (g.UF(+) = C.UF or g.UF(+) = 'ZZ')
                                     and    (g.UFEMPRESA(+) = C.UF or g.ufempresa(+) = 'ZZ')
                                     and    (g.NROREGTRIBUTACAO(+) = C.NROREGTRIBUTACAO or g.nroregtributacao(+) is null)),
                                   F.CFOPFORAESTADO )) Cfop_Dev_Vend_N_Reconhec
                From   MLF_NOTAFISCAL      A,
                       MLF_NFITEM          B,
                       MAX_EMPRESA         C,
                       MLF_NOTAFISCAL      D,
                       GE_PESSOA           E,
                       MAX_CODGERALOPER    F
                Where  A.SEQNOTAFISCAL     = pnSeqNotaFiscal
                And    A.SEQNF             = B.SEQNF
                And    A.NROEMPRESA        = C.NROEMPRESA
                And    A.SEQPESSOA         = C.SEQPESSOAEMP
                And    B.SEQNFREF          = D.SEQNF
                And    A.NROEMPRESA        = D.NROEMPRESA
                And    D.SEQPESSOA         = E.SEQPESSOA
                And    A.CODGERALOPER      = F.CODGERALOPER
                And    C.UF                <> E.UF
                And    E.UF                <> 'EX'
          ) x;
      end if;
      vnCountCidadeZFM := 0;
      If vsIndSuspPisCofins = 'S' then
          select count(1)
          into   vnCountCidadeZFM
          from   ge_pessoa a, ge_cidade b
          where  a.seqcidade = b.seqcidade
          and    a.seqpessoa = vnSeqPessoaNota
          and    nvl(b.pertzfmalc, 'N') = 'S';
      end if;
      BEGIN
          select B.tipotabela,
                 nvl(a.indtipoembdanfe, 'N')
          into   vsTipoTabela,
                 vsIndIipoEmbDanfeClie
          from   MRL_CLIENTE A,
                 MFLV_BASENF B
          where  A.SEQPESSOA = B.SEQPESSOA
          and    B.SEQNOTAFISCAL = pnSeqNotaFiscal
          AND    B.tipuso != 'R';
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
             vsIndIipoEmbDanfeClie     := 'N';
          WHEN OTHERS THEN
             vsIndIipoEmbDanfeClie     := 'N';
      END;
      begin
        select (case
                   when RFF_BuscaRegimeTribut(vnNroEmpresa, to_number(to_char(sysdate, 'MM')), to_number(to_char(sysdate, 'YYYY'))) = 1 then 2
                   when RFF_BuscaRegimeTribut(vnNroEmpresa, to_number(to_char(sysdate, 'MM')), to_number(to_char(sysdate, 'YYYY'))) = 4 then 0
                   when RFF_BuscaRegimeTribut(vnNroEmpresa, to_number(to_char(sysdate, 'MM')), to_number(to_char(sysdate, 'YYYY'))) = 5 then 1
                   when RFF_BuscaRegimeTribut(vnNroEmpresa, to_number(to_char(sysdate, 'MM')), to_number(to_char(sysdate, 'YYYY'))) = 7 then 3
                   else 2
                 end)
        into   vnRegimeTribut
        from   DUAL;
      exception
        when no_data_found then
          vnRegimeTribut := 2;
      end;
      begin
        select A.INDCONVEMBALAGEM
        into   vsIndConvEmbalagem
        from   MRL_CARGAEXPED A,
               MFLV_BASENF B
        where  A.NROCARGA = B.NROCARGA
        and    B.SEQNOTAFISCAL = pnSeqNotaFiscal
        AND    B.tipuso != 'R';
      exception
        when no_data_found then
          vsIndConvEmbalagem := null;
      end;
      if  vsSoftwarePDV = 'OPHOSNFE' then
          vnSeqM000_ID_NF := fBuscaSeqTmpOphus('TMP_M000_NF') ;
      else
          vnSeqM000_ID_NF := pnSeqNotaFiscal;
          select count(1)
            into vnCountNF
            from TMP_M000_NF N
           where N.M000_ID_NF = vnSeqM000_ID_NF;
          if vnCountNF > 0 then
            PKG_MLF_IMPNFERECEBIMENTO.SP_EXCLUI_TMP(vnSeqM000_ID_NF);
          end if;
      end if;
      if vsTipoTabela = 'D' then
         select (case
                      when nvl(MR.INDGERAITEMLIQDESCCLIE,'E') = 'S' then
                           'S'
                      when nvl(MR.INDGERAITEMLIQDESCCLIE,'E') = 'N' then
                           'N'
                      else
                          vsGERA_ITEM_LIQ_DESC
                end)
         into   vsGERA_ITEM_LIQ_DESC
         from   MRL_CLIENTE MR
         where  MR.SEQPESSOA = vnSeqPessoaNota;
      end if;
      BEGIN
        vsObsPorProduto := NULL;
        SELECT SUBSTR(LISTAGG(DISTINCT obs.descricao, ' - ') WITHIN GROUP (ORDER BY obs.descricao), 1, 1000)
          INTO vsObsPorProduto
          FROM MRL_CADOBSERVACAO obs
          JOIN MRL_CADOBSERVACAOPRODUTO prod ON obs.codobservacao = prod.codobservacao
         WHERE obs.finalidade = 'I'
           AND EXISTS (SELECT 1
                         FROM MFLV_BASEDFITEM item
                        WHERE item.seqnotafiscal = pnSeqNotaFiscal
                          AND item.seqproduto = prod.seqproduto
                          AND item.tipuso = 'E'
                          AND item.tipcgo = 'S'
                          AND item.tipdocfiscal != 'T'
                          AND NVL(item.situacaonfpis, '00') IN ('06', '07')
                          AND (
                               NOT EXISTS (SELECT 1
                                             FROM MRL_CADOBSERVACAOCGO cgo_ref
                                            WHERE cgo_ref.codobservacao = obs.codobservacao)
                               OR
                               EXISTS (SELECT 1
                                         FROM MRL_CADOBSERVACAOCGO cgo_ref
                                        WHERE cgo_ref.codobservacao = obs.codobservacao
                                          AND cgo_ref.cgo = item.codgeraloper)
                              )
                      );
      EXCEPTION
        WHEN OTHERS THEN
          vsObsPorProduto := NULL;
      END;
      INSERT INTO TMP_M000_NF(
              M000_ID_NF, M000_VL_RET_PREV, M000_VL_TOTAL_II,
              M000_DS_NAT_OPER, M000_DS_UF_EMBARQUE, M000_NR_MODELO,
              M000_DS_LOCAL_EMBARQUE, M000_NR_DOCUMENTO, M000_DS_NF_EMPENHO,
              M000_DM_IMPRESSA,
              M000_DS_PEDIDO,
              M000_DT_ENTRADA_SAIDA,
              M000_DS_CONTRATO,
              M000_DS_INFO_FISCO,
              M000_DS_INFO_CONTRIB,
              M000_DM_ST_PROC, M000_DM_FMT_DANFE, M000_NR_IBGE_MUN_FG,
              M000_DM_AMB_SIS,
              M000_VL_ICMS,
              M000_DM_FIN_EM,
              M000_VL_ICMS_ST, M000_VL_FRETE, M000_VL_DESCONTO,
              M000_VL_PIS,
              M000_VL_OUTROS,
              M000_VL_SERV,
              M000_VL_ISS, M000_VL_COFINS_ISS, M000_VL_RET_PIS,
              M000_VL_IRRF, M000_VL_BC_RET_PREV, M000_DM_FORMA_PAGAMENTO,
              M000_NR_REF_SIS, M000_DM_ENTRADA_SAIDA, M000_DM_FORMA_EMISSAO,
              M000_DT_EMIT_CONT,
              M000_VL_BC_ICMS,
              M000_VL_RET_CSLL,
              M000_VL_BC_IRRF, M000_VL_RET_IRRF,
              M000_VL_SEGURO, M000_VL_RET_COFINS,
              M000_VL_COFINS,
              M000_VL_BC_ISS, M000_NR_SERIE,
              M000_VL_PROD, M000_DT_EMISSAO, M000_VL_NF,
              M000_VL_IPI, M000_VL_PIS_ISS,
              M000_VL_BC_ICMS_ST,
              S002_ID_USUARIO_E, M000_NR_CARGA,
              NRODECLARAIMPORTc5, DTAREGISTRODIc5, LOCALDESEMBARACODIc5,
              UFDESEMBARACODIc5, DTADESEMBARACODIc5, CODEXPORTADORc5,
              M000_DS_EMAIL_ALT, NROCARGAEXP_NFRET,
              UFCLIENTEC5,
              M000_VL_TOTTRIB,
              UFDESTINOC5,
              M000_MOTIVO_DES_ICMS,
              VLRDESCSUFRAMA,
              VLRDESCICMS,
              M000_VLRFCPUFDEST, M000_VLRICMSUFDEST, M000_VLRICMSUFREMET,
              M000_INDFINAL,
              M000_INDPAG,
              INDPRESENCA,
              M000_INDINTERMED,
              M000_CNPJ_INTERMED,
              M000_NOME_INTERMED,
              NROFORMAPAGTO,
              m000_vl_icms_des,
              CFOP_DEV_VEND_N_RECONHEC,
              M000_NR_CHAVE_ACESSO,
              M000_VL_BC_ICMS_MONO_RET,
              M000_VL_ICMS_MONO_RET,
              --Reforma
              M000_NR_IBGE_MUN_FG_IBS,
              M000_TP_INDNOTADEBITO,
              M000_TP_INDNOTACREDITO,
              M000_TP_INDENTEGOV,
              M000_PER_REDALIQCGOV,
              M000_TP_INDOPERGOV,
              M000_DS_CHAVEACESSOREFPAGANTECIP,
              M000_VL_VLRIMPOSTOIS,
              M000_VL_VLRBASEIBSUF,
              M000_VL_VLRBASEIBSMUN,
              M000_VL_VLRBASECBS,
              M000_VL_VLRIMPOSTOIBS,
              M000_VL_VLRCCREDPRESIBSUF,
              M000_VL_VLRCCREDPRESCONDSUSIBSUF,
              M000_VL_VLRDIFERIDOIBSUF,
              M000_VL_VLRDEVTRIBIBSUF,
              M000_VL_VLRIMPOSTOIBSUF,
              M000_VL_VLRDIFERIDOIBSMUN,
              M000_VL_VLRDEVTRIBIBSMUN,
              M000_VL_VLRIMPOSTOIBSMUN,
              M000_VL_VLRDIFERIDOCBS,
              M000_VL_VLRDEVTRIBCBS,
              M000_VL_VLRIMPOSTOCBS,
              M000_VL_VLRCCREDPRESCBS,
              M000_VL_VLRCCREDPRESCONDSUSCBS,
              M000_VL_VLRIMPOSTOMONOIBS,
              M000_VL_VLRIMPOSTOMONOCBS,
              M000_VL_VLRIMPOSTOMONORETENIBS,
              M000_VL_VLRIMPOSTOMONORETENCBS,
              M000_VL_VLRIMPOSTOMONORETIBS,
              M000_VL_VLRIMPOSTOMONORETCBS,
              M000_VL_NFTOT,
              M000_VL_VLRIMPOSTOESTORNOIBS,
              M000_VL_VLRIMPOSTOESTORNOCBS)
      SELECT  vnSeqM000_ID_NF as M000_ID_NF,
              A.VLRDESCINSS as M000_VL_RET_PREV,
              case when a.vlrimpostoimport > 0 then
                   a.vlrimpostoimport
              else
                A.VLRIMPIMPORTEXPORT
              end as M000_VL_TOTAL_II,
              D.DESCRICAONF as M000_DS_NAT_OPER,
              DECODE( E.UF, 'EX', B.ESTADO ,NULL ) as M000_DS_UF_EMBARQUE,
              55 as M000_NR_MODELO,
              DECODE( E.UF, 'EX', B.CIDADE ,NULL ) as M000_DS_LOCAL_EMBARQUE,
              A.NUMERODF as M000_NR_DOCUMENTO,
              NULL as M000_DS_NF_EMPENHO,
              0 AS M000_DM_IMPRESSA,
              fc5_RetNroPedVdaClie_NFe(A.SEQNOTAFISCAL,A.SEQPESSOA,null,null,A.TIPOTABELA,A.nropedidovenda,A.nroempresa) as M000_DS_PEDIDO,
              DECODE( vsPDDataPadraoEmissaoNF,
                        'S', NVL(A.DTAHORSAIDA,A.DTAENTRADA),
                        'D', A.DTAHORSAIDA,
                        'P', case NVL(A.DTAHORSAIDA,A.DTAENTRADA) when TRUNC(NVL(A.DTAHORSAIDA,A.DTAENTRADA)) THEN
                                A.DTAIMPRESSAO
                             else
                               NVL(A.DTAHORSAIDA,A.DTAENTRADA)
                             end,
                        A.DTAENTRADA
              ) as M000_DT_ENTRADA_SAIDA,
              NULL as M000_DS_CONTRATO,
              NVL2(vsObsPorProduto, vsObsPorProduto || '. ', '') ||
                CASE WHEN A.INDNFEAJUSTECANCEL = 'S' AND A.APPORIGEM = 23 THEN
                  TRIM(A.OBSERVACAOLF)
                ELSE
                  CASE WHEN vsPDEmiteObsImpostoRetidoSP = 'S' AND A.UFDESTINO = 'SP' THEN
                    fEmiteObsImpostoRetidoSP(A.codgeraloper, A.seqnotafiscal, vsPDIndGeraRefFabricCodProd, vsUfOrigem)
                  ELSE
                    NULL
                  END
              END -- Alt Giuliano LC 224/2025
              || NAGF_OBSINFOADFISCO(A.SEQNF, A.codgeraloper)
        as M000_DS_INFO_FISCO,
              replace(regexp_replace(TRIM(nvl(a.observacaonfe, fc5_NFEObservacaoNF(a.seqnotafiscal))), ';', '.'), '"', '') as M000_DS_INFO_CONTRIB,
              1 as M000_DM_ST_PROC,
              NULL as M000_DM_FMT_DANFE,
              MUNEMI.CODIBGE as M000_NR_IBGE_MUN_FG,
              NULL as M000_DM_AMB_SIS,
              DECODE(D.INDEMITEICMS, 'A', 0, A.VLRICMSTOTNFE) as M000_VL_ICMS,
              case when vsSoftwarePDV = 'NDDIGITAL' and vsPDVersaoXml in('4') then
                 case when D.TIPOFINALIDADENFE IS NULL THEN
                     case when D.INDNFEAJUSTE = 'S'  then
                           3
                       when D.INDCOMPLVLRIMP = 'S' then
                           2
                       when D.TIPDOCFISCAL = 'D' then
                           Decode(d.trocacomodato,'S',1, 4)
                     else
                           1
                     end
                 ELSE
                     D.TIPOFINALIDADENFE
                 END
              else
                  case when D.Indnfeajuste = 'S' then
                        2
                  else
                        DECODE(D.INDCOMPLVLRIMP,'S',1,0)
                  end
              end as M000_DM_FIN_EM,
              DECODE( D.INDEMITEICMSST,
                        'A', 0,
                        'C', decode(e.indcontribicms, 'N', 0, A.VLRICMSSTTOTNFE),
                        A.VLRICMSSTTOTNFE
              ) as M000_VL_ICMS_ST,
              NVL( case when A.VLRFRETE_MAXTRANSP > 0 and vsPDEmiteFreteDocTransp = 'S' then
                     0
                   else
                     A.VLRFRETE_MAXTRANSP
                   end,
                   DECODE( A.TIPOFRETE,
                             'C', DECODE( vsPDGeraValorFreteNFCif,
                                            'S', case when sign(a.vlrfretetransp) = 1 and a.tipotabela = 'N' then
                                                   a.vlrfretetransp
                                                 else
                                                   DECODE(A.apporigem,'14',NVL(A.VLRFRETENANF,A.VLRFRETEITEMRATEIO),A.VLRFRETEITEMRATEIO)
                                                 end,
                                            DECODE(A.apporigem,'14',NVL(A.VLRFRETENANF,A.VLRFRETEITEMRATEIO),A.VLRFRETEITEMRATEIO)),
                             case when sign(a.vlrfretetransp) = 1 and a.tipotabela = 'N' and vnExisteConhecimento = 0 then
                               a.vlrfretetransp
                             when sign(a.vlrfretetransp) = 1 and a.tipotabela = 'N' and vnExisteConhecimento > 0 then
                               0
                             else
                               nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'F'), 0)
                             end
                   )
              ) as M000_VL_FRETE,
              ( decode( vsGERA_ITEM_LIQ_DESC,
                          'S', DECODE(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl(a.vlrdescsf, 0)),
                          A.VLRDESCONTO - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl(a.vlrdescsf, 0), 0)
                )
                + decode(a.tipotabela, 'D', round(a.VLRDESCINCONDIC, 2), 0)
                - nvl(decode(nvl(vsGERA_ITEM_LIQ_DESC, 'N'), 'N', nvl(a.VLRDESCSUFRAMA, 0) + nvl(a.VLRTOTICMSDESONITEMSUBTRAI, 0)), 0)
                - nvl(a.vlrdescdespesa, 0)
              ) as M000_VL_DESCONTO,
              case when vsPD_SitDescPisSuspZFM = '06' and vnCountCidadeZFM > 0  then
                ROUND(A.VLRPISNFESUSP, 2)
              else
                ROUND(A.VLRPISNFE,2)
              end as M000_VL_PIS,
              ABS(
                DECODE(A.APPORIGEM,'14',(A.VLRDESPTRIBUTITEM-nvl(A.VLRFRETENANF,0)),A.VLRDESPTRIBUTITEM) + A.VLRDESPACESSORIA + A.VLRACRFINANCEIRO
                +
                nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'D'), 0)
                +
                case when A.TIPOTABELA = 'D' and A.INDFATURAICMSANTEC = 'S' then
                  NVL(A.VLRICMSANTECIPADO, 0)
                else
                  0
                end
                +
                NVL(A.VLRDESPNTRIBUTITEM, 0)
                +
                DECODE( D.INDEMITEICMSST,
                          'A', NVL(A.vlricmssttotoutronfe, 0),
                          'C', decode(e.indcontribicms, 'N', NVL(A.vlricmssttotoutronfe, 0), 0),
                          0)
                +
                CASE WHEN vsIndGeraIPIDevXML = 'S' AND vsIndVlrIpiDadoAdic = 'S'
                     AND vsPDVersaoXml =  '4' AND A.TIPDOCFISCAL = 'D' THEN
                       0
                ELSE
                  NVL(A.VLRIPIOBSADC, 0)
                END
                +
                NVL(A.VLRICMSSTTOTOUTROSDESP, 0)
                +
                case when vsTipoDoctoFiscal = 'D' or A.TIPOTABELA = 'D' then
                  NVL(A.VLRFECPTOTOUTRADESPNFE, 0)
                else
                  0
                end
                -
                case when d.tipdocfiscal = 'D' and a.apporigem != 3 then
                  nvl(a.vlrfreteitemrateio, 0)
                else
                  0
                end
                -
                case when d.indimportexport = 'S'
                  and (vsPDConsid_Imp_VlrOutras = 'T' OR ( vsPDConsid_Imp_VlrOutras = 'M' and a.apporigem in (35))) then
                  (nvl(a.vlrpis, 0) + nvl(a.vlrcofins, 0) + nvl(a.vlrimpimportexport, 0))
                else
                  0
                end
                -
                case when d.indimportexport = 'S' and vsPDCalcBaseIcmsAFRMM = 'S'
                  and (vsPDConsid_Imp_VlrOutras = 'T' OR ( vsPDConsid_Imp_VlrOutras = 'M' and a.apporigem in (35))) then
                 nvl(a.vlrafrmm, 0)
                else
                  0
                end
              -- Giuliano 06/05/26
              - 
              CASE WHEN nvl(a.vlrfreteitemrateio, 0) > 0 THEN NAGF_SUBTRAI_DESP_CENT_ECOMM(NVL(A.VLRDESPACESSORIA,0), A.APPORIGEM, A.CODGERALOPER) ELSE 0 END
              --
              ) as M000_VL_OUTROS,
              A.VLRSERVICO as M000_VL_SERV,
              A.VLRISS as M000_VL_ISS,
              ROUND(A.VLRCOFINSISSNFE, 2) as M000_VL_COFINS_ISS,
              ROUND(A.VLRDESCPIS, 2) as M000_VL_RET_PIS,
              A.VLRIR as M000_VL_IRRF,
              DECODE(A.VLRDESCINSS, 0, 0, A.VLRTOTITEM) as M000_VL_BC_RET_PREV,
              decode(nvl(fmrl_VenctoNf(a.numerodf,a.seqpessoa,a.seriedf,a.nroempresa,decode(a.tipnotafiscal,'E','O','D')) - a.dtaemissao, 0), 0, 0, 1) as M000_DM_FORMA_PAGAMENTO,
              A.SEQNOTAFISCAL as M000_NR_REF_SIS,
              DECODE(A.TIPNOTAFISCAL, 'E', 0, 1) as M000_DM_ENTRADA_SAIDA,
              case when vsSoftwarePDV = 'NDDIGITAL' then
                  DECODE(A.SERIEDF, fc5BuscaNFeScan(A.NROEMPRESA, A.NROSEGMENTO, A.CODGERALOPER), 3,  SUBSTR(A.NFECHAVEACESSO, 35, 1))
              else
                  NULL
              end as M000_DM_FORMA_EMISSAO,
              NULL as M000_DT_EMIT_CONT,
              DECODE(D.INDEMITEICMS, 'A', 0, A.BASEICMSTOTNFE) as M000_VL_BC_ICMS,
              A.VLRDESCCSLL as M000_VL_RET_CSLL,
              DECODE(A.VLRDESCIR, 0, 0, A.VLRTOTITEM) as M000_VL_BC_IRRF,
              A.VLRDESCIR as M000_VL_RET_IRRF,
              case when a.vlrseguro > 0 then
                a.vlrseguro
              else
                nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'G'), 0)
              end as M000_VL_SEGURO,
              ROUND(A.VLRDESCCOFINS, 2) as M000_VL_RET_COFINS,
              case when vsPD_SitDescCofinsSuspZFM = '06' and vnCountCidadeZFM > 0 then
                ROUND(A.VLRCOFINSNFESUSP, 2)
              else
                ROUND(A.VLRCOFINSNFE, 2)
              end as M000_VL_COFINS,
              A.VLRBASEISS as M000_VL_BC_ISS,
              TO_NUMBER(NVL(TRIM(A.SERIEDF), 0)) as M000_NR_SERIE,
              ( decode( vsGERA_ITEM_LIQ_DESC,
                          'S', A.VLRITEM
                               -
                               A.VLRDESCONTO
                               +
                               DECODE(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl(a.vlrdescsf, 0))
                               + DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0),
                          A.VLRITEM - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl(a.vlrdescsf, 0), 0)
                )
                -
                case when (A.APPORIGEM = 14 Or (A.APPORIGEM = 2 And D.TIPDOCFISCAL = 'D')) then
                  ( nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'D', 'F', 'N'), 0) +
                    nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'F', 'F', 'N'), 0) +
                    nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'G', 'F', 'N'), 0)
                  )
                else
                  0
                end
                -
                nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'S', 'F', 'N'), 0)
              ) as M000_VL_PROD,
              case when A.APPORIGEM in (23, 18, 2)
                   and A.tipotabela = 'N' then
                      sysdate
                      --to_date(to_char(A.dtaemissao, 'DD-MON-YYYY') || ' ' || trim(to_char(A.DTAHOREMISSAO, 'HH24:MI:ss')), 'DD-MM-YYYY HH24:MI:ss')
              else
                A.DTAHOREMISSAO
              end as M000_DT_EMISSAO,
              ( A.VLRCONTABILSEMFUNRURAL
                +
                decode( vsTipoDoctoFiscal,
                          'D', 0,
                          DECODE( A.TIPOTABELA,
                                    'D', case when vsIndUtilCalcFCP = 'S' then
                                           0
                                         else
                                           DECODE( vsPD_SomaVlrFECPAcrescimo,
                                                     'S', 0,
                                                     NVL(A.VLRFECPTOTOUTRADESPNFE, 0)
                                           )
                                         End,
                                    0)
                )
              ) as M000_VL_NF,
              A.VLRIPI as M000_VL_IPI,
              ROUND(A.VLRPISISSNFE,2) as M000_VL_PIS_ISS,
              DECODE( D.INDEMITEICMSST,
                        'A', 0,
                        'C', decode(E.INDCONTRIBICMS, 'N', 0, A.BASEICMSSTTOTNFE),
                        A.BASEICMSSTTOTNFE
              ) as M000_VL_BC_ICMS_ST,
              vnUsuPainel as S002_ID_USUARIO_E,
              A.NROCARGA as M000_NR_CARGA,
              A.NRODECLARAIMPORT as NRODECLARAIMPORTc5,
              A.DTAREGISTRODI as DTAREGISTRODIc5,
              A.LOCALDESEMBARACODI as LOCALDESEMBARACODIc5,
              A.UFDESEMBARACODI as UFDESEMBARACODIc5,
              A.DTADESEMBARACOADUANEIRODI as DTADESEMBARACODIc5,
              a.seqpessoa as CODEXPORTADORC5,
              ltrim(( nvl( fRetornaEmailNfeTransp( vnNroEmpresa , pnSeqNotaFiscal  ,vsEMITE_TRANSPOR_CIF),
                           ( SELECT NVL(Z.EMAILNFE, Z.EMAIL)
                             FROM   MRL_PEVENDA X,
                                    GE_PESSOA Z
                             WHERE  X.SEQPESSOAREM = Z.SEQPESSOA
                             AND    X.NUMERONF     = A.NUMERODF
                             AND    X.SERIENF      = A.SERIEDF
                             AND    X.NROEMPRESA   = A.NROEMPRESA)
                      )
                      ||
                      ( SELECT decode(EMAILNFEEMP, null, '', ';' || Replace(Replace(Trim(EMAILNFEEMP), Chr(13), Null), Chr(10), Null))
                        FROM   MAX_EMPRESA
                        WHERE  NROEMPRESA = A.nroempresa
                      )
                     ), ';'
              ) as M000_DS_EMAIL_ALT,
              fNroCargaExpedNotaTransf(a.nrocarga, a.nroempresa) as NROCARGAEXP_NFRET,
              case when a.tipnotafiscal = 'E' then
                b.estado
              else
                nvl(a.ufdestino, b.estado)
              end as UFCLIENTEC5,
              A.VLRTOTTRIB AS M000_VL_TOTTRIB,
              NVL(A.UFDESTINO, E.UF) UFDESTINOC5,
              CASE WHEN vsPDUtilTribUFMotDesonerado = 'T' THEN
                A.INDMOTIVODESOICMS
              ELSE
                case when A.VLRDESCSUFRAMA > 0 then
                     7
                when A.VLRDESCICMS > 0 and A.INDCALCICMSDESONOUTROS = 'S' and A.VLRTOTICMSDESONOUTROS > 0 then
                     9
                when A.VLRDESCICMS > 0 then
                     8
                else
                     null
                end
              END as M000_MOTIVO_DES_ICMS,
              A.VLRDESCSUFRAMA,
              A.VLRDESCICMS,
              A.VLRFCP as M000_VLRFCPUFDEST,
              A.VLRICMSCALCDESTINO as M000_VLRICMSUFDEST,
              DECODE(D.TIPDOCFISCAL,'D',0, A.VLRICMSCALCORIGEM) as M000_VLRICMSUFREMET,
              DECODE(NVL(D.INDCONSUMIDORFINAL,A.INDCONSUMIDORFINAL), 'S', 1, 0) as M000_INDFINAL,
              nvl(( select max(1)
                    from   mrl_titulofin c
                    where  c.nroempresa = a.nroempresa
                    and    c.nrodocumento = a.numerodf
                    and    c.seqpessoa = a.seqpessoa
                    and    c.seriedoc =  a.seriedf
                    and    trunc(c.dtavencimento) > trunc(c.dtaemissao)
                  ), 0
              ) M000_INDPAG, -- 0 a vista 1 a prazo
              fc5_BuscaIndPresenca(a.numerodf, a.nroempresa, a.seriedf, a.nroserieecf) AS INDPRESENCA,
              Case When A.CNPJINTERMEDIADOR is not null Then
                        1
                   Else
                        0
              End As M000_INDINTERMED,
              A.CNPJINTERMEDIADOR,
              A.NOMEINTERMEDIADOR,
              A.NROFORMAPAGTO,
              a.vlrtoticmsdesonoutros,
              vnCfop_Dev_Vend_N_Reconhec,
              A.NFECHAVEACESSO,
              A.VLRBCICMSMONORET,
              A.VLRICMSMONORET,
              MUNEMI.CODIBGE AS M000_NR_IBGE_MUN_FG_IBS,
              CASE WHEN D.TIPOFINALIDADENFE = 6 THEN a.indtiponfcreditodebitodet END AS M000_TP_INDNOTADEBITO,
              CASE WHEN D.TIPOFINALIDADENFE = 5 THEN a.indtiponfcreditodebitodet END AS M000_TP_INDNOTACREDITO,
              NULL AS M000_TP_INDENTEGOV,
              NULL AS M000_PER_REDALIQCGOV,
              NULL AS M000_TP_INDOPERGOV,
              NULL AS M000_DS_CHAVEACESSOREFPAGANTECIP,
              A.VLRIMPOSTOIS AS M000_VL_VLRIMPOSTOIS,
              A.VLRBASEIBSUF AS M000_VL_VLRBASEIBSUF,
              A.VLRBASEIBSMUN AS M000_VL_VLRBASEIBSMUN,
              A.VLRBASECBS AS M000_VL_VLRBASECBS,
              A.VLRIMPOSTOIBSUF + A.VLRIMPOSTOIBSMUN AS M000_VL_VLRIMPOSTOIBS,
              A.VLRCCREDPRESIBSUF AS M000_VL_VLRCCREDPRESIBSUF,
              0 AS M000_VL_VLRCCREDPRESCONDSUSIBSUF,
              A.VLRDIFERIDOIBSUF AS M000_VL_VLRDIFERIDOIBSUF,
              0 AS M000_VL_VLRDEVTRIBIBSUF,
              A.VLRIMPOSTOIBSUF AS M000_VL_VLRIMPOSTOIBSUF,
              A.VLRDIFERIDOIBSMUN AS M000_VL_VLRDIFERIDOIBSMUN,
              0 AS M000_VL_VLRDEVTRIBIBSMUN,
              A.VLRIMPOSTOIBSMUN AS M000_VL_VLRIMPOSTOIBSMUN,
              A.VLRDIFERIDOCBS AS M000_VL_VLRDIFERIDOCBS,
              0 AS M000_VL_VLRDEVTRIBCBS,
              A.VLRIMPOSTOCBS AS M000_VL_VLRIMPOSTOCBS,
              A.VLRCCREDPRESCBS AS M000_VL_VLRCCREDPRESCBS,
              0 AS M000_VL_VLRCCREDPRESCONDSUSCBS,
              0 AS M000_VL_VLRIMPOSTOMONOIBS,
              0 AS M000_VL_VLRIMPOSTOMONOCBS,
              0 AS M000_VL_VLRIMPOSTOMONORETENIBS,
              0 AS M000_VL_VLRIMPOSTOMONORETENCBS,
              A.VLRIMPOSTOMONORETIBSUF AS M000_VL_VLRIMPOSTOMONORETIBS,
              A.VLRIMPOSTOMONORETCBS AS M000_VL_VLRIMPOSTOMONORETCBS,
              ( decode( vsGERA_ITEM_LIQ_DESC,
                          'S', A.VLRITEM
                               -
                               A.VLRDESCONTO
                               +
                               DECODE(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl(a.vlrdescsf, 0))
                               + DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0),
                          A.VLRITEM - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl(a.vlrdescsf, 0), 0)
                )
                -
                case when (A.APPORIGEM = 14 Or (A.APPORIGEM = 2 And D.TIPDOCFISCAL = 'D')) then
                  ( nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'D', 'F', 'N'), 0) +
                    nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'F', 'F', 'N'), 0) +
                    nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'G', 'F', 'N'), 0)
                  )
                else
                  0
                end
                -
                nvl(fValorProdFinalidade(a.id_df, a.tipotabela, 'S', 'F', 'N'), 0)
              ) +
              CASE WHEN NVL(vsIndConsideraImposto,'N') = 'S'
                   THEN A.VLRIMPOSTOIS + A.VLRIMPOSTOIBSMUN + A.VLRIMPOSTOIBSUF + A.VLRIMPOSTOCBS
                   ELSE 0
              END AS M000_VL_NFTOT,
              CASE WHEN D.TIPOFINALIDADENFE = 6 AND a.indtiponfcreditodebitodet = 7
                   THEN A.VLRIMPOSTOIBSUF
                   END AS M000_VL_VLRIMPOSTOESTORNOIBS,
              CASE WHEN D.TIPOFINALIDADENFE = 6 AND a.indtiponfcreditodebitodet = 7
                   THEN A.VLRIMPOSTOCBS
                   END AS M000_VL_VLRIMPOSTOESTORNOCBS
      FROM    MFLV_BASENF      A,
              GE_EMPRESA       B,
              MAX_CODGERALOPER D,
              GE_CIDADE        MUNEMI,
              GE_PESSOA        E
      WHERE   A.NROEMPRESA     = B.NROEMPRESA
      AND     A.CODGERALOPER   = D.CODGERALOPER
      AND     B.SEQCIDADE      = MUNEMI.SEQCIDADE
      AND     A.SEQPESSOA      = E.SEQPESSOA
      AND     A.SEQNOTAFISCAL  = pnSeqNotaFiscal
      AND     D.TIPUSO         != 'R';
      IF vsIndGeraHash = 'N' THEN
      UPDATE MLF_NOTAFISCAL
      SET    STATUSNFE = 1
      WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
      UPDATE MFL_DOCTOFISCAL
      SET    STATUSNFE = 1
      WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
      ELSE
         UPDATE MLF_NOTAFISCAL
         SET    STATUSNFE = 27
         WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
         UPDATE MFL_DOCTOFISCAL
         SET    STATUSNFE = 27
         WHERE  SEQNOTAFISCAL = pnSeqNotaFiscal;
      END IF;
      INSERT INTO TMP_M001_EMITENTE(
              M000_ID_NF, M001_DS_BAIRRO, M001_NR_CEP,
              M001_NR_IE, M001_NR_IBGE_MUN,
              M001_NR_IE_ST,
              M001_DS_MUN, M001_NM_FANTASIA, M001_NR_UF,
              M001_NM_LOGRADOURO, M001_DS_UF, M001_NR_CNPJ,
              M001_NR_PAIS,
              M001_NM_RAZAO_SOCIAL,
              M001_DS_PAIS,
              M001_DS_CPL_LOGRADOURO, M001_NR_TELEFONE, M001_NR_LOGRADOURO,
              M001_NR_CNAE, M001_NR_IM,
              M001_DM_CRT)
      SELECT  vnSeqM000_ID_NF as M000_ID_NF,
              REPLACE(B.BAIRRO,';','') as M001_DS_BAIRRO,
              B.CEP as M001_NR_CEP,
              SUBSTR(TRIM(B.INSCRESTADUAL),1,14) as M001_NR_IE,
              G.CODIBGE as M001_NR_IBGE_MUN,
              case when ((vsEmite_IE_ST = 'S') or (vsEmite_IE_ST = 'I' and A.VLRICMSST > 0)) then
                ( select  max(x.inscricao)
                  from    rf_inscruf x,
                          ge_pessoa p
                  where   x.nroempresa  =  a.nroempresa
                  and     x.uf          =  p.uf
                  and     p.seqpessoa   =  a.seqpessoa
                  and     a.dtaemissao  between x.dtainicial and x.dtafinal
                )
              else
                ''
              end as M001_NR_IE_ST,
              REPLACE(B.CIDADE,';','') as M001_DS_MUN,
              REPLACE(B.FANTASIA,';','') as M001_NM_FANTASIA,
              C.CODUF as M001_NR_UF,
              B.ENDERECO as M001_NM_LOGRADOURO,
              B.ESTADO as M001_DS_UF,
              SUBSTR(LPAD(B.NROCGC,12,'0') || LPAD(B.DIGCGC,2,'0'),1,14) as M001_NR_CNPJ,
              G.CODPAIS as M001_NR_PAIS,
              SUBSTR(REPLACE(B.RAZAOSOCIAL,';',''),1,60) as M001_NM_RAZAO_SOCIAL,
              B.PAIS as M001_DS_PAIS,
              REPLACE(B.CMPLTOLOGRADOURO,';','') as M001_DS_CPL_LOGRADOURO,
              SUBSTR(TRIM(B.DDD) || TRIM(B.FONENRO), 1, 14 ) as M001_NR_TELEFONE,
              REPLACE(DECODE(B.ENDERECONRO, NULL, 'S/N', B.ENDERECONRO), ';', '') as M001_NR_LOGRADOURO,
              substr(F.CNAE, 1, 7) as M001_NR_CNAE,
              F.INSCMUNICIPAL as M001_NR_IM,
              vnRegimeTribut as M001_DM_CRT
      FROM    MFLV_BASENF     A,
              GE_EMPRESA      B,
              GEV_UFCODIGO    C,
              GE_CIDADE       G,
              GE_PESSOA       P,
              MAX_EMPRESA     E,
              GE_PESSOA       F
      WHERE   A.NROEMPRESA    = B.NROEMPRESA
      AND     A.nroempresa    = E.NROEMPRESA
      AND     E.SEQPESSOAEMP  = F.SEQPESSOA
      AND     A.seqpessoa     = P.SEQPESSOA
      AND     B.SEQCIDADE     = G.SEQCIDADE
      AND     B.ESTADO        = C.UF
      AND     A.SEQNOTAFISCAL = pnSeqNotaFiscal
      AND     A.tipuso        != 'R';
      -- Type para objeto da customização
      pObjfc5_RazaoSocialCust.cnseqpessoa := vnSeqPessoaNota;
      INSERT INTO TMP_M002_DESTINATARIO(
              M002_NR_CLIENTE,
              M000_ID_NF, M002_NR_IBGE_MUN, M002_DS_MUNICIPIO,
              M002_NR_CNPJ_CPF,
              M002_DS_UF, M002_NM_LOGRADOURO,
              M002_NR_TELEFONE, M002_DS_CPL, M002_NR_PAIS,
              M002_NR_CEP, M002_DS_PAIS, M002_NM_RAZAO_SOCIAL,
              M002_NR_IE, M002_DS_BAIRRO, M002_NR_SUFRAMA,
              M002_NR_LOGRADOURO, M002_DS_EMAIL, EMAILNFEC5, M002_NM_FANTASIA,
              M002_IND_CONTRIB_ICMS,
              M002_NR_PASSAPORTE)
      SELECT  A.SEQPESSOA,
              vnSeqM000_ID_NF as M000_ID_NF,
              G.CODIBGE as M002_NR_IBGE_MUN,
              REPLACE(E.CIDADE,';','') as M002_DS_MUNICIPIO,
              case when A.NFEAMBIENTE = 'H' and vsSoftwarePDV = 'NDDIGITAL' then
                SUBSTR(DECODE(E.FISICAJURIDICA,'F',LPAD(E.NROCGCCPF,9,'0') || LPAD(E.DIGCGCCPF,2,'0'), LPAD(E.NROCGCCPF,12,'0') || LPAD(E.DIGCGCCPF,2,'0')),1,14)
              else
                DECODE( E.UF, 'EX', DECODE(A.NFEAMBIENTE, 'H', NULL, '00000000000000'), DECODE(A.NFEAMBIENTE, 'H','99999999000191', SUBSTR(DECODE(E.FISICAJURIDICA,'F',LPAD(E.NROCGCCPF,9,'0') || LPAD(E.DIGCGCCPF,2,'0'), LPAD(E.NROCGCCPF,12,'0') || LPAD(E.DIGCGCCPF,2,'0')),1,14)))
              end as M002_NR_CNPJ_CPF,
              E.UF as M002_DS_UF,
              E.LOGRADOURO as M002_NM_LOGRADOURO,
              SUBSTR( TRIM(E.FONEDDD1) || TRIM(E.FONENRO1), 1, 14 ) as M002_NR_TELEFONE,
              REPLACE(E.CMPLTOLOGRADOURO,';','') as M002_DS_CPL,
              G.CODPAIS as M002_NR_PAIS,
              E.CEP as M002_NR_CEP,
              E.PAIS as M002_DS_PAIS,
              REPLACE(DECODE( A.NFEAMBIENTE,
                                'H', 'NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL',
                                SUBSTR(DECODE( vsResultado, -- Objeto Customização (Razão Social)
                                                 'S', NVL(fc5_RazaoSocialCust(pObjfc5_RazaoSocialCust), E.NOMERAZAO || ' - ' || A.SEQPESSOA),
                                                 E.NOMERAZAO
                                       ), 1, 60)
                      ),';',''
              ) as M002_NM_RAZAO_SOCIAL,
              case when A.NFEAMBIENTE = 'H' and vsSoftwarePDV != 'NDDIGITAL' then
                null
              else
                case when vsPDVersaoXml in ('4') and E.INDCONTRIBICMS = 'N' then
                  case when SUBSTR(TRIM(E.INSCRICAORG),1,14) is null or (E.Indprodrural = 'S' and vnAppOrigem = 14) then
                    'ISENTO'
                  when nvl(e.indprodrural, 'N') = 'N' and e.fisicajuridica =  'F' then
                    'FISICA'
                  else
                    SUBSTR(TRIM(E.INSCRICAORG), 1, 14)
                  end
                when E.FISICAJURIDICA = 'J' then
                  SUBSTR(TRIM(E.INSCRICAORG),1,14)
                else
                  case when E.INDPRODRURAL   = 'S' and  E.INDCONTRIBICMS = 'S' then
                    DECODE( vsPDInscRgPesFisicaPrdRural,
                              'S', SUBSTR(TRIM(E.INSCRICAORG), 1, 14),
                              'ISENTO')
                  else
                    DECODE( E.INDCONTRIBICMS || vsPDInscRgPesFisicaContribIcms,
                              'SS', SUBSTR(TRIM(E.INSCRICAORG), 1, 14),
                              'ISENTO' )
                  end
                end
              end as M002_NR_IE,
              REPLACE(E.BAIRRO,';','') as M002_DS_BAIRRO,
              E.NROINSCSUFRAMA as M002_NR_SUFRAMA,
              REPLACE(DECODE(E.NROLOGRADOURO,NULL,'S/N',E.NROLOGRADOURO),';','') as M002_NR_LOGRADOURO,
              SUBSTR(CASE
                       WHEN INSTR(NVL(E.EMAILNFE, E.EMAIL), ';', 1, 1) = 0 THEN
                         NVL(E.EMAILNFE, E.EMAIL)
                       ELSE
                         SUBSTR(NVL(E.EMAILNFE, E.EMAIL), 0, INSTR(NVL(E.EMAILNFE, E.EMAIL), ';', 1, 1)-1)
                     END, 0, 60) AS M002_DS_EMAIL,
              NVL(E.EMAILNFE, E.EMAIL) as EMAILNFEC5,
              REPLACE(E.FANTASIA, ';', '') as M002_NM_FANTASIA,
              E.INDCONTRIBICMS as M002_IND_CONTRIB_ICMS,
              E.NROPASSAPORTE as M002_NR_PASSAPORTE
      FROM    MFLV_BASENF     A,
              GE_PESSOA       E,
              GE_CIDADE       G
      WHERE   A.SEQPESSOA     = E.SEQPESSOA
      AND     E.SEQCIDADE     = G.SEQCIDADE
      AND     A.SEQNOTAFISCAL = pnSeqNotaFiscal
      AND     A.tipuso        != 'R';
      INSERT  INTO TMP_M003_FATURA(
              M000_ID_NF,                      M003_VL_ORIGINAL,
              M003_VL_DESCONTO,                M003_NR_FATURA,
              M003_VL_LIQUIDO,                 M003_DS_CPGTO,
              M003_DS_FPGTO)
      SELECT  vnSeqM000_ID_NF as M000_ID_NF,
              NULL as M003_VL_ORIGINAL,
              NULL as M003_VL_DESCONTO,
              A.NUMERODF as M003_NR_FATURA,
              NULL as M003_VL_LIQUIDO,
              B.DESCCONDICAOPAGTO as M003_DS_CPGTO,
              C.FORMAPAGTO as M003_DS_FPGTO
      FROM    MFLV_BASENF       A,
              MAD_CONDICAOPAGTO B,
              MRL_FORMAPAGTO    C
      WHERE   A.NROCONDPAGTO    = B.NROCONDICAOPAGTO(+)
      AND     A.NROFORMAPAGTO   = C.NROFORMAPAGTO(+)
      AND     (B.DESCCONDICAOPAGTO IS NOT NULL OR FORMAPAGTO IS NOT NULL)
      AND     A.SEQNOTAFISCAL   = pnSeqNotaFiscal
      AND     A.tipuso          != 'R';
      select  M.M000_DM_ENTRADA_SAIDA,
              M.UFDESTINOC5,
              M.M000_DS_NAT_OPER
      into    vnEntradaSaida,
              vsUfDestino,
              vsNatOper
      from    TMP_M000_NF M
      where   M.M000_ID_NF = vnSeqM000_ID_NF;
      -- Forma Pagto NFe
      UPDATE TMP_M000_NF NF
      SET    NF.M000_FORMAPAGTONFE = fNFeFormaPagto(NF.M000_DM_FIN_EM , NF.M000_DM_ENTRADA_SAIDA , NF.NROFORMAPAGTO)
      WHERE  NF.M000_ID_NF         = vnSeqM000_ID_NF;
      INSERT INTO TMP_M014_ITEM(
              M014_ID_ITEM,
              M014_NR_UND_PRD_IPI,
              M014_NR_ITEM,
              M014_VL_UNID_TRIB_IPI,
              M014_DM_ST_TRIB_CF,
              M014_VL_QTDE_TRIB,
              M014_DM_ORIG_ICMS,
              M014_VL_TOTAL_SEGURO,
              M014_NR_CNPJ_IPI,
              M014_VL_ALIQ_ST_ICMS,
              M014_VL_BC_CF,
              M014_VL_ALIQ_IPI,
              M014_VL_BC_PIS,
              M014_CD_SELO_IPI,
              M014_VL_IPI, M014_VL_PERC_ALIQ_CF,
              M014_VL_QTDE_COM,
              M014_CD_EAN, M014_VL_DESCONTO,
              M014_DS_UNID_TRIB,
              M014_VL_PERC_REDUC_ICMS,
              M014_VL_PIS,
              M014_DS_INFO,
              M014_VL_QTDE_VEND_CF,
              M014_CD_PRODUTO,
              M014_CD_ENQ_IPI,
              M014_VL_ALIQ_ICMS,
              M014_CD_CFOP,
              M014_VL_ICMS,
              M014_NR_IBGE_MUN_ISSQN,
              M014_VL_ALIQ_CF,
              M014_CD_EX_TIPI,
              M014_DM_ST_TRIB_IPI,
              M014_VL_UNIT,
              M014_VL_BC_IPI,
              M014_CD_EAN_TRIB,
              M014_DS_UNID_COM,
              M014_VL_UNIT_TRIBUTAVEL,
              M014_VL_TOTAL_FRETE,
              M014_VL_BC_IMPOSTO_IMPORT,
              M014_NR_CLASSE_IPI,
              M014_VL_DESP_ADUANEIRAS,
              M014_VL_BC_ISSQN,
              M014_VL_IMPOSTO_IMPORT,
              M014_VL_ALIQ_ISSQN,
              M014_VL_IOF,
              M014_DM_MOD_BC_ICMS,
              M014_VL_BC_PIS_ST,
              M014_VL_CF,
              M014_VL_PALIQ_PIS_ST,
              M014_VL_BC_ICMS,
              M014_VL_QTD_PIS_ST,
              M014_VL_QTDE_VEND_PIS,
              M014_VL_RALIQ_PIS_ST,
              M014_VL_TOTAL_BRUTO,
              M014_VL_PIS_ST,
              M014_CD_NCM,
              M014_VL_BC_CF_ST,
              M014_VL_PERC_REDUC_ICMS_ST,
              M014_VL_PALIQ_CF_ST,
              M014_DM_ST_TRIB_PIS,
              M014_VL_QTD_CF_ST,
              M014_VL_ALIQ_PIS,
              M014_VL_ALIQ_CF_ST,
              M014_NR_SELO_IPI,
              M014_VL_CF_ST,
              M014_VL_PERC_ALIQ_PIS,
              M014_CD_LISTA_SERVICOS,
              M014_VL_PERC_MARG_ICMS,
              M014_DS_PRODUTO,
              M014_DM_TRIB_ICMS,
              M014_DM_MOD_BC_ST_ICMS,
              M014_VL_ISSQN,
              M000_ID_NF,
              M014_VL_PERC_DESC,
              M014_NR_PED_COMP,
              M014_NR_ITEM_PED_COMP,
              M014_VL_OUTRAS_DESPESAS,
              M014_DM_ITEM_TOTAL,
              M014_VL_BC_ST_RET,
              M014_VL_ICMS_ST_RET,
              M014_VL_PERC_CRED_SN,
              M014_VL_CRED_ICMS_SN,
              M014_VL_BC_ST_ICMS,
              M014_VL_ICMS_ST,
              M014_CD_GENERO,
              M014_CD_TRIB_ISSQN,
              M014_MOTIVO_DES_ICMS,
              m014_CSOSN_C5,
              NROADICAOC5,
              SEQADICAOC5,
              VLRDESCADICAODIC5,
              M014_LANCAMENTOSTc5,
              seqprodutoc5,
              codigoanpc5, codigoifc5,
              M014_CD_PRODUTOAUX_C5,
              M014_VL_TOTTRIB,
              M014_NRO_FCI_C5,
              M014_VL_PERC_CARGA_LIQ,
              M014_CD_NVEC5,
              NRODRAWBACKDIC5,
              M014_VL_PERC_GAS_NATURALC5,
              M014_DESCRICAOANP,
              M014_VL_PERCGASNATURALNACIONAL,
              M014_VL_PERCGASNATURALIMPORT,
              M014_VL_VLRPARTIDAGLP,
              M014_VL_PERC_DEVOLC5,
              M014_VL_ICMS_DIFC5,
              M014_VL_ICMS_OPPROPRIAC5,
              VLRDESCICMS,
              INDPAPELIMUNE,
              PERCMVAST,
              CODCEST,
              M014_VBCUFDESTPART,
              M014_PFCPUFDEST,
              M014_PICMSINTER,
              M014_PICMSINTERPART,
              M014_VFCPUFDEST,
              M014_VICMSUFDEST,
              M014_VICMSUFREMET,
              M014_TIPOCALCICMSFISCI_C5,
              M014_PERALIQICMSDIF_C5,
              PERCINCENTIVOPED,
              BASCALCFECP,
              PERALIQUOTAFECP,
              VLRFECP,
              M014_VL_IPI_DADOSADIC_C5,
              M014_BC_ICMS_ST_DISTRIB,
              M014_VL_ICMS_ST_DISTRIB,
              M014_VL_ALIQ_ICMS_ST_DISTRIB,
              m014_vl_bc_fcp_st,
              m014_vl_aliq_fcp_st,
              m014_vl_fcp_st,
              m014_vl_bc_fcp_icms,
              m014_vl_aliq_fcp_icms,
              m014_vl_fcp_icms,
              m014_vl_bc_fcp_ret,
              m014_vl_aliq_fcp_ret,
              m014_vl_fcp_ret,
              M014_VBCFCPUFDESTPART,
              CODAJUSTEEFD,
              PERREDBCICMSEFET,
              VLRBASEICMSEFET,
              PERALIQICMSEFET,
              VLRICMSEFET,
              INDESCALARELEVANTE,
              CNPJFABRICANTE,
              DIGCNPJFABRICANTE,
              M014_VL_OP_PROP_DIST,
              M014_VLRTOTICMSDESONOUTROS,
              M014_PERDIFERIDO_C5,
              M014_CD_CBARRA,
              M014_CD_CBARRA_TRIB,
              M014_VL_ICMS_ST_DESONERADO,
              M014_MOTIVO_DES_ICMS_ST,
              M014_ALIQ_FCP_ICMS_DIF,
              M014_VL_FCP_ICMS_DIF,
              M014_VL_FCP_ICMS_EFET,
              M014_DM_SOMA_PISST,
              M014_DM_SOMA_COFINSST,
              M014_VL_ALIQ_AD_REM_ICMS_RET,
              M014_VL_ICMS_MONO_RET,
              M014_VL_BC_ICMS_MONO_RET,
              M014_VL_PERC_BIODIESEL,
              M014_CD_CRED_PRESUMIDO,
              M014_ALIQ_CRED_PRESUMIDO,
              M014_VL_CRED_PRESUMIDO,
              M014_CD_BENEF_RBC,
              M014_DM_DEDUZ_DESON,
              --Reforma
              M014_TP_INDBEMMOVELUSADO,
              M014_VL_VLRITEM,
              --Is
              M014_CD_CSTIS,
              M014_DS_CCLASSTRIBIS,
              M014_VL_VLRBASEIS,
              M014_VL_PERALIQIS,
              M014_VL_PERALIQEUNIS,
              M014_VL_VLRIMPOSTOIS,
              M014_DS_UNTRIBIS,
              M014_VL_QTDTRIBIS,
              --Ibs
              M014_VL_VLRIMPOSTOIBS,
              --Ibs Uf
              M014_CD_CSTIBSUF,
              M014_DS_CCLASSTRIBIBSUF,
              M014_VL_VLRBASEIBSUF,
              M014_VL_PERALIQIBSUF,
              M014_VL_VLRIMPOSTOIBSUF,
              M014_VL_PERDIFERIDOIBSUF,
              M014_VL_VLRDIFERIDOIBSUF,
              M014_VL_VLRDEVTRIBIBSUF,
              M014_VL_PERALIQREDIBSUF,
              M014_VL_PERALIQEFETIVAIBSUF,
              M014_CD_CSTREGULARIBSUF,
              M014_DS_CCLASSTRIBREGULARIBSUF,
              M014_VL_PERALIQREGULARIBSUF,
              M014_VL_VLRIMPOSTOREGULARIBSUF,
              M014_VL_VLRBASECCREDPRESIBSUF,
              M014_CD_CCREDPRESIBSUF,
              M014_VL_PERALIQCCREDPRESIBSUF,
              M014_VL_VLRCCREDPRESIBSUF,
              M014_VL_VLRCCREDPRESCONDSUSIBSUF,
              M014_VL_PERALIQCOMPRAGOVIBSUF,
              M014_VL_VLRIMPOSTOCOMPRAGOVIBSUF,
              M014_VL_VLRIMPOSTOTRANSFERIDOIBS,
              M000_TP_INDCREDPRESZFMIBS,
              M014_VL_VLRCCREDPRESZFMIBS,
              -- Ibs Mun
              M014_CD_CSTIBSMUN,
              M014_DS_CCLASSTRIBIBSMUN,
              M014_VL_VLRBASEIBSMUN,
              M014_VL_PERALIQIBSMUN,
              M014_VL_VLRIMPOSTOIBSMUN,
              M014_VL_PERDIFERIDOIBSMUN,
              M014_VL_VLRDIFERIDOIBSMUN,
              M014_VL_VLRDEVTRIBIBSMUN,
              M014_VL_PERALIQREDIBSMUN,
              M014_VL_PERALIQEFETIVAIBSMUN,
              M014_CD_CSTREGULARIBSMUN,
              M014_DS_CCLASSTRIBREGULARIBSMUN,
              M014_VL_PERALIQREGULARIBSMUN,
              M014_VL_VLRIMPOSTOREGULARIBSMUN,
              M014_VL_PERALIQCOMPRAGOVIBSMUN,
              M014_VL_VLRIMPOSTOCOMPRAGOVIBSMUN,
              -- Cbs
              M014_CD_CSTCBS,
              M014_DS_CCLASSTRIBCBS,
              M014_VL_VLRBASECBS,
              M014_VL_PERALIQCBS,
              M014_VL_VLRIMPOSTOCBS,
              M014_VL_PERDIFERIMENTOCBS,
              M014_VL_VLRIMPOSTOBRUTOCBS,
              M014_VL_VLRDIFERIDOCBS,
              M014_VL_VLRDEVTRIBCBS,
              M014_VL_PERALIQREDCBS,
              M014_VL_PERALIQEFETIVACBS,
              M014_CD_CSTREGULARCBS,
              M014_DS_CCLASSTRIBREGULARCBS,
              M014_VL_PERALIQREGULARCBS,
              M014_VL_VLRIMPOSTOREGULARCBS,
              M014_VL_VLRBASECCREDPRESCBS,
              M014_CD_CCREDPRESCBS,
              M014_VL_PERALIQCCREDPRESCBS,
              M014_VL_VLRCCREDPRESCBS,
              M014_VL_VLRCCREDPRESCONDSUSCBS,
              M014_VL_PERALIQCOMPRAGOVCBS,
              M014_VL_VLRIMPOSTOCOMPRAGOVCBS,
              M014_VL_VLRIMPOSTOTRANSFERIDOCBS,
              -- Reforma Mono
              M014_VL_QTDE_TRIB_MONO,
              M014_VL_PERALIQADREMIBS,
              M014_VL_PERALIQADREMCBS,
              M014_VL_VLRIMPOSTOMONOIBS,
              M014_VL_VLRIMPOSTOMONOCBS,
              M014_VL_VLRIMPOSTOINTEGRALMONOIBS,
              M014_VL_VLRIMPOSTOINTEGRALMONOCBS,
              M014_VL_QTDE_TRIB_MONORETENIBS,
              M014_VL_PERALIQMONORETENIBS,
              M014_VL_VLRIMPOSTOMONORETENIBS,
              M014_VL_PERALIQMONORETENCBS,
              M014_VL_VLRIMPOSTOMONORETENCBS,
              M014_VL_QTDE_TRIB_MONORETIBS,
              M014_VL_PERALIQMONORETIBS,
              M014_VL_VLRIMPOSTOMONORETIBS,
              M014_VL_PERALIQMONORETCBS,
              M014_VL_VLRIMPOSTOMONORETCBS,
              M014_VL_PERDIFERIMENTOMONOIBS,
              M014_VL_VLRDIFERIDOMONOIBS,
              M014_VL_PERDIFERIMENTOMONOCBS,
              M014_VL_VLRDIFERIDOMONOCBS,
              -- Reforma Doc Ref
              M014_DS_CHAVEACESSOREF,
              M014_DS_NROITEMREF,
              --Agropecuario
              M014_TP_GUIAAGRO,
              M014_NR_RECEITUARIO,
              M014_NR_CPFRESPTECNICO,
              M014_TP_GUIATRANSITO,
              M014_UF_GUIA,
              M014_NR_SERIEGUIA,
              M014_NR_GUIA,
              -- Reforma estorno
              M014_VL_VLRIMPOSTOESTORNOIBS,
              M014_VL_VLRIMPOSTOESTORNOCBS
              )
      SELECT  case when vsSoftwarePDV = 'OPHOSNFE' then
                  fBuscaSeqTmpOphus('TMP_M014_ITEM')
              else
                    S_SEQNFEITEM.NEXTVAL
              end  as M014_ID_ITEM,
              (
              case when
                    (A.SITUACAONFIPI = '00' OR A.SITUACAONFIPI = '49'
                     OR A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '99'
                     OR (A.SITUACAONFIPI = '53' AND A.TIPDOCFISCAL = 'D') ) AND
                    ( NVL(A.VLRIPI,0) > 0 OR NVL(A.PERALIQUOTAIPI,0) > 0 ) THEN
                        decode(NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic), 'S', 0, to_number(null))
                    else
                        (A.QUANTIDADE/A.QTDEMBALAGEM)
               end
              ) as M014_NR_UND_PRD_IPI,
              nvl(A.SEQORDEMNFE, a.seqitemdf) as M014_NR_ITEM,
              (
              case when
                    (A.SITUACAONFIPI = '00' OR A.SITUACAONFIPI = '49'
                     OR A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '99'
                     OR (A.SITUACAONFIPI = '53' AND A.TIPDOCFISCAL = 'D') ) AND
                    ( NVL(A.VLRIPI,0) > 0 OR NVL(A.PERALIQUOTAIPI,0) > 0 ) THEN
                        decode(NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic), 'S', 0, to_number(null))
                    else
                        ROUND(decode(vsGERA_ITEM_LIQ_DESC,'S', A.VLRPRODBRUTO
                                                             - A.VLRDESCONTO
                                                             + decode(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl( a.vlrdescsf, 0 ) )
                                                             + DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0),
                                                               A.VLRPRODBRUTO - decode(vsPDConsidVlrDescEspecialItem, 'S', nvl( a.vlrdescsf, 0 ), 0 )) /
                              (DECODE(A.QUANTIDADE,0,1,A.QUANTIDADE)/DECODE(A.QTDEMBALAGEM,0,1,A.QTDEMBALAGEM)), 2)
               end
              ) as M014_VL_UNID_TRIB_IPI,
               (case when k.tipocontribpiscofins = 'C' then
                         '99'
                    when fmlf_validanfedeajuste(vnCodGeralOper) = 1 then
                         '08'
                    else
                         NVL(DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS),
                         DECODE(SIGN(NVL(A.VLRCOFINS,0)), 1,'01',
                         DECODE(vsPDTrocaCstPisCfXml,'N', DECODE(NVL(K.TIPCGO, A.TIPCGO), 'S', '08', '74'), FTrocaCstPisCfXml(K.TIPCGO, A.TIPCGO,A.TIPDOCFISCAL,A.CFOP))))
                    end
              ) as M014_DM_ST_TRIB_CF,
              (case
                    WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN
                         0
                    when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then
                         (A.QUANTIDADE/A.QTDEMBALAGEM)*D.FATORCONVEMBNFE
                    else
                         (A.QUANTIDADE/A.QTDEMBALAGEM)
               END
               )as M014_VL_QTDE_TRIB,
              case
                when ( select nvl(max(a.indsimplesnac), 'N')
                       from map_regimetributacao a
                       where nroregtributacao = i.nroregtributacao) = 'S' then
                     nvl(h.codorigemtrib,'0')
                when fmap_familiafinalidade(b.seqfamilia, a.nroempresa) = 'S' then
                     '0'
                When vnRegimeTribut = 0 And
                     A.SITUACAONF != A.SITUACAONFORIG then
                     SUBSTR(A.SITUACAONFORIG,1,1)
                when A.TIPDOCFISCAL = 'D' and A.CODORIGEMTRIB is not null then
                     A.CODORIGEMTRIB
                else SUBSTR(A.SITUACAONF,1,1)
              end as M014_DM_ORIG_ICMS,
              case when FMAP_FAMILIAFINALIDADE(b.seqfamilia, a.nroempresa) = 'G' then
                    a.vlrprodbruto
                   when A.VLRSEGURORATEIODANFE > 0 then
                    A.VLRSEGURORATEIODANFE
              else
                     A.VLRSEGURO
              end   as M014_VL_TOTAL_SEGURO,
              NULL as M014_NR_CNPJ_IPI,
              case when a.lancamentost in ('O','S') then
                0
              else
                case
                  when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 1, 3, 9, 10, 12, 13, 14, 18, 19, 20 ) then
                    DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt), 'A', 0,
                                                                    'C', decode(E.INDCONTRIBICMS,'N',0,A.PERALIQUOTAICMSST),
                                                                         A.PERALIQUOTAICMSST)
                  else null
                end
              end as M014_VL_ALIQ_ST_ICMS,
              (
              case  when (vsPD_SitDescCofinsSuspZFM = '06' AND vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null) THEN
                        0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) = '03' THEN
                        DECODE(A.SITUACAONFCOFINSCGO, '03', DECODE(A.PERALIQUOTACOFINS, 0, 0, ROUND(A.BASCALCOFINS,2)), NULL)
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) in ('07','08','09') THEN
                        NULL
                    else
                        DECODE(A.PERALIQUOTACOFINS, 0, 0, ROUND(A.BASCALCOFINS,2))
               end
              ) as M014_VL_BC_CF,
              (
              case when (A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '00' ) and
                        NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic) = 'T' then
                        A.PERALIQUOTAIPI
                   when
                    (A.SITUACAONFIPI = '00' OR A.SITUACAONFIPI = '49'
                     OR A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '99'
                     OR (A.SITUACAONFIPI = '53' AND A.TIPDOCFISCAL = 'D') ) AND
                    ( NVL(A.VLRIPI,0) > 0 OR NVL(A.PERALIQUOTAIPI,0) > 0 ) THEN
                        DECODE( NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic), 'S', to_number(null), A.PERALIQUOTAIPI )
                    else
                        null
               end
              ) as M014_VL_ALIQ_IPI,
              (
              case  when (vsPD_SitDescPisSuspZFM = '06' and vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null) THEN
                        0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) = '03' THEN
                        DECODE(A.SITUACAONFPISCGO, '03',  decode(a.PERALIQUOTAPIS, 0, 0, ROUND(A.BASCALCPIS,2)), NULL)
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) in ('07','08','09') THEN
                        NULL
                    else
                        decode(a.PERALIQUOTAPIS, 0, 0, ROUND(A.BASCALCPIS,2))
               end
              ) as M014_VL_BC_PIS,
              Decode( vsPDConsInfSeloIpi, 'S', A.CODIGOSELOIPI, null) as M014_CD_SELO_IPI,
              (
              case when (A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '00' ) and
                        NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic) = 'T' then
                        A.VLRIPI
                   when
                    (A.SITUACAONFIPI = '00' OR A.SITUACAONFIPI = '49'
                     OR A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '99'
                     OR (A.SITUACAONFIPI = '53' AND A.TIPDOCFISCAL = 'D') ) AND
                    ( NVL(A.VLRIPI,0) > 0 ) THEN
                        DECODE( NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic), 'S', 0, A.VLRIPI )
                    else
                        0
               end
              ) as M014_VL_IPI,
              (
              case  when (vsPD_SitDescCofinsSuspZFM = '06' AND vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null) THEN
                         0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) = '03' THEN
                        DECODE(A.SITUACAONFCOFINSCGO, '03', ROUND(A.PERALIQUOTACOFINS,4), NULL)
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) in ('07','08','09') THEN
                        NULL
                    else
                         ROUND(NVL(A.PERALIQUOTACOFINS,0),4)
               end
              ) as M014_VL_PERC_ALIQ_CF,
              (case
                   WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN 0
                   WHEN vsIndIipoEmbDanfeClie = 'M' then A.QUANTIDADE/fminembfamilia(B.SEQFAMILIA)
                   when vsIndIipoEmbDanfeClie = 'V' then A.QUANTIDADE/FMinEmbVendaFamiliaAtiva(B.SEQPRODUTO, A.NROEMPRESA, NVL(A.NROSEGITEM, A.NROSEGMENTO))
                   else A.QUANTIDADE/A.QTDEMBALAGEM end) as M014_VL_QTDE_COM,
              fc5_NFeCodAcesso(A.NROEMPRESA, A.SEQPRODUTO,Decode (vsIndIipoEmbDanfeClie, 'M',fminembfamilia(B.SEQFAMILIA),
                                                               'V', FMinEmbVendaFamiliaAtiva(B.SEQPRODUTO, A.NROEMPRESA,
                                                                NVL(A.NROSEGITEM, A.NROSEGMENTO)),
              A.QTDEMBALAGEM), 'N') as M014_CD_EAN,
              decode(vsGERA_ITEM_LIQ_DESC,'S',
                               DECODE(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl( a.vlrdescsf, 0 ) ),
                               A.VLRDESCONTO - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl( a.vlrdescsf, 0 ), 0 ))
              + decode(a.tipotabela, 'D', round( a.vlrdescincond, 2), 0)
              - nvl(decode(nvl(vsGERA_ITEM_LIQ_DESC, 'N'), 'N', nvl(a.VLRDESCSUFRAMA, 0)
                         + nvl(DECODE(a.indSubtraiICMSDesonTotItem, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI)), 0)),0)
               as M014_VL_DESCONTO,
              (case
                    WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN
                         '0'
                    when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then
                         D.EMBCONVNFE
                    when vsPDVersaoXml = '4'
                      and b.codigoanp in (210203001, 210203003, 210203004, 210203005, 420102004, 420102005,
                                          420105001, 420201001, 420201003, 420301002, 820101001, 820101012,
                                          820101013, 820101033, 820101034, 320101001, 320101002, 320102001,
                                          320102002, 320102003, 320102005, 320201001, 810102001, 810102004,
                                          810102003, 320103001, 320103003, 320301002, 320301001, 320103002)
                      then
                         D.EMBALAGEM -- atualmente deve ser sempre configurado como "KG"
                    else
                         D.EMBALAGEM || SUBSTR(A.QTDEMBALAGEM, 1, 4) END
              ) as M014_DS_UNID_TRIB,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 1, 2, 3, 4, 8, 9, 10, 14, 18, 19, 20, 151 ) then
                  case when vsSoftwarePDV = 'NDDIGITAL' and fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) = 10 and nvl(DECODE(NVL(K.INDEMITEICMS, vsIndEmiteIcms), 'A', 0, fBuscaPerRedICMS(a.seqnotafiscal, a.seqproduto, a.pertributado, 'TR')),0) = 0 then
                      null
                  else
                      nvl(DECODE(NVL(K.INDEMITEICMS, vsIndEmiteIcms),'A',0,fBuscaPerRedICMS(a.seqnotafiscal, a.seqproduto, a.pertributado, 'TR')),0)
                  end
                else null
              end as M014_VL_PERC_REDUC_ICMS,
              (
              case  when (vsPD_SitDescPisSuspZFM = '06' AND vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null) THEN
                         0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) in ('07','08','09') THEN
                        NULL
                    else
                        ROUND(A.VLRPIS,2)
               end
              ) as M014_VL_PIS,
              fInfoAdicionaisProdNFe(pnSeqNotaFiscal,
                                     A.NROPEDVENDALICIT,
                                     A.OBSITEMPEDVENDALONGSTR,
                                     A.OBSITEMPEDVENDACOMPLLOTE,
                                     A.SEQPRODUTO,
                                     A.QTDEMBALAGEM,
                                     A.TIPOTABELA,
                                     A.VLRICMSSTDISTRIB,
                                     A.BASICMSSTDISTRIB,
                                     A.VLRICMSOPPROPDISTRIB,
                                     A.MOTIVODESONERACAOICMS,
                                     A.BASCALCICMSOPPROPRIADISTRIB,
                                     A.OBSITEM,
                                     A.SERIEDF,
                                     A.NUMERODF,
                                     A.NROEMPRESA,
                                     A.NROSERIEECF,
                                     A.VLRDESCSUFRAMA,
                                     A.VLRPRODBRUTO,
                                     A.VLRDESCONTO,
                                     A.VLRDESCSF,
                                     A.VLRDESCICMS,
                                     A.VLRICMS,
                                     A.BASEFCPICMS,
                                     A.PERALIQFCPICMS,
                                     (CASE WHEN I.UF = 'RJ' AND NVL(E.UF, F.UF) = 'RJ'
                                           THEN CASE WHEN (NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)) < 0
                                                     THEN 0
                                                     ELSE NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)
                                                END
                                           ELSE A.VLRFCPICMS
                                     END),
                                     A.BASEFCPST,
                                     A.VLRICMSST,
                                     A.PERALIQFCPST,
                                     A.VLRFCPST,
                                     C.OBSEMERGENCIAL,
                                     J.NROFCI,
                                     J.PERCCI,
                                     vsIndEmiteSTRefUltEntrada,
                                     vnIndNFIntegraFiscal,
                                     CASE WHEN a.indmotivodesoicms IS NULL THEN
                                       CASE WHEN a.vlrdescsuframa > 0 THEN 7
                                            WHEN a.vlrdescicms > 0 THEN 9
                                       ELSE NULL END
                                     ELSE
                                       CASE WHEN nvl(a.vlrdescsuframa,0) > 0 OR nvl(a.vlrdescicms,0) > 0 THEN a.indmotivodesoicms
                                       ELSE NULL END
                                     END,
                                     CASE WHEN NVL(A.VLRDESCICMS, 0) > 0 THEN NVL(A.VLRDESCICMS, 0)
                                          WHEN fNFeCalcVlrICMSDeson(A.SITUACAONF, A.VLRDESCSUFRAMA,
                                                                    A.VLRICMS, A.VLRICMSST,
                                                                    NVL(K.INDEMITEICMS, vsIndEmiteIcms)) > 0 THEN
                                            fNFeCalcVlrICMSDeson(A.SITUACAONF, A.VLRDESCSUFRAMA,
                                                                 A.VLRICMS, A.VLRICMSST,
                                                                 NVL(K.INDEMITEICMS, vsIndEmiteIcms))
                                     END,
                                     vsUfOrigem) as M014_DS_INFO,
              (
              case  when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) = '03' THEN
                        A.QUANTIDADE * NVL(A.FATORCONVIPIPISCOFINS, 1)
                    else
                        NULL
               end
              ) as M014_VL_QTDE_VEND_CF,
              CASE
                  WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                       'CFOP' || TO_CHAR(A.cfop)
                  when b.indemitecodprodfiscalnfe = 'S' and b.codprodfiscal is not null THEN
                        b.codprodfiscal
                  else
                        decode(g.tipocodprodnf,
                           'S',
                           decode(vsPDIndGeraRefFabricCodProd,
                              'S',
                              NVL(B.REFFABRICANTE, A.SEQPRODUTO),
                              A.SEQPRODUTO),
                           'I',
                           NVL(FCODACESSOPRODEMB(A.SEQPRODUTO, 'B', 0, A.QTDEMBALAGEM),
                             A.seqproduto),
                            'F',
                            NVL(FBUSCACODACESSOFORNEC(A.SEQPRODUTO, A.QTDEMBALAGEM, FMAP_FORNECFAMILIA(A.SEQFAMILIA)),
                              A.SEQPRODUTO),
                           NVL(FCODACESSOPRODEMBNF(A.NROEMPRESA,
                                       A.SEQPRODUTO,
                                       g.tipocodprodnf,
                                       NULL,
                                       A.QTDEMBALAGEM, null, 'N'),
                             A.seqproduto))
              end as M014_CD_PRODUTO,
              case when fmap_familiafinalidade(b.seqfamilia, a.nroempresa) = 'S' then
                     null
              else
                   Decode(vsPDConsInfSeloIpi, 'S', NVL(A.CODIGOENQUADRAMENTOIPI, DECODE(A.SITUACAONFIPI, NULL, NULL, 999)), 999)
              end as M014_CD_ENQ_IPI,
              case  when A.SITUACAONF = '060' THEN
                        0
              else
                    DECODE(NVL(K.INDEMITEICMS, vsIndEmiteIcms),'A',0,NVL(A.PERALIQICMSORIG, A.PERALIQUOTAICMS))
              end    as M014_VL_ALIQ_ICMS,
              A.CFOP as M014_CD_CFOP,
              fNFeCalcVlrICMSDeson(A.SITUACAONF, A.VLRDESCSUFRAMA, A.VLRICMS,
                                   A.VLRICMSST, NVL(K.INDEMITEICMS, vsIndEmiteIcms)) AS M014_VL_ICMS,
              DECODE(A.VLRISS,0,NULL,F.CODIBGE) as M014_NR_IBGE_MUN_ISSQN,
              (
              case  when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) = '03' THEN
                        A.VLRMINCOFINS
                    else
                        NULL
               end
              ) as M014_VL_ALIQ_CF,
              case when C.CODTIPI is not null then
                   case when length(C.CODTIPI) = 1 then
                       lpad(to_char(C.CODTIPI), 2, '0')
                   else
                        to_char(C.CODTIPI)
                   end
              end as M014_CD_EX_TIPI,
              -- Giuliano 17/06/26
              -- Ticket 463190
              CASE WHEN A.CODGERALOPER IN (97,244,803,850) AND NAGF_BUSCA_CST_IPI_FAM(B.SEQFAMILIA) = '50'
                   THEN 10 ELSE
              case when fmap_familiafinalidade(b.seqfamilia, a.nroempresa) = 'S' then
                     null
              else
                  fRetornaSituacaoIpiOphos( A.SITUACAONFIPI, A.TIPDOCFISCAL )
              end 
              END  as M014_DM_ST_TRIB_IPI,
               ( CASE WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                           0
                      WHEN nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN
                           a.vlritem
                      ELSE
                           nvl(a.vlrunitariodev * (case vsIndIipoEmbDanfeClie
                                                when 'M' then fminembfamilia(B.SEQFAMILIA)
                                                when 'V' then FMinEmbVendaFamiliaAtiva(B.SEQPRODUTO, A.NROEMPRESA, NVL(A.NROSEGITEM, A.NROSEGMENTO))
                                                else  A.QTDEMBALAGEM end),
                                decode( nvl(a.VlrUnitarioECF, 0), 0, fc5_RetVlrUnitNfe(A.SEQNOTAFISCAL, A.SEQPRODUTO, (case vsIndIipoEmbDanfeClie
                                                                                                       when 'M' then fminembfamilia(B.SEQFAMILIA)
                                                                                                       when 'V' then FMinEmbVendaFamiliaAtiva(B.SEQPRODUTO, A.NROEMPRESA, NVL(A.NROSEGITEM, A.NROSEGMENTO))
                                                                                                       else  A.QTDEMBALAGEM end) ,
                                                      a.VLRPRODBRUTO, (a.VLRDESCONTO -  DECODE(A.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0)), A.VLRDESCSF,
                                                      A.QUANTIDADE, A.INDUSAPRECOFIXO, vsGERA_ITEM_LIQ_DESC, vsPDConsidVlrDescEspecialItem, a.tipotabela, a.tipotabvenda,a.vlracrescimo),
                                        a.VlrUnitarioECF
                                  )
                              )
                 END
               )   as M014_VL_UNIT,
              (
              case when (A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '00' ) and
                        NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic) = 'T' then
                        A.BASEIPI
                   when
                    (A.SITUACAONFIPI = '00' OR A.SITUACAONFIPI = '49'
                     OR A.SITUACAONFIPI = '50' OR A.SITUACAONFIPI = '99'
                     OR (A.SITUACAONFIPI = '53' AND A.TIPDOCFISCAL = 'D')) AND
                    ( NVL(A.VLRIPI,0) > 0 OR NVL(A.PERALIQUOTAIPI,0) > 0 ) THEN
                        DECODE( NVL(K.INDVLRIPIDADOADICIONAL, vsIndVlrIpiDadoAdic), 'S', to_number(null), A.BASEIPI )
                    else
                        NULL
               end
              ) as M014_VL_BC_IPI,
              fc5_NFeCodAcesso(A.NROEMPRESA, A.SEQPRODUTO, A.QTDEMBALAGEM, 'S') as M014_CD_EAN_TRIB,
             (case
                   WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(indqtdzeradanfcompl, 'N') = 'S' THEN '0'
                   when vsIndIipoEmbDanfeClie = 'M' then fDescEmbFamilia(B.SEQFAMILIA,fminembfamilia(B.SEQFAMILIA))
                   when vsIndIipoEmbDanfeClie = 'V' then fDescEmbFamilia(B.SEQFAMILIA,FMinEmbVendaFamiliaAtiva(B.SEQPRODUTO, A.NROEMPRESA, NVL(A.NROSEGITEM, A.NROSEGMENTO)))
                   when vsIndIipoEmbDanfeClie = 'C' then D.EMBALAGEM
                   else  D.EMBALAGEM || SUBSTR(A.QTDEMBALAGEM, 1, 4) end)  as M014_DS_UNID_COM,
              (
               CASE WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                         0
                    ELSE
                         nvl(a.vlrunitariodev * (case when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then ( 1 ) else A.QTDEMBALAGEM end), decode( nvl(a.VlrUnitarioECF, 0), 0, fc5_RetVlrUnitNfe(A.SEQNOTAFISCAL, A.SEQPRODUTO, (case when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then ( 1 ) else A.QTDEMBALAGEM end), a.VLRPRODBRUTO,
                         (a.VLRDESCONTO -  DECODE(A.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0)), A.VLRDESCSF,
                                 (case when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then (A.QUANTIDADE/A.QTDEMBALAGEM)*D.FATORCONVEMBNFE else A.QUANTIDADE end), A.INDUSAPRECOFIXO, vsGERA_ITEM_LIQ_DESC, vsPDConsidVlrDescEspecialItem, a.tipotabela, a.tipotabvenda,a.vlracrescimo), a.VlrUnitarioECF) )
               END
              )as M014_VL_UNIT_TRIBUTAVEL,
              nvl(case when A.VLRFRETE_MAXTRANSPITEM > 0 and vsPDEmiteFreteDocTransp = 'S'
                       then 0
                       else A.VLRFRETE_MAXTRANSPITEM end,
                 DECODE(A.TIPOFRETE,'C',
                      DECODE(vsPDGeraValorFreteNFCif, 'S',
                                        case when sign(A.VLRFRETETRANSP) = 1 and a.tipotabela = 'N' then
                                             A.VLRFRETETRANSP
                                        else
                                             case when FMAP_FAMILIAFINALIDADE(b.seqfamilia, a.nroempresa)  = 'F' then
                                                   nvl(a.vlrprodbruto, 0) +
                                                   case when A.SEQITEMDF = fc5_NFeSeqItemDF(A.SEQNOTAFISCAL) and (A.APPORIGEM = 14 Or (A.apporigem = 2 And A.tipdocfiscal = 'D')) then
                                                      fValorProdFinalidade(a.id_df, a.tipotabela, 'F')
                                                   else
                                                      0
                                                   end
                                             else
                                                   nvl(DECODE(A.apporigem,'14',NVL(A.VLRFRETENANF,A.VLRFRETEITEMRATEIO),A.VLRFRETEITEMRATEIO), 0)
                                             end
                                        end,  DECODE(A.apporigem,'14',NVL(A.VLRFRETENANF,A.VLRFRETEITEMRATEIO),A.VLRFRETEITEMRATEIO)),
                      case when sign(A.VLRFRETETRANSP) = 1 and a.tipotabela = 'N' and vnExisteConhecimento = 0 then
                           A.VLRFRETETRANSP
                      when sign(A.VLRFRETETRANSP) = 1 and a.tipotabela = 'N' and vnExisteConhecimento > 0 then
                           0
                      else
                           case when FMAP_FAMILIAFINALIDADE(b.seqfamilia, a.nroempresa)  = 'F' then
                                 a.vlrprodbruto +
                                 case when A.SEQITEMDF = fc5_NFeSeqItemDF(A.SEQNOTAFISCAL) and (A.APPORIGEM = 14 Or (A.apporigem = 2 And A.tipdocfiscal = 'D')) then
                                    fValorProdFinalidade(a.id_df, a.tipotabela, 'F')
                                 else
                                    0
                                 end
                           else
                                 nvl(DECODE(A.apporigem,'14',NVL(A.VLRFRETENANF,A.VLRFRETEITEMRATEIO),A.VLRFRETEITEMRATEIO), 0)
                           end
                      end
                    )) as M014_VL_TOTAL_FRETE,
              case when a.vlrimpostoimport > 0 or a.vlrimpimportexport > 0 or a.vlrimpimportexporttopo > 0 then
                   case when a.vlrbaseimpostoimport > 0 then
                      a.vlrbaseimpostoimport
                   when a.BASEICMS > 0 then
                         a.BASEICMS
                   else
                        a.vlritem
                   end
                   when a.vlrbaseimpostoimport > 0 then
                       a.vlrbaseimpostoimport
              else
                 0
              end as M014_VL_BC_IMPOSTO_IMPORT,
              Decode(vsPDConsInfSeloIpi, 'S', A.CLASSEENQUADRAMENTOIPI,null) as M014_NR_CLASSE_IPI,
              a.vlrdespesaad + a.vlrsiscomex as M014_VL_DESP_ADUANEIRAS,
              DECODE(A.VLRISS,0,null,A.VLRCONTABIL) as M014_VL_BC_ISSQN,
              case when a.vlrimpostoimport > 0 then
                   a.vlrimpostoimport
              else
                  a.vlrimpimportexport
              end as M014_VL_IMPOSTO_IMPORT,
              decode(A.VLRISS, 0, null, round(A.VLRISS/ A.VLRCONTABIL, 4) * 100) as M014_VL_ALIQ_ISSQN,
              0 as M014_VL_IOF,
              DECODE(A.INDPAUTAICMS,'S',1,3) as M014_DM_MOD_BC_ICMS,
              NULL as M014_VL_BC_PIS_ST,
              (
              case  when (vsPD_SitDescCofinsSuspZFM = '06' and vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null)  THEN
                         0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS) in ('07','08','09') THEN
                        NULL
                    else
                        ROUND(A.VLRCOFINS,2)
               end
              ) as M014_VL_CF,
              NULL as M014_VL_PALIQ_PIS_ST,
              case when substr(A.SITUACAONF, 2, 2) in ('40','41','50') THEN
                        NULL
                   when substr(A.SITUACAONF, 2, 2) = '60' THEN
                        0
                   when NVL(K.INDEMITEICMS, vsIndEmiteIcms) = 'S' and a.vlricmsst > 0 THEN
                        0
                   when a.vlrdescsuframa > 0 then
                        0
              else
                    DECODE(NVL(K.INDEMITEICMS, vsIndEmiteIcms),'A',0, case when A.SEQITEMDF = fc5_NFeSeqItemDF(A.SEQNOTAFISCAL) and (A.APPORIGEM = 14 Or (A.apporigem = 2 And A.tipdocfiscal = 'D')) THEN
                                                      fValorProdFinalidade(a.id_df, a.tipotabela, 'F', 'B')
                                                 else
                                                      0
                                                 end + nvl(A.BASEICMS, 0))
              end as M014_VL_BC_ICMS,
              NULL as M014_VL_QTD_PIS_ST,
              (
              case when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) = '03' THEN
                        A.QUANTIDADE * NVL(A.FATORCONVIPIPISCOFINS, 1)
                   else
                        NULL
               end
              ) as M014_VL_QTDE_VEND_PIS,
              NULL as M014_VL_RALIQ_PIS_ST,
              decode(vsGERA_ITEM_LIQ_DESC|| A.INDUSAPRECOFIXO,'SN', A.VLRPRODBRUTO
                                                                  - a.VLRDESCONTO
                                                                  + decode(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl( a.vlrdescsf, 0 ) )
                                                                  + DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0)
                                                                  ,A.VLRPRODBRUTO - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl( a.vlrdescsf, 0 ), 0 ) ) as M014_VL_TOTAL_BRUTO,
              NULL as M014_VL_PIS_ST,
              (
               CASE WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                        '00'
                    ELSE
                        REPLACE(C.CODNBMSH,'.','')
               END
              ) as M014_CD_NCM,
              NULL as M014_VL_BC_CF_ST,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 14, 18, 19, 20 ) then
                  nvl(DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A', 0,
                                                                     'C', decode(E.INDCONTRIBICMS,'N',0,fc5BuscaBaseReduzProduto(b.codprodfiscal, a.seqpessoa, a.nroempresa, a.tipnotafiscal, a.codgeraloper,
                                                                                                                                 a.seqproduto, i.uf, vsUfDestino, i.codperfilorigem, e.codperfildestino,
                                                                                                                                 null, null, f.codibge, null, null, null, trunc(sysdate), null)),
                                                                          fc5BuscaBaseReduzProduto(b.codprodfiscal, a.seqpessoa, a.nroempresa, a.tipnotafiscal, a.codgeraloper,
                                                                                                   a.seqproduto, i.uf, vsUfDestino, i.codperfilorigem, e.codperfildestino,
                                                                                                   null, null, f.codibge, null, null, null, trunc(sysdate), null)),0)
                else null
              end as M014_VL_PERC_REDUC_ICMS_ST,
              NULL as M014_VL_PALIQ_CF_ST,
              (case when k.tipocontribpiscofins = 'C' then
                        '99'
                    WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                        '08'
                    else
                        NVL(DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS),
                        DECODE(SIGN(NVL(A.VLRPIS,0)), 1,'01',
                        DECODE(vsPDTrocaCstPisCfXml, 'N', DECODE(NVL(K.TIPCGO, A.TIPCGO), 'S', '08', '74'), FTrocaCstPisCfXml(K.TIPCGO, A.TIPCGO, A.TIPDOCFISCAL, A.CFOP))))
               end
              ) as M014_DM_ST_TRIB_PIS,
              NULL as M014_VL_QTD_CF_ST,
              (
              case when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) = '03' THEN
                        A.VLRMINPIS
                   else
                        NULL
               end
              ) as M014_VL_ALIQ_PIS,
              NULL as M014_VL_ALIQ_CF_ST,
              A.QTDSELOIPI as M014_NR_SELO_IPI,
              NULL as M014_VL_CF_ST,
              (
              case  when (vsPD_SitDescPisSuspZFM = '06' AND vnCountCidadeZFM > 0 AND A.INDPERMSUSPPISCOFINS = 'S') Or
                         A.CFOP IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPD_ListaCfopEstPisCof), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null) THEN
                         0
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) = '03' THEN
                        DECODE(A.SITUACAONFPISCGO, '03', ROUND(A.PERALIQUOTAPIS,4), NULL)
                    when DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS) in ('07','08','09') THEN
                        NULL
                    else
                        ROUND(NVL(A.PERALIQUOTAPIS,0),4)
               end
              ) as M014_VL_PERC_ALIQ_PIS,
              C.CODSERVICO as M014_CD_LISTA_SERVICOS,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 1, 3, 9, 10, 12, 13, 14, 18, 19, 20 ) then
                  case when ((a.apporigem in(2, 22, 39) and fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) = 9) or (a.apporigem = 1 and a.tipdocfiscal = 'D')) and ('NDDIGITAL' = 'NDDIGITAL') then
                       case when a.apporigem in (2, 22, 39) and a.tipdocfiscal = 'D' and a.peracrescst > 0 then
                         a.peracrescst
                       else
                         fc5BuscaMVAProduto(A.seqproduto,a.seqpessoa,a.nroempresa, 'E', a.codgeraloper, a.apporigem, a.tipforitem,
                                            vnNroRegTribDevol, a.peracrescst, i.uf, vsUfDestino, i.codperfilorigem, e.codperfildestino,
                                            null, null, f.codibge, null, null, null, trunc(sysdate))
                       end
                  else
                        nvl(DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                           'C',decode(E.INDCONTRIBICMS,'N',0,fc5BuscaMVAProduto(A.seqproduto,a.seqpessoa, a.nroempresa, a.tipnotafiscal, a.codgeraloper, null, null, vnNroRegTribDevol, a.peracrescst,
                                                                                                                                i.uf, vsUfDestino, i.codperfilorigem, e.codperfildestino, null, null, f.codibge, null, null, null, trunc(sysdate))),
                                                                               fc5BuscaMVAProduto(A.seqproduto,a.seqpessoa, a.nroempresa, a.tipnotafiscal, a.codgeraloper, null, null, vnNroRegTribDevol, a.peracrescst,
                                                                                                  i.uf, vsUfDestino, i.codperfilorigem, e.codperfildestino, null, null, f.codibge, null, null, null, trunc(sysdate))),0)
                  end
                else null
              end as M014_VL_PERC_MARG_ICMS,
              case WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                      fc5_NFeAjusteDescricaoProd(A.SEQNOTAFISCAL, I.UF, A.APPORIGEM, vsNatOper, A.VLRICMSST, A.VLRFCPST)
              else
              fc5_NFeDescricaoProd(
                  A.SEQPRODUTO,
                  A.NROPEDVENDALICIT,
                  A.OBSITEMPEDVENDALONGSTR,
                  A.OBSITEMPEDLICIT,
                  A.OBSITEM,
                  DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFPISCGO,A.SITUACAONFPIS), A.SITUACAONFPIS),
                  DECODE(A.INDREMESSACONSUMO, 'S', NVL(A.SITUACAONFCOFINSCGO,A.SITUACAONFCOFINS), A.SITUACAONFCOFINS),
                  A.SEQNOTAFISCAL,
                  A.NROEMPRESA,
                  A.SEQITEMDF,
                  B.REFFABRICANTE,
                  vsIndIipoEmbDanfeClie,
                  D.EMBALAGEM || SUBSTR(A.qtdembalagem, 1, 4),
                  decode(C.INDENVIAQTDMAXTRANSPNFE,'S',C.QTDMAXPERMNFE,NULL),
                  ((A.quantidade / a.qtdembalagem) * D.PESOBRUTO))
              End as M014_DS_PRODUTO,
              case when fmap_familiafinalidade(b.seqfamilia, a.nroempresa) = 'S' then
                     null
              else
                  fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa)
              end as M014_DM_TRIB_ICMS,
              DECODE(A.INDPAUTAST,'S',5,4) as M014_DM_MOD_BC_ST_ICMS,
              decode(A.VLRISS,0,NULL,A.VLRISS) as M014_VL_ISSQN,
              vnSeqM000_ID_NF as M000_ID_NF,
              decode(A.VLRPRODBRUTO,0,0,ROUND(decode(vsGERA_ITEM_LIQ_DESC|| A.INDUSAPRECOFIXO,'SN', DECODE(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl( a.vlrdescsf, 0 ) ),
                                                                            A.VLRDESCONTO
                                                                          - DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0)
                                                                          - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl( a.vlrdescsf, 0 ), 0 )) / A.VLRPRODBRUTO * 100, 2)) as M014_VL_PERC_DESC,
              SUBSTR(fc5_RetNroPedVdaClie_NFe(A.SEQNOTAFISCAL,A.SEQPESSOA,A.SEQPRODUTO,A.QTDEMBALAGEM,A.TIPOTABELA,NULL,NULL),0,15) as M014_NR_PED_COMP,
              case
                when fc5_RetNroPedVdaClie_NFe(A.SEQNOTAFISCAL,A.SEQPESSOA,A.SEQPRODUTO,A.QTDEMBALAGEM,A.TIPOTABELA,NULL, NULL) = '0' then 0
                else fmad_seqprodpedido(fc5_RetNroPedVenda_NFe(A.SEQNOTAFISCAL,A.SEQPESSOA,A.SEQPRODUTO,A.QTDEMBALAGEM,A.TIPOTABELA,NULL,NULL),A.SEQPRODUTO, a.seqitemdf, a.qtdembalagem)
              end as M014_NR_ITEM_PED_COMP,
              case when FMAP_FAMILIAFINALIDADE(b.seqfamilia, a.nroempresa)  = 'D' then
                 a.vlrprodbruto
                   when A.VLRDESPESARATEIODANFE > 0 then
                    A.VLRDESPESARATEIODANFE
              else
                 ABS( DECODE(A.APPORIGEM,'14',(A.VLRDESPTRIBUTITEM-nvl(A.VLRFRETENANF,0)),A.VLRDESPTRIBUTITEM)
                      - decode(A.tipdocfiscal,'D', nvl(a.vlrfreteitemrateio,0),0) + A.VLRDESPACESSORIA + A.VLRACRFINANCEIRO +
                  case when A.TIPOTABELA = 'D' and A.INDFATURAICMSANTEC = 'S' then
                       NVL(A.VLRICMSANTECIPADO,0)
                  else 0 end + NVL(A.VLRDESPNTRIBUTITEM,0) )
              end
              +
              DECODE( NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),
                        'A', decode(nvl(fIndGeraDevRessarcSTFornec(a.seqpessoa,i.nrodivisao),'N'),'N',decode(nvl(a.lancamentost, 'C'), 'O', 0, 'S', 0, nvl(a.vlricmsst, 0) + CASE
                                                                                                                                                                               WHEN SUBSTR(a.situacaonf, 2, 2) IN ('00', '20', '60') THEN
                                                                                                                                                                                 NVL(a.vlrfcpst, 0)
                                                                                                                                                                               ELSE
                                                                                                                                                                                 0
                                                                                                                                                                             END), 0),
                        'C', decode(e.indcontribicms,'N',decode(nvl(fIndGeraDevRessarcSTFornec(a.seqpessoa,i.nrodivisao),'N'),'N',decode(nvl(a.lancamentost, 'C'), 'O', 0, 'S', 0, nvl(a.vlricmsst, 0) + CASE
                                                                                                                                                                                                           WHEN SUBSTR(a.situacaonf, 2, 2) IN ('00', '20', '60') THEN
                                                                                                                                                                                                             NVL(a.vlrfcpst, 0)
                                                                                                                                                                                                           ELSE
                                                                                                                                                                                                             0
                                                                                                                                                                                                         END), 0), 0),
                        0)
              +
              CASE WHEN NVL(K.INDGERIPIDEVXML, vsIndGeraIPIDevXML) = 'S'
                   AND NVL(K.INDVLRIPIDADOADICIONAL,vsIndVlrIpiDadoAdic) = 'S'
                   AND A.TIPDOCFISCAL = 'D' AND vsPDVersaoXml = '4' THEN
                     0
              ELSE
                NVL(A.VLRIPIOBSADC, 0)
              END
              +
              NVL(A.VLRICMSSTOUTROSDESP, 0)
              +
              case when vsTipoDoctoFiscal = 'D' or A.TIPOTABELA = 'D' then -- FCP
                NVL(A.VLRFECPOUTRADESPNFE, 0)
              else
                0
              End
              +
              case when A.SEQITEMDF = fc5_NFeSeqItemDF(A.SEQNOTAFISCAL) and (A.APPORIGEM = 14 Or (A.apporigem = 2 And A.tipdocfiscal = 'D')) THEN
                 fc5_NFeValorOutrasDespesas(A.SEQNOTAFISCAL)
              else
                 0
              end
              -
              case when a.nrodeclaraimport is not null
                and (vsPDConsid_Imp_VlrOutras = 'T' OR ( vsPDConsid_Imp_VlrOutras = 'M' and a.apporigem in (35))) then
                (nvl(a.vlrpis, 0) + nvl(a.vlrcofins, 0) + nvl(a.vlrimpimportexport, 0))
              else
                0
              end
              -
              case when a.nrodeclaraimport is not null and vsPDCalcBaseIcmsAFRMM = 'S'
                and (vsPDConsid_Imp_VlrOutras = 'T' OR ( vsPDConsid_Imp_VlrOutras = 'M' and a.apporigem in (35))) then
                 fRateiaAFRMM(a.nroadicaodi, a.nrodeclaraimport, a.seqproduto)
              else
                  0
              end 
              -- Giuliano 06/05/26
              - 
              CASE WHEN nvl(a.vlrfreteitemrateio, 0) > 0 THEN NAGF_SUBTRAI_DESP_CENT_ECOMM(NVL(A.VLRDESPACESSORIA,0), A.APPORIGEM, A.CODGERALOPER) ELSE 0 END
              --
              as M014_VL_OUTRAS_DESPESAS,
              case
                when FMAP_FAMILIAFINALIDADE(B.SEQFAMILIA, A.NROEMPRESA) in ('F', 'G', 'D') or
                     A.SEQITEMDF >= 990 then 0
                else 1
              end as M014_DM_ITEM_TOTAL,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 8, 11, 23 ) then
                  DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                 'C',DECODE(E.INDCONTRIBICMS,'N',0,A.BASEICMSST),
                                                                     A.BASEICMSST)
                else null
              end as M014_VL_BC_ST_RET,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 8, 11, 23 ) then
                  DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                 'C',DECODE(E.INDCONTRIBICMS,'N',0,A.VLRICMSST),
                                                                     A.VLRICMSST)
                else null
              end as M014_VL_ICMS_ST_RET,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 15 ) then
                  nvl(A.PERALIQICMSSIMPLES,0)
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 14, 18 ) then
                  nvl(DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                     'C',DECODE(E.INDCONTRIBICMS,'N',0,A.PERALIQICMSSIMPLES),
                                                                         A.PERALIQICMSSIMPLES),0)
                else null
              end as M014_VL_PERC_CRED_SN,
              case
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 15 ) then
                  nvl(A.VLRICMSSIMPLES,0)
                when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 14, 18 ) then
                  nvl(DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                     'C',DECODE(E.INDCONTRIBICMS,'N',0,A.VLRICMSSIMPLES),
                                                                         A.VLRICMSSIMPLES),0)
                else null
              end as M014_VL_CRED_ICMS_SN,
              case when a.lancamentost in ('O','S') then
                0
              else
                case
                  when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 1, 3, 9, 10, 12, 13, 14, 18, 19, 20 )
                  then
                    DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                   'C',DECODE(E.INDCONTRIBICMS,'N',0,A.BASEICMSST),
                                                                       A.BASEICMSST)
                  when  nvl(k.tipcgo||k.tipuso||k.tipdocfiscal, a.tipcgo||a.Tipuso||a.tipdocfiscal ) = 'E'||'E'||'C' and fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) = 8
                  then
                    DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                   'C',DECODE(E.INDCONTRIBICMS,'N',0,A.BASEICMSST),
                                                                       A.BASEICMSST)
                  else
                      case when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in (8) then
                         0
                      else
                        null
                      end
                end
              end as M014_VL_BC_ST_ICMS,
              case when a.lancamentost in ('O','S') then
                0
              else
                case
                  when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in ( 1, 3, 9, 10, 12, 13, 14, 18, 19, 20 ) then
                    DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                   'C',DECODE(E.INDCONTRIBICMS,'N',0,A.VLRICMSST),
                                                                       A.VLRICMSST)
                  when  nvl(k.tipcgo||k.tipuso||k.tipdocfiscal, a.tipcgo||a.Tipuso||a.tipdocfiscal ) = 'E'||'E'||'C' and fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) = 8
                  then
                    DECODE(NVL(K.INDEMITEICMSST, vsIndEmiteIcmsSt),'A',0,
                                                                   'C',DECODE(E.INDCONTRIBICMS,'N',0,A.VLRICMSST),
                                                                       A.VLRICMSST)
                  else
                     case when fc5_RetIndSituacaoNF_NFe(A.SITUACAONF, a.nroempresa) in (8, 0) then
                        0
                     else
                        null
                     end
                end
              end as M014_VL_ICMS_ST,
              SUBSTR(NVL(C.CODNBMSH, '00'), 1, 2) as M014_CD_GENERO,
              case when fmap_familiafinalidade(b.seqfamilia, a.nroempresa) = 'S' and
                   fBuscaSeqTribISS(b.seqfamilia, f.seqcidade) is null then
                     '0'
              else
                  fBuscaSeqTribISS(b.seqfamilia, f.seqcidade)
              end as M014_CD_Trib_ISSQN,
              case when i.uf in ('RJ','SC','GO') and a.INDCALCICMSDESONOUTROS = 'S' then
                   NVL(a.MOTIVODESONERACAOICMS, 9)
              else
              case when a.indmotivodesoicms is null then
                 case when a.vlrdescsuframa > 0 then 7
                      when a.vlrdescicms > 0 then 9
                 else null end
              else
                 case when nvl(a.vlrdescsuframa,0) > 0 or nvl(a.vlrdescicms,0) > 0 then a.indmotivodesoicms
                 else null end
                  end
              end as M014_MOTIVO_DES_ICMS,
              A.situacaonf AS m014_CSOSN_C5,
              a.nroadicaodi,
              a.seqadicaodi,
              a.vlrdescadicaodi,
              A.lancamentost AS M014_LANCAMENTOSTC5,
              a.seqproduto,
              b.codigoanp, b.codigoif,
              (CASE
                   WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 THEN
                        'CFOP' || TO_CHAR(A.cfop)
                   ELSE
                       NULL
               END
              )AS M014_CD_PRODUTOAUX_C5,
              (round(
               A.VLRPRODBRUTO * ( FC5BUSCAALIQCARGATRIB(A.SEQPRODUTO, a.nroempresa, a.seqpessoa, 'P', a.codgeraloper, 'P') / 100)
              , 2)) AS M014_VL_TOTTRIB,
              DECODE(vsPDGeraFCI, 'D', J.NROFCI, null) as M014_NRO_FCI_C5,
              a.peraliquotastcargagliq AS M014_VL_PERC_CARGA_LIQ,
              c.codnve as M014_CD_NVE,
              a.nrodrawback AS NRODRAWBACKDIC5,
              b.percgasnatural as M014_VL_PERC_GAS_NATURALC5,
              B.DESCRICAOANP AS M014_DESCRICAOANP,
              B.PERCGASNATURALNACIONAL AS M014_VL_PERCGASNATURALNACIONAL,
              B.PERCGASNATURALIMPORTADO AS M014_VL_PERCGASNATURALIMPORT,
              B.VLRPARTIDAGLP AS M014_VL_VLRPARTIDAGLP,
              decode(a.tipdocfiscal, 'D', fc5_NFePercDevolItem(a.seqnotafiscal, a.seqproduto, a.quantidade, a.SEQNFREF), 0) as M014_VL_PERC_DEVOLC5,
              case when A.TIPOCALCICMSFISCI = 25 then
                        Round(NVL(A.BASEICMS * (A.PERALIQUOTAICMS / 100) * (A.PERALIQICMSDIF / 100), 0),2)
                   else
                        NVL(a.vlricmsdiferido, round(a.baseicms * (a.peraliquotaicms / 100), 2))
              end as M014_VL_ICMS_DIFC5,
              case when A.tipocalcicmsfisci = 25 then
                        round(a.baseicms * (a.peraliquotaicms / 100), 2)
                   else
                        case when a.vlricmsoppropria > 0 then
                             a.vlricmsoppropria
                        else
                            round(a.baseicms * (a.peraliqicmsorig / 100), 2)
                        end
              end as M014_VL_ICMS_OPPROPRIAC5,
              a.vlrdescicms,
              c.papelimune,
              A.PERACRESCST,
              case when vsPDGeraCestGenerico = 'S' and a.codcest is null and A.situacaonf in ('060','090') then '9999999'
              else lpad(a.codcest,7,0)
              end,
              NVL(A.BASCALCICMSPARTILHA, 0) BASCALCICMSPARTILHA,
              A.PERALIQUOTAFCP,
              NVL(A.PERALIQINTPARTILHAICMS, 0) PERALIQINTPARTILHAICMS,
              NVL(A.PERPARTILHAICMS, 0) PERPARTILHAICMS,
              A.VLRFCP,
              A.VLRICMSCALCDESTINO,
              A.VLRICMSCALCORIGEM,
              A.TIPOCALCICMSFISCI,
              A.PERALIQICMSDIF,
              CASE WHEN vsPDUsaPercDescDANFE = 'S' THEN
                     NVL((SELECT SUM(DECODE(X4.INDGERAPERCDESCNF, 'S', X3.PERCINCENTIVO, 0)) PERCINCENTIVOPED
                        FROM MFL_DOCTOFISCAL    X1,
                             MAD_PEDVENDAITEM   X2,
                             MAD_PEDVENDAREGRA  X3,
                             MFL_REGRAINCENTIVO X4
                       WHERE X1.NUMERODF = X2.NUMERODF
                         AND X1.SERIEDF = X2.SERIEDF
                         AND X1.NROSERIEECF = X2.NROSERIEECF
                         AND X1.NROEMPRESA = X2.NROEMPRESA
                         AND X2.NROPEDVENDA = X3.NROPEDVENDA
                         AND X3.SEQREGRA = X4.SEQREGRA
                         AND X2.SEQPRODUTO = A.SEQPRODUTO
                         AND X1.SEQNOTAFISCAL = pnSeqNotaFiscal
                         AND X2.PERCINCENTIVOPED > 0),0)
                    +
                      NVL((SELECT SUM(DECODE(Z3.INDGERAPERCDESCNF, 'S', Z2.PERCINCENTIVOPED, 0))
                        FROM MFL_DOCTOFISCAL Z1, MAD_PEDVENDAITEM Z2, MFL_REGRAINCENTIVO Z3
                       WHERE Z1.NUMERODF = Z2.NUMERODF
                         AND Z1.SERIEDF = Z2.SERIEDF
                         AND Z1.NROSERIEECF = Z2.NROSERIEECF
                         AND Z2.NROEMPRESA = Z2.NROEMPRESA
                         AND Z2.SEQREGRAINCETIVO = Z3.SEQREGRA
                         AND Z2.SEQPRODUTO = A.SEQPRODUTO
                         AND Z1.SEQNOTAFISCAL = pnSeqNotaFiscal
                         AND Z2.PERCINCENTIVOPED > 0),0)
              END,
              A.BASCALCFECP,
              A.PERALIQUOTAFECP,
              A.VLRFECP,
              (CASE WHEN NVL(K.INDGERIPIDEVXML, vsIndGeraIPIDevXML) = 'S'
                     AND NVL(K.INDVLRIPIDADOADICIONAL,vsIndVlrIpiDadoAdic) = 'S'
                     AND A.TIPDOCFISCAL = 'D' AND vsPDVersaoXml = '4'
                    THEN
                         NVL(A.VLRIPIOBSADC, 0)
                    ELSE
                         0
               END) AS M014_VL_IPI_DADOSADIC_C5,
              a.basicmsstdistrib M014_BC_ICMS_ST_DISTRIB,
              a.vlricmsstdistrib M014_VL_ICMS_ST_DISTRIB,
              a.peraliquotaicmsstdistrib M014_VL_ALIQ_ICMS_ST_DISTRIB,
              A.BASEFCPST,
              A.PERALIQFCPST,
              A.VLRFCPST,
              A.BASEFCPICMS,
              A.PERALIQFCPICMS,
              CASE WHEN I.UF = 'RJ' AND NVL(E.UF, F.UF) = 'RJ'
                   THEN CASE WHEN (NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)) < 0
                             THEN 0
                             ELSE NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)
                        END
                   ELSE A.VLRFCPICMS
              END VLRFCPICMS,
              A.BASEFCPDISTRIB,
              A.PERALIQFCPDISTRIB,
              A.VLRFCPDISTRIB,
              A.BASCALCFECPPARTILHA,
              fc5_BuscaCodAjusteEFD(A.CODAJUSTEEFD) AS CODAJUSTEEFD,
              A.PERREDBCICMSEFET,
              A.VLRBASEICMSEFET,
              A.PERALIQICMSEFET,
              A.VLRICMSEFET,
              J.INDESCALARELEVANTE,
              J.CNPJFABRICANTE,
              J.DIGCNPJFABRICANTE,
              A.VLRICMSOPPROPDISTRIB M014_VL_OP_PROP_DIST,
              case when i.uf in ('RJ','SC','GO') and a.INDCALCICMSDESONOUTROS = 'S'
                then a.VLRTOTICMSDESONERADO else 0 end as M014_VLRTOTICMSDESONOUTROS,
              a.perdiferido,
              fc5_NFeCodAcesso(A.NROEMPRESA,
                               A.SEQPRODUTO,
                               DECODE(vsIndIipoEmbDanfeClie,
                                            'M', fminembfamilia(B.SEQFAMILIA),
                                            'V', fminembvendafamiliaativa(B.SEQPRODUTO, A.NROEMPRESA, NVL(A.NROSEGITEM, A.NROSEGMENTO)), A.QTDEMBALAGEM),
                               'N',
                               'B') AS M014_CD_CBARRA,
              fc5_NFeCodAcesso(A.NROEMPRESA, A.SEQPRODUTO, A.QTDEMBALAGEM, 'S', 'B') AS M014_CD_CBARRA_TRIB,
              NULL AS M014_VL_ICMS_ST_DESONERADO,
              NULL AS M014_MOTIVO_DES_ICMS_ST,
              A.PERDIFERIDO AS M014_ALIQ_FCP_ICMS_DIF,
              A.VLRFCPICMSDIFERIDO AS M014_VL_FCP_ICMS_DIF,
              CASE WHEN (NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)) < 0
                THEN 0
                ELSE NVL(A.VLRFCPICMS,0) -  NVL(A.VLRFCPICMSDIFERIDO,0)
              END AS M014_VL_FCP_ICMS_EFET,
              NULL AS M014_DM_SOMA_PISST,
              NULL AS M014_DM_SOMA_COFINSST,
              A.PERALIQICMSMONORETANTERIOR,
              A.VLRICMSMONORETANTERIOR,
              A.BASICMSMONORETANTERIOR,
              A.PERCINDMISTBIODIESEL,
              CASE WHEN fc5_BuscaCodAjusteEFD(A.CODAJUSTEEFD,'P') IS NOT NULL AND A.VLRICMSPRESUMIDO > 0
                   THEN fc5_BuscaCodAjusteEFD(A.CODAJUSTEEFD,'P')
                   ELSE NULL
              END AS M014_CD_CRED_PRESUMIDO,
              NVL(A.PERICMSPRESUMIDO,0) AS M014_ALIQ_CRED_PRESUMIDO,
              A.VLRICMSPRESUMIDO AS M014_VL_CRED_PRESUMIDO,
              fc5_BuscaCodAjusteEFD(A.CODAJUSTEEFD,'D') AS M014_CD_BENEF_RBC,
              DECODE(DECODE(NVL(C.INDDEDUZICMSDESONERADO,'C'),'C',vsPDSubtraiICMSDesonTotItem,C.INDDEDUZICMSDESONERADO),'S','1','0') AS M014_DM_DEDUZ_DESON,
              --Reforma
              NULL AS M014_TP_INDBEMMOVELUSADO,
              decode(vsGERA_ITEM_LIQ_DESC|| A.INDUSAPRECOFIXO,'SN', A.VLRPRODBRUTO
                                                                  - a.VLRDESCONTO
                                                                  + decode(vsPDConsidVlrDescEspecialItem, 'S', 0, nvl( a.vlrdescsf, 0 ) )
                                                                  + DECODE(a.INDSUBTRAIICMSDESONTOTITEM, 'S', decode(a.VLRTOTICMSDESONITEMSUBTRAI,0,a.vlrdescicms,a.VLRTOTICMSDESONITEMSUBTRAI), 0)
                                                                  ,A.VLRPRODBRUTO - DECODE(vsPDConsidVlrDescEspecialItem, 'S', nvl( a.vlrdescsf, 0 ), 0 ) ) +
              CASE WHEN NVL(vsIndConsideraImposto, 'N') = 'S'
                   THEN NVL(A.VLRIMPOSTOIS,0) + NVL(A.VLRIMPOSTOIBSUF,0) + NVL(A.VLRIMPOSTOIBSMUN,0) + NVL(A.VLRIMPOSTOCBS,0)
                   ELSE 0
              END AS M014_VL_VLRITEM,
              --Is
              A.CSTIS AS M014_CD_CSTIS,
              A.CCLASSTRIBIS AS M014_DS_CCLASSTRIBIS,
              A.VLRBASEIS AS M014_VL_VLRBASEIS,
              A.PERALIQIS AS M014_VL_PERALIQIS,
              A.PERALIQEFETIVAIS AS M014_VL_PERALIQEUNIS,
              A.VLRIMPOSTOIS AS M014_VL_VLRIMPOSTOIS,
              (case
                    WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN
                         '0'
                    when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then
                         D.EMBCONVNFE
                    when vsPDVersaoXml = '4'
                      and b.codigoanp in (210203001, 210203003, 210203004, 210203005, 420102004, 420102005,
                                          420105001, 420201001, 420201003, 420301002, 820101001, 820101012,
                                          820101013, 820101033, 820101034, 320101001, 320101002, 320102001,
                                          320102002, 320102003, 320102005, 320201001, 810102001, 810102004,
                                          810102003, 320103001, 320103003, 320301002, 320301001, 320103002)
                      then
                         D.EMBALAGEM -- atualmente deve ser sempre configurado como "KG"
                    else
                         D.EMBALAGEM || SUBSTR(A.QTDEMBALAGEM, 1, 4) END
              ) AS M014_DS_UNTRIBIS,
              (case
                    WHEN fmlf_validanfedeajuste(vnCodGeralOper) = 1 OR nvl(a.indqtdzeradanfcompl, 'N') = 'S' THEN
                         0
                    when (vsIndConvEmbNFe = 'S' or fConvertEmbComercioExterior(vsIndConvEmbNFe, vnEntradaSaida, vsUfDestino, A.CFOP ) = 1) and D.EMBCONVNFE is not null and D.FATORCONVEMBNFE is not null then
                         (A.QUANTIDADE/A.QTDEMBALAGEM)*D.FATORCONVEMBNFE
                    else
                         (A.QUANTIDADE/A.QTDEMBALAGEM)
               END
               ) AS M014_VL_QTDTRIBIS,
              --Ibs
              NVL(A.VLRIMPOSTOIBSUF,0) + NVL(A.VLRIMPOSTOIBSMUN,0) AS M014_VL_VLRIMPOSTOIBS,
              --Ibs Uf
              A.CSTIBSUF AS M014_CD_CSTIBSUF,
              A.CCLASSTRIBIBSUF AS M014_DS_CCLASSTRIBIBSUF,
              A.VLRBASEIBSUF AS M014_VL_VLRBASEIBSUF,
              A.PERALIQIBSUF AS M014_VL_PERALIQIBSUF,
              A.VLRIMPOSTOIBSUF AS M014_VL_VLRIMPOSTOIBSUF,
              A.PERDIFERIMENTOIBSUF AS M014_VL_PERDIFERIDOIBSUF,
              A.VLRDIFERIDOIBSUF AS M014_VL_VLRDIFERIDOIBSUF,
              NULL AS M014_VL_VLRDEVTRIBIBSUF,
              A.PERALIQREDIBSUF AS M014_VL_PERALIQREDIBSUF,
              A.PERALIQEFETIVAIBSUF AS M014_VL_PERALIQEFETIVAIBSUF,
              A.CSTREGULARIBSUF AS M014_CD_CSTREGULARIBSUF,
              A.CCLASSTRIBREGULARIBSUF AS M014_DS_CCLASSTRIBREGULARIBSUF,
              A.PERALIQREGULARIBSUF AS M014_VL_PERALIQREGULARIBSUF,
              A.VLRIMPOSTOREGULARIBSUF AS M014_VL_VLRIMPOSTOREGULARIBSUF,
              A.VLRBASECCREDPRESIBSUF AS M014_VL_VLRBASECCREDPRESIBSUF,
              A.CCREDPRESIBSUF AS M014_CD_CCREDPRESIBSUF,
              A.PERALIQCCREDPRESIBSUF AS M014_VL_PERALIQCCREDPRESIBSUF,
              A.VLRCCREDPRESIBSUF AS M014_VL_VLRCCREDPRESIBSUF,
              NULL AS M014_VL_VLRCCREDPRESCONDSUSIBSUF,
              NULL AS M014_VL_PERALIQCOMPRAGOVIBSUF,
              NULL AS M014_VL_VLRIMPOSTOCOMPRAGOVIBSUF,
              CASE WHEN LPAD(A.CSTIBSUF,3,0) IN ('800') THEN A.VLRIMPOSTOIBSUF END AS M014_VL_VLRIMPOSTOTRANSFERIDOIBS,
              NULL AS M000_TP_INDCREDPRESZFMIBS,
              NULL AS M014_VL_VLRCCREDPRESZFMIBS,
              -- Ibs Mun
              A.CSTIBSMUN AS M014_CD_CSTIBSMUN,
              A.CCLASSTRIBIBSMUN AS M014_DS_CCLASSTRIBIBSMUN,
              A.VLRBASEIBSMUN AS M014_VL_VLRBASEIBSMUN,
              A.PERALIQIBSMUN AS M014_VL_PERALIQIBSMUN,
              A.VLRIMPOSTOIBSMUN AS M014_VL_VLRIMPOSTOIBSMUN,
              A.PERDIFERIMENTOIBSMUN AS M014_VL_PERDIFERIDOIBSMUN,
              A.VLRDIFERIDOIBSMUN AS M014_VL_VLRDIFERIDOIBSMUN,
              NULL AS M014_VL_VLRDEVTRIBIBSMUN,
              A.PERALIQREDIBSMUN AS M014_VL_PERALIQREDIBSMUN,
              A.PERALIQEFETIVAIBSMUN AS M014_VL_PERALIQEFETIVAIBSMUN,
              A.CSTREGULARIBSMUN AS M014_CD_CSTREGULARIBSMUN,
              A.CCLASSTRIBREGULARIBSMUN AS M014_DS_CCLASSTRIBREGULARIBSMUN,
              A.PERALIQREGULARIBSMUN AS M014_VL_PERALIQREGULARIBSMUN,
              A.VLRIMPOSTOREGULARIBSMUN AS M014_VL_VLRIMPOSTOREGULARIBSMUN,
              NULL AS M014_VL_PERALIQCOMPRAGOVIBSMUN,
              NULL AS M014_VL_VLRIMPOSTOCOMPRAGOVIBSMUN,
              -- Cbs
              A.CSTCBS AS M014_CD_CSTCBS,
              A.CCLASSTRIBCBS AS M014_DS_CCLASSTRIBCBS,
              A.VLRBASECBS AS M014_VL_VLRBASECBS,
              A.PERALIQCBS AS M014_VL_PERALIQCBS,
              A.VLRIMPOSTOCBS AS M014_VL_VLRIMPOSTOCBS,
              A.PERDIFERIMENTOCBS AS M014_VL_PERDIFERIMENTOCBS,
              A.VLRIMPOSTOINTEGRALCBS AS M014_VL_VLRIMPOSTOBRUTOCBS,
              A.VLRDIFERIDOCBS AS M014_VL_VLRDIFERIDOCBS,
              NULL AS M014_VL_VLRDEVTRIBCBS,
              A.PERALIQREDCBS AS M014_VL_PERALIQREDCBS,
              A.PERALIQEFETIVACBS AS M014_VL_PERALIQEFETIVACBS,
              A.CSTREGULARCBS AS M014_CD_CSTREGULARCBS,
              A.CCLASSTRIBREGULARCBS AS M014_DS_CCLASSTRIBREGULARCBS,
              A.PERALIQREGULARCBS AS M014_VL_PERALIQREGULARCBS,
              A.VLRIMPOSTOREGULARCBS AS M014_VL_VLRIMPOSTOREGULARCBS,
              A.VLRBASECCREDPRESCBS AS M014_VL_VLRBASECCREDPRESCBS,
              A.CCREDPRESCBS AS M014_CD_CCREDPRESCBS,
              A.PERALIQCCREDPRESCBS AS M014_VL_PERALIQCCREDPRESCBS,
              A.VLRCCREDPRESCBS AS M014_VL_VLRCCREDPRESCBS,
              NULL AS M014_VL_VLRCCREDPRESCONDSUSCBS,
              NULL AS M014_VL_PERALIQCOMPRAGOVCBS,
              NULL AS M014_VL_VLRIMPOSTOCOMPRAGOVCBS,
              CASE WHEN LPAD(A.CSTCBS,3,0) IN ('800') THEN A.VLRIMPOSTOCBS END AS M014_VL_VLRIMPOSTOTRANSFERIDOCBS,
              -- Reforma Mono
              NULL AS M014_VL_QTDE_TRIB_MONO,
              NULL AS M014_VL_PERALIQADREMIBS,
              NULL AS M014_VL_PERALIQADREMCBS,
              NULL AS M014_VL_VLRIMPOSTOMONOIBS,
              NULL AS M014_VL_VLRIMPOSTOMONOCBS,
              NVL(VLRIMPOSTOMONORETIBSUF,0) AS M014_VL_VLRIMPOSTOINTEGRALMONOIBS,
              NVL(VLRIMPOSTOMONORETCBS,0) AS M014_VL_VLRIMPOSTOINTEGRALMONOCBS,
              NULL AS M014_VL_QTDE_TRIB_MONORETENIBS,
              NULL AS M014_VL_PERALIQMONORETENIBS,
              NULL AS M014_VL_VLRIMPOSTOMONORETENIBS,
              NULL AS M014_VL_PERALIQMONORETENCBS,
              NULL AS M014_VL_VLRIMPOSTOMONORETENCBS,
              A.VLRBASEMONORETIBSUF AS M014_VL_QTDE_TRIB_MONORETIBS,
              A.PERALIQMONORETIBSUF AS M014_VL_PERALIQMONORETIBS,
              A.VLRIMPOSTOMONORETIBSUF AS M014_VL_VLRIMPOSTOMONORETIBS,
              A.PERALIQMONORETCBS AS M014_VL_PERALIQMONORETCBS,
              A.VLRIMPOSTOMONORETCBS AS M014_VL_VLRIMPOSTOMONORETCBS,
              NULL AS M014_VL_PERDIFERIMENTOMONOIBS,
              NULL AS M014_VL_VLRDIFERIDOMONOIBS,
              NULL AS M014_VL_PERDIFERIMENTOMONOCBS,
              NULL AS M014_VL_VLRDIFERIDOMONOCBS,
              -- Doc Ref
              -- Giuliano 18/06/26 Adicionado AppOrigem 22
              CASE WHEN vnAppOrigem IN (40,22) THEN A.nfreferencianfechaveacesso END AS M014_DS_CHAVEACESSOREF,
              CASE WHEN vnAppOrigem IN (40,22) THEN A.SeqItemNfRef END AS M014_DS_NROITEMREF,
              --Agropecuario
              A.TIPOGUIAAGRO AS M014_TP_GUIAAGRO,
              A.NRORECEITUARIO AS M014_NR_RECEITUARIO,
              A.CPFRESPTECNICO AS M014_NR_CPFRESPTECNICO,
              A.TIPOGUIATRANSITO AS M014_TP_GUIATRANSITO,
              A.UFGUIA AS M014_UF_GUIA,
              A.SERIEGUIA AS M014_NR_SERIEGUIA,
              A.NROGUIA AS M014_NR_GUIA,
              -- Reforma Estorno
              CASE WHEN A.TIPOFINALIDADENFE = 6 AND A.INDTIPONFCREDITODEBITODET = 7 THEN NVL(A.VLRIMPOSTOIBSUF,0) + NVL(A.VLRIMPOSTOIBSMUN,0) END AS M014_VL_VLRIMPOSTOESTORNOIBS,
              CASE WHEN A.TIPOFINALIDADENFE = 6 AND A.INDTIPONFCREDITODEBITODET = 7 THEN A.VLRIMPOSTOCBS END AS M014_VL_VLRIMPOSTOESTORNOCBS
      FROM    MFLV_BASEDFITEM  A, MAP_PRODUTO        B,
              MAP_FAMILIA      C, MAP_FAMEMBALAGEM   D,
              GE_PESSOA        E, GE_CIDADE          F,
              MAX_EMPSERIENF   G, MAP_FAMDIVISAO     H,
              MAX_EMPRESA      I, MRL_PRODUTOEMPRESA J,
              MAX_CODGERALOPER K
      WHERE   A.SEQPRODUTO    =  B.SEQPRODUTO    AND
              B.SEQFAMILIA    =  C.SEQFAMILIA    AND
              B.SEQFAMILIA    =  D.SEQFAMILIA    AND
              D.QTDEMBALAGEM  =  A.QTDEMBALAGEM  AND
              A.SEQPESSOA     =  E.SEQPESSOA     AND
              E.SEQCIDADE     =  F.SEQCIDADE     AND
              A.NROEMPRESA    =  G.NROEMPRESA    AND
              A.SERIEDF       =  G.SERIENF       AND
              A.SEQNOTAFISCAL =  pnSeqNotaFiscal AND
              A.nroempresa    =  I.NROEMPRESA    AND
              B.SEQFAMILIA    =  H.SEQFAMILIA    AND
              I.NRODIVISAO    =  H.NRODIVISAO    AND
              A.SEQITEMDF     <  990             AND
              A.Tipuso        != 'R'             AND
              FMAP_FAMILIAFINALIDADE(B.SEQFAMILIA, A.NROEMPRESA) not in ('F', 'G', 'D') AND
              J.NROEMPRESA       = A.NROEMPRESA  AND
              J.SEQPRODUTO       = A.SEQPRODUTO  AND
              A.CODGERALOPERITEM = K.CODGERALOPER(+);
              sp_AjusteOutrosAFRMM(vnSeqM000_ID_NF, vsIndImportExport, vsPDCalcBaseIcmsAFRMM, vsPDConsid_Imp_VlrOutras, vnAppOrigem);
     vnSeqNFeDuplicata := 0;
     vsRowID_TMP_SEQUENCE := null;
     if nvl(vsPDGeraDuplicata, 'S') = 'S' OR nvl(vsPDGeraDuplicata, 'S') = 'C'  then
         for vt in (
                 SELECT  (case
                            when vsPDTipGeraCartaoDanfe = 'C' then A.DTAVENCIMENTO
                            when vsPDTipGeraCartaoDanfe = 'A' then nvl(B.DTAVENCIMENTO, B.DTAVENCIMENTO)  end )as M004_DT_VENCIMENTO,
                         (case
                            when vsPDConsideraDescSFDuplic = 'M' then
                                 A.VLRORIGINAL
                            else A.VLRORIGINAL - (case
                                                    when C.CODESPECIESF is null then
                                                         NVL(B.VLRDESCSF, 0)
                                                    else 0
                                                  end)
                          end) -
                          (case
                            when vsPDDeduzDescComercDuplic = 'S' then
                                 NVL(A.VLRDESCCOMERC, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzVlrIndenizacaoDuplic = 'S' then
                                 NVL(A.VLRINDENIZACAO, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescFunRuralDuplic = 'S' then
                                 NVL(A.VLRDESCFUNRURAL, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescIcmsDuplic = 'S' then
                                 NVL(A.VLRDESCICMS, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescPisDuplic = 'S' then
                                 NVL(A.VLRDESCPIS, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescCofinsDuplic = 'S' then
                                 NVL(A.VLRDESCCOFINS, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescCSLLDuplic = 'S' then
                                 NVL(A.VLRDESCCSLL, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescIRDuplic = 'S' then
                                 NVL(A.VLRDESCIR, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescINSSDuplic = 'S' then
                                 NVL(A.VLRDESCINSS, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescISSDuplic = 'S' then
                                 NVL(A.VLRDESCISS, 0)
                            else 0
                          end) -
                          (case
                            when vsPDDeduzDescFinancDuplic = 'S' then
                                 A.VLRDSCFINANC
                            else 0
                          end) as M004_VL_DUPLICATA,
                         LPAD(A.NROPARCELA, 3, '0') as M004_NR_DUPLICATA,
                         vnSeqM000_ID_NF as M000_ID_NF
                 FROM    MRL_TITULOFIN A,
                         MFLV_BASENF B,
                         MAX_CODGERALOPER C
                 WHERE   A.NROEMPRESA = B.NROEMPRESA
                 AND     A.NRODOCUMENTO = B.NUMERODF
                 AND     A.SEQPESSOA = B.SEQPESSOA
                 AND     A.SERIEDOC = B.SERIEDF
                 AND     B.SEQNOTAFISCAL = pnSeqNotaFiscal
                 AND     B.CODGERALOPER = C.CODGERALOPER
                 AND     (vsPDGeraDuplicata = 'S' OR
                         (vsPDGeraDuplicata = 'C' AND
                          B.CODGERALOPER NOT IN (select COLUMN_VALUE
                            from table(cast(c5_ComplexIn.c5InTable(nvl(trim(vsPDCgo_N_GeraDuplicataNfe), 0)) as
                                c5InStrTable)) where COLUMN_VALUE is not null)))
                 AND     NVL(C.INDDESCSFCONFFAT, 'N') = (case
                                                           when vsPDConsideraDescSFDuplic = 'M' then
                                                                NVL(C.INDDESCSFCONFFAT, 'N')
                                                           else 'N'
                                                         end)
                 AND     A.CODESPECIE != (case
                                            when vsPDConsideraDescSFDuplic = 'M' then
                                                 ' '
                                            else (case
                                                    when SIGN(B.VLRDESCSF) = 0 then
                                                         ' '
                                                    else NVL(C.CODESPECIESF, ' ')
                                                  end)
                                          end)
                 AND     A.LINKERP = B.LINKERP
                 AND     B.tipuso != 'R'
                 AND     NVL(A.ORIGEMTITULO, 'F') != 'G'
                 AND     (TRIM(vsPDFormaPagtoNaoGeraFatura) IS NULL OR (TRIM(vsPDFormaPagtoNaoGeraFatura) IS NOT NULL AND
                                                                        A.Nroformapagto NOT IN (SELECT COLUMN_VALUE FROM TABLE(cast(c5_ComplexIn.c5InTable(vsPDFormaPagtoNaoGeraFatura) as c5InStrTable)))))
                 order by 1, M004_NR_DUPLICATA)
              loop
                 if vt.M004_VL_DUPLICATA > 0 then
                         if  vsRowID_TMP_SEQUENCE is null and
                             vsSoftwarePDV = 'OPHOSNFE' then
                             vsSelect := '
                             select COUNT(1)
                             from   TMP_SEQUENCE A
                             where  A.SEQUENCENAME = ' || CHR(39) || 'TMP_M004_DUPLICATA' || CHR(39) || ' ';
                             EXECUTE IMMEDIATE vsSelect INTO vnCount;
                             if  vnCount = 0 then
                                 vsSelect := '
                                 INSERT INTO TMP_SEQUENCE(
                                        SEQUENCENAME,
                                        GENERATEDID )
                                 VALUES(' || CHR(39) || 'TMP_M004_DUPLICATA' || CHR(39) || ',
                                        0)' ;
                                 EXECUTE IMMEDIATE vsSelect;
                             end if;
                             vsSelect := '
                             select A.ROWID,
                                    nvl(A.GENERATEDID,0)
                             from   TMP_SEQUENCE A
                             where  A.SEQUENCENAME = ' || CHR(39) || 'TMP_M004_DUPLICATA' || CHR(39) || '
                             for    update';
                             EXECUTE IMMEDIATE vsSelect INTO vsRowID_TMP_SEQUENCE, vnSeqNFeDuplicata;
                         end if;
                         if((vsPDTipGeraCartaoDanfe = 'A' and not vbInseriuDuplicata) or
                            (vsPDTipGeraCartaoDanfe = 'C')) then
                           vnSeqNFeDuplicata := vnSeqNFeDuplicata + 1;
                           if(vsSoftwarePDV = 'OPHOSNFE') then
                             vnIdDuplicata := vnSeqNFeDuplicata;
                           else
                             select S_SEQNFEDUPLICATA.Nextval
                               into vnIdDuplicata
                               from dual;
                           end if;
                           insert into TMP_M004_DUPLICATA(
                                  M004_ID_DUPLICATA,
                                  M004_DT_VENCIMENTO,
                                  M004_VL_DUPLICATA,
                                  M004_NR_DUPLICATA,
                                  M000_ID_NF )
                           values (vnIdDuplicata,
                                   vt.M004_DT_VENCIMENTO,
                                   vt.M004_VL_DUPLICATA,
                                   vt.M004_NR_DUPLICATA,
                                   vt.M000_ID_NF);
                           vbInseriuDuplicata := true;
                         else
                           update TMP_M004_DUPLICATA
                              set M004_VL_DUPLICATA = M004_VL_DUPLICATA + vt.M004_VL_DUPLICATA
                            where M004_ID_DUPLICATA = vnIdDuplicata;
                         end if;
                 end if;
        end loop;
     end if;
      if  vsRowID_TMP_SEQUENCE is not null and vnSeqNFeDuplicata > 0 and
          vsSoftwarePDV = 'OPHOSNFE' then
          vsSelect := '
          update TMP_SEQUENCE A
          set    A.GENERATEDID = ' || vnSeqNFeDuplicata ||'
          where  A.ROWID = ' || CHR(39) || vsRowID_TMP_SEQUENCE || CHR(39);
          EXECUTE IMMEDIATE vsSelect;
      end if;
      IF vsPDConsisteDetPagtoTpIntegra = 'S' THEN
        -- Detalhamento da forma de pagamento
        INSERT INTO TMP_M005_DETPAGTO (M000_ID_NF, M000_FORMAPAGTONFE, M005_ID_DETPAGTO, M005_INDPAG, M005_VLRLANCTO,
                                       M005_TPINTEGRA, M005_CNPJCARTAO, M005_TBANDCARTAO, M005_CAUTCARTAO, M005_DPAG,
                                       M005_CNPJPAG, M005_UFPag, M005_CNPJRECEB, M005_IDTERMPAG)
          SELECT M000_ID_NF,
                 M000_FORMAPAGTONFE,
                 ROWNUM AS M005_ID_DETPAGTO,
                 M005_INDPAG,
                 M005_VLRLANCTO,
                 M005_TPINTEGRA,
                 M005_CNPJCARTAO,
                 M005_TBANDCARTAO,
                 M005_CAUTCARTAO,
                 M005_DPAG,
                 M005_CNPJPAG,
                 M005_UFPag,
                 M005_CNPJRECEB,
                 M005_IDTERMPAG
            FROM (SELECT vnSeqM000_ID_NF AS M000_ID_NF,
                         fNFeFormaPagto(CASE
                                          WHEN vsSoftwarePDV = 'NDDIGITAL' AND vsPDVersaoXml in('4') THEN
                                            CASE
                                              WHEN D.TIPOFINALIDADENFE IS NULL THEN
                                                CASE
                                                  WHEN D.INDNFEAJUSTE = 'S' THEN
                                                    3
                                                  WHEN D.INDCOMPLVLRIMP = 'S' THEN
                                                    2
                                                  WHEN D.TIPDOCFISCAL = 'D' THEN
                                                    DECODE(D.TROCACOMODATO, 'S', 1, 4)
                                                  ELSE
                                                    1
                                                END
                                              ELSE
                                                D.TIPOFINALIDADENFE
                                            END
                                          ELSE
                                            CASE
                                              WHEN D.INDNFEAJUSTE = 'S' THEN
                                                2
                                              ELSE
                                                DECODE(D.INDCOMPLVLRIMP,'S',1,0)
                                            END
                                        END, 1, E.NROFORMAPAGTO) AS M000_FORMAPAGTONFE,
                         NVL((SELECT MAX(1)
                                FROM MRL_TITULOFIN C
                               WHERE C.NROEMPRESA = A.NROEMPRESA
                                 AND C.NRODOCUMENTO = A.NUMERODF
                                 AND C.SEQPESSOA = A.SEQPESSOA
                                 AND C.SERIEDOC =  A.SERIEDF
                                 AND TRUNC(C.DTAVENCIMENTO) > TRUNC(C.DTAEMISSAO)), 0) AS M005_INDPAG,
                         C.VLRLANCTO AS M005_VLRLANCTO,
                         CASE
                           WHEN CNPJCREDTEF IS NOT NULL THEN
                             1
                           ELSE
                             2
                         END AS M005_TPINTEGRA,
                         C.CNPJCREDTEF AS M005_CNPJCARTAO,
                         fc5_NFeBandeiraCartao(LPAD(C.CODBANDEIRA, 5, '0')) AS M005_TBANDCARTAO,
                         C.CODAUTORIZACAOTEF AS M005_CAUTCARTAO,
                         TRUNC(C.DTAHORLANCTO) AS M005_DPAG,
                         NULL AS M005_CNPJPAG,
                         NULL AS M005_UFPag,
                         (SELECT NVL(F.M001_NR_CNPJ, NULL)
                            FROM TMP_M001_EMITENTE F
                           WHERE F.M000_ID_NF = vnSeqM000_ID_NF) AS M005_CNPJRECEB,
                         NVL(C.NROCHECKOUT,B.NROCHECKOUTPDV) AS M005_IDTERMPAG
                    FROM MFL_DOCTOFISCAL A,
                         MFL_DFFINANCEIRO B,
                         MFL_FINANCEIRO C,
                         MAX_CODGERALOPER D,
                         MRL_FORMAPAGTO E
                   WHERE A.NUMERODF = B.NUMERODF
                     AND A.SERIEDF = B.SERIEDF
                     AND A.NROSERIEECF = B.NROSERIEECF
                     AND A.NROEMPRESA = B.NROEMPRESA
                     AND A.SEQNF = B.SEQNF
                     AND A.CODGERALOPER = D.CODGERALOPER
                     AND B.SEQFINANCEIRO = C.SEQFINANCEIRO
                     AND C.NROFORMAPAGTO = E.NROFORMAPAGTO
                     AND E.ESPECIEFORMAPAGTO IN ('D', 'R', 'E', 'J')
                     AND A.SEQNOTAFISCAL = pnSeqNotaFiscal
                     AND A.APPORIGEM = 7
                     AND NVL(C.STATUSTEF, 'V') != 'C'
                  UNION ALL
                  SELECT vnSeqM000_ID_NF AS M000_ID_NF,
                         fNFeFormaPagto(CASE
                                          WHEN vsSoftwarePDV = 'NDDIGITAL' AND vsPDVersaoXml in('4') THEN
                                            CASE
                                              WHEN D.TIPOFINALIDADENFE IS NULL THEN
                                                CASE
                                                  WHEN D.INDNFEAJUSTE = 'S' THEN
                                                    3
                                                  WHEN D.INDCOMPLVLRIMP = 'S' THEN
                                                    2
                                                  WHEN D.TIPDOCFISCAL = 'D' THEN
                                                    DECODE(D.TROCACOMODATO, 'S', 1, 4)
                                                  ELSE
                                                    1
                                                END
                                              ELSE
                                                D.TIPOFINALIDADENFE
                                            END
                                          ELSE
                                            CASE
                                              WHEN D.INDNFEAJUSTE = 'S' THEN
                                                2
                                              ELSE
                                                DECODE(D.INDCOMPLVLRIMP,'S',1,0)
                                            END
                                        END, 1, E.NROFORMAPAGTO) AS M000_FORMAPAGTONFE,
                         NVL((SELECT MAX(1)
                                FROM MRL_TITULOFIN C
                               WHERE C.NROEMPRESA = A.NROEMPRESA
                                 AND C.NRODOCUMENTO = A.NUMERODF
                                 AND C.SEQPESSOA = A.SEQPESSOA
                                 AND C.SERIEDOC =  A.SERIEDF
                                 AND TRUNC(C.DTAVENCIMENTO) > TRUNC(C.DTAEMISSAO)), 0) AS M005_INDPAG,
                         E.VALOR AS M005_VLRLANCTO,
                         CASE
                           WHEN E.NROCGCCPFCARTAO IS NOT NULL THEN
                             1
                           ELSE
                             2
                         END AS M005_TPINTEGRA,
                         E.CNPJINSTITUICAOPAGTO AS M005_CNPJCARTAO,
                         fc5_NFeBandeiraCartao(LPAD(E.CODBANDEIRA, 5, '0')) AS M005_TBANDCARTAO,
                         NVL((SELECT MAX(Z.NROAUTORIZACAO)
                                FROM MAD_PEDVENDANSU Z
                               WHERE Z.NROPEDVENDA = E.NROPEDVENDA
                                 AND Z.NROFORMAPAGTO = E.NROFORMAPAGTO
                                 AND Z.REDE = E.CODOPERADORACARTAO
                                 AND Z.BIN = E.CODBIN), E.NROAUTORIZACAO) AS M005_CAUTCARTAO,
                         E.DTAMOVIMENTO AS M005_DPAG,
                         E.CNPJTRANSACIONALPAGTO AS M005_CNPJPAG,
                         E.UFTRANSACIONALPAGTO AS M005_UFPag,
                         NULL AS M005_M005_CNPJRECEB,
                         NULL AS M005_IDTERMPAG
                    FROM MFL_DOCTOFISCAL A,
                         MAD_PEDVENDA C,
                         MAX_CODGERALOPER D,
                         MAD_PEDVENDAFORMAPAGTO E,
                         MRL_FORMAPAGTO F
                   WHERE EXISTS (SELECT 1
                                   FROM MFL_DFITEM B, MAD_PEDVENDAITEM D
                                  WHERE A.NUMERODF = B.NUMERODF
                                    AND A.SERIEDF = B.SERIEDF
                                    AND A.NROSERIEECF = B.NROSERIEECF
                                    AND A.NROEMPRESA = B.NROEMPRESA
                                    AND A.SEQNF = B.SEQNF
                                    AND D.NUMERODF = B.NUMERODF
                                    AND D.SERIEDF = B.SERIEDF
                                    AND D.NROSERIEECF = B.NROSERIEECF
                                    AND D.NROEMPRESADF = B.NROEMPRESA
                                    AND D.NROPEDVENDA = C.NROPEDVENDA
                                    AND D.NROEMPRESA = C.NROEMPRESA)
                     AND A.SEQNOTAFISCAL = pnSeqNotaFiscal
                     AND A.CODGERALOPER = D.CODGERALOPER
                     AND F.NROFORMAPAGTO = E.NROFORMAPAGTO
                     AND C.NROPEDVENDA = E.NROPEDVENDA
                     AND C.NROEMPRESA = E.NROEMPRESA
                     AND C.INDECOMMERCE = 'S'
                     AND F.ESPECIEFORMAPAGTO IN ('D', 'R', 'E', 'J'));
      END IF;
      IF vsPD_ConcatNfRefObsNF = 'S' or (vsPD_ConcatNfRefObsNF = 'N' and (vnAppOrigem != 2 OR vsTipoDoctoFiscal = 'D')) THEN
          if  vsSoftwarePDV = 'OPHOSNFE' then
              vnSeqM013_ID_CHAVE_REF := fBuscaSeqTmpOphus('TMP_M013_CHAVE_REF');
          end if;
          BEGIN
            SELECT NVL(CASE WHEN MAX(I.M014_DS_CHAVEACESSOREF) is not null AND MAX(I.M014_DS_NROITEMREF) is not null
                        THEN 'S'
                        ELSE 'N'
                        END,'N')
              INTO vsGeraNFRefDetItem
              FROM TMP_M014_ITEM I
             WHERE I.M000_ID_NF = pnSeqNotaFiscal;
          EXCEPTION WHEN OTHERS THEN
            vsGeraNFRefDetItem := 'N';
          END;
          INSERT INTO TMP_M013_CHAVE_REF(
                 M013_ID_CHAVE_REF,
                 M013_NR_CNPJ,
                 M013_NR_MODELO,
                 M013_NR_IBGE_UF,
                 M013_NR_SERIE,
                 M013_NR_CHAVE_ACESSO_REF,
                 M013_NR_DOCUMENTO,
                 M013_DT_EMISSAO,
                 M000_ID_NF,
                 M013_TIPO_CHAVE,
                 M013_NR_CPF,
                 M013_NR_IE,
                 M013_NR_ECF,
                 M013_NR_COO)
          SELECT S_SEQNFECHAVEREF.NEXTVAL + nvl(vnSeqM013_ID_CHAVE_REF, 0) AS M013_ID_CHAVE_REF,
                 case
                   when A.M013_TIPO_CHAVE = 3 and A.FISICAJURIDICA = 'F' then
                        case when nvl(A.INDPRODUTORRURAL, 'N') = 'S' and
                                  A.M013_NR_CNPJ_PRODRURAL is not null then
                                  A.M013_NR_CNPJ_PRODRURAL
                             else
                                  null
                        end
                   else
                        A.M013_NR_CNPJ
                 end as M013_NR_CNPJ,
                 case
                   when A.M013_TIPO_CHAVE = 3 then decode(A.M013_NR_MODELO,'55','04', '04', '04', '01')
                   when A.M013_TIPO_CHAVE = 4 then nvl(A.M013_NR_MODELO,'2D')
                   else decode(A.M013_NR_MODELO, '1B','01',A.M013_NR_MODELO)
                 end as M013_NR_MODELO,
                 A.M013_NR_IBGE_UF,
                 A.M013_NR_SERIE,
                 A.M013_NR_CHAVE_ACESSO_REF,
                 A.M013_NR_DOCUMENTO,
                 A.M013_DT_EMISSAO,
                 vnSeqM000_ID_NF,
                 A.M013_TIPO_CHAVE,
                 case
                   when A.M013_TIPO_CHAVE = 3 and A.FISICAJURIDICA = 'F' then
                        case when nvl(A.INDPRODUTORRURAL, 'N') = 'S' and
                                  A.M013_NR_CNPJ_PRODRURAL is not null then
                                  null
                             else
                                  A.M013_NR_CPF
                        end
                   else
                        NULL
                 end as M013_NR_CPF,
                 case
                   when A.M013_TIPO_CHAVE = 3 then substr(A.M013_NR_IE, 0, 14)
                   else NULL
                 end as M013_NR_IE,
                 case
                   when A.M013_TIPO_CHAVE = 4 then substr(A.M013_NR_ECF,0,3)
                   else null
                 end as M013_NR_ECF,
                 case
                   when A.M013_TIPO_CHAVE = 4 then substr(A.M013_NR_COO,0,6)
                   else null
                 end as M013_NR_COO
            FROM MFLV_BASENFREF_NFE A
           WHERE A.M000_ID_NF = pnSeqNotaFiscal
             AND ((nvl(vnIndTipoFinalidadeNfe, 0) = 5 and nvl(vnIndTipoNfCreditoDebitodet, 0) in (1, 3, 4))
                   or (nvl(vnIndTipoFinalidadeNfe, 0) = 6 and  nvl(vnIndTipoNfCreditoDebitodet, 0) not in (3, 4) and vsGeraNFRefDetItem = 'N')
                   or (vnAppOrigem = 40 and vsGeraNFRefDetItem = 'N')
                   or (vnAppOrigem != 40 or vnAppOrigem is null));
      END IF;
      INSERT INTO TMP_M006_TRANSPORTE(
              M000_ID_NF, M006_VL_BC_RET_ICMS, M006_VL_ALIQ_RET,
              M006_DM_FRETE, M006_VL_RET_ICMS, M006_NM_TRANSP,
              M006_NR_CFOP, M006_NM_LOGR, M006_NR_IBGE_MUN_FG,
              M006_DS_UF, M006_DS_PLACA, M006_DS_UF_PLACA,
              M006_NR_IE, M006_NR_RNTC, M006_VL_SERV,
              M006_DS_MUN, M006_NR_CNPJ_CPF, M006_IDENTIFICA_BALSA)
      SELECT vnSeqM000_ID_NF as M000_ID_NF,
             (CASE WHEN A.TIPOFRETE IN ('F','D') THEN NULL
                   WHEN A.TIPOFRETE in ('C','R','T') AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                        fMfl_RetValoresFreteNFe(A.SEQNOTAFISCAL, A.NROEMPRESA, 'B')
                   ELSE null END ) as M006_VL_BC_RET_ICMS,
             (CASE WHEN A.TIPOFRETE IN ('F','D') THEN NULL
                   WHEN A.TIPOFRETE in ('C','R','T') AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                        fMfl_RetValoresFreteNFe(A.SEQNOTAFISCAL, A.NROEMPRESA, 'A')
                   ELSE null END ) as M006_VL_ALIQ_RET,
              fBuscaTipoFreteTransp(A.SEQNOTAFISCAL,A.NROCARGA,A.NROEMPRESA,A.TIPOFRETE,A.SEQTRANSPORTADOR) as M006_DM_FRETE,
             (CASE WHEN A.TIPOFRETE IN ('F','D') THEN NULL
                   WHEN A.TIPOFRETE in ('C','R','T') AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                        fMfl_RetValoresFreteNFe(A.SEQNOTAFISCAL, A.NROEMPRESA, 'V')
                   ELSE null END ) as M006_VL_RET_ICMS,
             SUBSTR(((CASE WHEN A.tipofrete IN ('F','D') THEN SUBSTR(C.NOMERAZAO, 1, 60)
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL THEN C.NOMERAZAO
                   ELSE null END ) ||
              (CASE WHEN vsPDExibeSeqTransportDanfe = 'S' and A.SEQTRANSPORTADOR IS NOT NULL THEN
                    ' - ' || A.SEQTRANSPORTADOR
               END) ), 1, 60)  as M006_NM_TRANSP ,
             (CASE WHEN A.tipofrete IN ('F','D') THEN NULL
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                        nvl(decode(a.ufdestino, 'EX',     e.cfopexteriornfetransp,
                                                f.estado, e.cfopestadonfetransp,
                                                          e.cfopforaestadonfetransp), 0)
                   ELSE null END ) as M006_NR_CFOP,
             (CASE WHEN A.tipofrete IN ('F','D') THEN C.LOGRADOURO || ' ' || C.NROLOGRADOURO || ' ' || C.CMPLTOLOGRADOURO
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL THEN C.LOGRADOURO || ' ' || C.NROLOGRADOURO || ' ' || C.CMPLTOLOGRADOURO
                   ELSE null END ) as M006_NM_LOGR,
             (CASE WHEN A.tipofrete IN ('F','D') THEN NULL
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                        nvl(D.CODIBGE, 0)
                   ELSE null END ) as M006_NR_IBGE_MUN_FG,
             (CASE WHEN A.tipofrete IN ('F','D') THEN C.UF
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL THEN C.UF
                   ELSE null END ) as M006_DS_UF,
             (CASE WHEN A.tipofrete IN ('F','D') THEN SUBSTR(REGEXP_REPLACE(TRIM(A.PLACAVEICULO),'[ !"@#$%¨&*()_+={ª}º|\,<.>;:?/°^~¹²³£¢¬ -]',NULL),1,8)
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' THEN SUBSTR(REGEXP_REPLACE(TRIM(A.PLACAVEICULO),'[ !"@#$%¨&*()_+={ª}º|\,<.>;:?/°^~¹²³£¢¬ -]',NULL),1,8)
                   ELSE null END ) as M006_DS_PLACA,
             (CASE WHEN A.tipofrete IN ('F','D') THEN A.ufplacaveiculo
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' THEN A.ufplacaveiculo
                   ELSE null END ) as M006_DS_UF_PLACA,
             (CASE WHEN F.ESTADO = 'BA' THEN
                   (CASE WHEN NVL(C.INDCONTRIBICMS,'N') = 'N' THEN
                              NULL
                         WHEN C.FISICAJURIDICA = 'F' AND vsPDInscRgPesFisicaTransp = 'S' THEN
                              'ISENTO'
                         ELSE
                              (CASE WHEN A.TIPOFRETE IN ('F','D') THEN C.INSCRICAORG
                                    WHEN A.TIPOFRETE in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.SEQTRANSPORTADOR IS NOT NULL THEN C.INSCRICAORG
                                    ELSE NULL END )
                    END)
              ELSE
                   (CASE WHEN C.FISICAJURIDICA = 'F' AND vsPDInscRgPesFisicaTransp = 'S' THEN
                              'ISENTO'
                         ELSE
                              (CASE WHEN A.TIPOFRETE IN ('F','D') THEN C.INSCRICAORG
                                    WHEN A.TIPOFRETE in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.SEQTRANSPORTADOR IS NOT NULL THEN C.INSCRICAORG
                                    ELSE NULL END )
                    END)
              END) as M006_NR_IE,
                (CASE WHEN A.tipofrete IN ('F','D') THEN B.CODRNTRC
                      WHEN A.tipofrete in ('C','R','T')
                           AND vsEMITE_TRANSPOR_CIF = 'S'
                           AND A.seqtransportador IS NOT NULL
                      THEN B.CODRNTRC
                      ELSE NULL
                      END ) as M006_NR_RNTC,
             (CASE WHEN A.TIPOFRETE IN ('F','D') THEN
                          NULL
                   WHEN A.TIPOFRETE in ('C','R','T') AND
                        vsEMITE_TRANSPOR_CIF = 'S' AND
                        A.SEQTRANSPORTADOR IS NOT NULL AND
                        C.NROCGCCPF IS NOT NULL AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                          A.VLRFRETE
                   WHEN A.TIPOFRETE in ('C','R','T') AND
                        vsEMITE_TRANSPOR_CIF = 'S' AND
                        A.SEQTRANSPORTADOR IS NOT NULL AND
                        C.NROCGCCPF IS NULL AND
                        B.INDTIPOTRANSPORTADOR = 'T' AND
                        B.INDGERAFRETETERC = 'S' AND
                        NVL(B.PERBASEICMSFRETETERC,0) > 0 THEN
                           0
                   ELSE
                          null END ) as M006_VL_SERV,
             (CASE WHEN A.tipofrete IN ('F','D') THEN C.CIDADE
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL THEN C.CIDADE
                   ELSE null END ) as M006_DS_MUN,
             (CASE WHEN A.tipofrete IN ('F','D') THEN LPAD(C.NROCGCCPF,DECODE(C.FISICAJURIDICA, 'F',9,12),'0') || LPAD(C.DIGCGCCPF,2,'0')
                   WHEN A.tipofrete in ('C','R','T') AND vsEMITE_TRANSPOR_CIF = 'S' AND A.seqtransportador IS NOT NULL THEN LPAD(C.NROCGCCPF,DECODE(C.FISICAJURIDICA, 'F',9,12),'0') || LPAD(C.DIGCGCCPF,2,'0')
                   ELSE null END ) as M006_NR_CNPJ_CPF, a.NomeEmbarcacao as M006_IDENTIFICA_BALSA
      FROM    MFLV_BASENF A, GE_PESSOA C, GE_CIDADE D,
              MAD_TRANSPORTADOR B, MAD_PARAMETRO E, GE_EMPRESA F
      WHERE   A.SEQTRANSPORTADOR = C.SEQPESSOA(+)   AND
              A.SEQTRANSPORTADOR = B.SEQTRANSPORTADOR(+) AND
              C.SEQCIDADE        = D.SEQCIDADE(+)   AND
              A.SEQNOTAFISCAL    = pnSeqNotaFiscal  AND
              A.NROEMPRESA       = E.NROEMPRESA     AND
              E.NROEMPRESA       = F.NROEMPRESA     AND
              A.tipuso           != 'R';
      if vsEMITE_QTDVOLUME_WMS = 'U' then
        if VSPDGERASEPARACAOPED = 'S' then
          SELECT MIN(AA.SEQNOTAFISCAL)
           INTO vnSeqNotaFiscalVolume
           FROM MFL_DOCTOFISCAL AA, MFLV_BASEDFITEM Z
          WHERE AA.NROPEDIDOVENDA = (SELECT BB.NROPEDIDOVENDA
                                       FROM MFL_DOCTOFISCAL BB
                                      WHERE BB.SEQNOTAFISCAL = Z.SEQNOTAFISCAL)
            AND AA.SEQNOTAFISCAL  >= (SELECT BB.SEQNOTAFISCAL
                                       FROM MFL_DOCTOFISCAL BB
                                      WHERE BB.SEQNOTAFISCAL = Z.SEQNOTAFISCAL)
            AND Z.SEQNOTAFISCAL = pnSeqNotaFiscal;
        else
          SELECT MAX(AA.SEQNOTAFISCAL)
           INTO vnSeqNotaFiscalVolume
           FROM MFL_DOCTOFISCAL AA, MFLV_BASEDFITEM Z
          WHERE AA.NROCARGA = (SELECT BB.NROCARGA
                                 FROM MFL_DOCTOFISCAL BB
                                WHERE BB.SEQNOTAFISCAL = Z.SEQNOTAFISCAL
                                  AND BB.SEQPESSOA = AA.SEQPESSOA)
            AND AA.SEQNOTAFISCAL >= (SELECT BB.SEQNOTAFISCAL
                                      FROM MFL_DOCTOFISCAL BB
                                     WHERE BB.SEQNOTAFISCAL = Z.SEQNOTAFISCAL
                                       AND BB.SEQPESSOA = AA.SEQPESSOA)
            AND AA.SEQPESSOA = Z.SEQPESSOA
            AND Z.SEQNOTAFISCAL = pnSeqNotaFiscal;
        end if;
      end if;
      INSERT INTO TMP_M008_VOLUME(
               M008_ID_VOLUME,
               M008_NR_IDENT,
               M008_VL_PL,
               M008_DS_ESPECIE,
               M008_VL_PB,
               M008_VL_QTDE,
               M008_DS_MARCA,
               M000_ID_NF)
      SELECT case when vsSoftwarePDV = 'OPHOSNFE' then
                    fBuscaSeqTmpOphus('TMP_M008_VOLUME')
                else
                    S_SEQNFEVOLUME.NEXTVAL
                end  as M008_ID_VOLUME,
             case when Z.INDEXPORTACAO = 'S' then
                       case when Z.NUMEROVOLUME is not null then
                                 Z.NUMEROVOLUME
                            else
                                 case when vsPD_InfoNumVolume != 'N' then
                                           SUBSTR(vsPD_InfoNumVolume, 1, 60)
                                      else
                                           null
                                 end
                       end
                  else
                       null
             end AS M008_NR_IDENT,
             ROUND(Z.PESOLIQUIDO, 3) as M008_VL_PL,
             substr(NVL(Z.ESPECIETRANSPPED, NVL(Z.ESPECIEVOLUMENF, decode(nvl(vsPD_InfoEspecVolume,'N'),'N',null, vsPD_InfoEspecVolume))),1,60) as M008_DS_ESPECIE,
             ROUND(Z.PESOBRUTO, 3) as M008_VL_PB,
             Decode( Z.SEQNOTAFISCAL,
                       nvl(vnSeqNotaFiscalVolume, Z.SEQNOTAFISCAL),
                         Case when (vsPDTipoNFEmissaoVolume = 'I' and  z.INDIMPORTEXPORT = 'S')
                              or (vsPDTipoNFEmissaoVolume = 'T') then
                                NVL(Z.QTDVOLTRANSPPED, DECODE(vsEMITE_QTDVOLUME_WMS, 'N', nvl(QtdVolumeNF,QtdVolumeItem), Z.QTDVOLUMEWM))
                         else
                           null
                         end,
                       NULL
             ) as M008_VL_QTDE,
             case when Z.INDEXPORTACAO = 'S' then
                       case when Z.MARCAVOLUME is not null then
                                 Z.MARCAVOLUME
                            else
                                 case when vsPD_InfoMARCAVolume != 'N' then
                                           SUBSTR(vsPD_InfoMARCAVolume, 1, 60)
                                      else
                                           null
                                 end
                       end
                  else
                       null
             end AS M008_DS_MARCA,
             vnSeqM000_ID_NF as M000_ID_NF
      FROM (
            SELECT NVL(A.PESOLIQUIDONF, SUM(B.PESOLIQUIDO * (A.QUANTIDADE / A.QTDEMBALAGEM))) PESOLIQUIDO,
                   NVL(A.PESOBRUTONF,SUM( B.PESOBRUTO * (A.QUANTIDADE / A.QTDEMBALAGEM))) PESOBRUTO,
                   A.ESPECIEVOLUMENF ESPECIEVOLUMENF,
                   NVL(A.QTDVOLUMENF, decode(FMAD_VOLUMECLIENTE(NVL(A.NROCARGA, A.NROCARGANOTABASECUPOM), NVL( A.NROEMPRESAPED, A.NROEMPRESA ), A.SEQPESSOA, DECODE( vsPDGeraSeparacaoPed, 'S', A.NROPEDIDOVENDA, NULL), A.INDFATCRUZADO ),0,
                       A.QTDVOLUMEITEM,
                       FMAD_VOLUMECLIENTE(NVL(A.NROCARGA, A.NROCARGANOTABASECUPOM), NVL( A.NROEMPRESAPED, A.NROEMPRESA ), A.SEQPESSOA, DECODE( vsPDGeraSeparacaoPed, 'S', A.NROPEDIDOVENDA, NULL), A.INDFATCRUZADO ))) QTDVOLUMEWM,
                   A.SEQNOTAFISCAL,
                   SUM(A.QUANTIDADE / A.QTDEMBALAGEM) QtdVolumeItem,
                   A.QTDVOLUMENF as QtdVolumeNF,
                   CASE
                     WHEN (P.UF = 'EX' AND A.INDIMPORTEXPORT = 'S') THEN
                       'S'
                     ELSE
                       'N'
                   END AS INDEXPORTACAO,
                   A.ESPECIETRANSPPED,
                   TO_NUMBER(A.QTDVOLTRANSPPED) QTDVOLTRANSPPED,
                   NVL(A.INDIMPORTEXPORT,'N') INDIMPORTEXPORT,
                   A.MARCAVOLUME,
                   A.NUMEROVOLUME,
                   A.SEQPESSOA
            FROM   MFLV_BASEDFITEM A, MAP_FAMEMBALAGEM B, MAP_PRODUTO C, GE_PESSOA P
            WHERE  A.SEQPRODUTO = C.SEQPRODUTO AND
                   C.SEQFAMILIA = B.SEQFAMILIA AND
                   B.QTDEMBALAGEM = A.QTDEMBALAGEM AND
                   P.SEQPESSOA = A.SEQPESSOA AND
                   A.SEQNOTAFISCAL = pnSeqNotaFiscal AND
                   FMLF_VALIDANFEDEAJUSTE(a.codgeraloper) <= 0 AND
                   A.Tipuso        != 'R'
            GROUP BY NVL(A.QTDVOLUMENF, decode(FMAD_VOLUMECLIENTE(NVL(A.NROCARGA, A.NROCARGANOTABASECUPOM), NVL( A.NROEMPRESAPED, A.NROEMPRESA ), A.SEQPESSOA, DECODE( vsPDGeraSeparacaoPed, 'S', A.NROPEDIDOVENDA, NULL), A.INDFATCRUZADO ),0,
                       A.QTDVOLUMEITEM,
                       FMAD_VOLUMECLIENTE(NVL(A.NROCARGA, A.NROCARGANOTABASECUPOM), NVL( A.NROEMPRESAPED, A.NROEMPRESA ), A.SEQPESSOA, DECODE( vsPDGeraSeparacaoPed, 'S', A.NROPEDIDOVENDA, NULL), A.INDFATCRUZADO ))),
                     A.SEQNOTAFISCAL,
                     A.ESPECIEVOLUMENF,
                     A.PESOBRUTONF,
                     A.PESOLIQUIDONF,
                     A.QTDVOLUMENF,
                     A.INDIMPORTEXPORT,
                     P.UF,
                     A.ESPECIETRANSPPED,
                     A.QTDVOLTRANSPPED,
                     A.MARCAVOLUME,
                     A.NUMEROVOLUME,
                     A.SEQPESSOA ) Z
             where   NVL(Z.QTDVOLTRANSPPED, DECODE(vsEMITE_QTDVOLUME_WMS, 'N', nvl(QtdVolumeNF,QtdVolumeItem), Z.QTDVOLUMEWM)) > 0;
      if  vsSoftwarePDV = 'OPHOSNFE' then
          vnSeqM005_ID_LOCAL := fBuscaSeqTmpOphus('TMP_M005_LOCAL');
      end if;
      INSERT INTO TMP_M005_LOCAL(
              M005_ID_LOCAL, M005_DM_TIPO, M005_DS_COMPL,
              M005_DS_BAIRRO, M005_NR_CNPJ, M005_NR_IBGE_MUN,
              M005_NR_LOGR, M005_DS_MUN, M005_NM_LOGR,
              M005_DS_UF, M000_ID_NF, M005_DS_NOME,
              M005_NR_CEP, M005_DS_PAIS, M005_NR_FONE,
              M005_DS_EMAIL )
      SELECT S_SEQNFELOCAL.NEXTVAL + nvl(vnSeqM005_ID_LOCAL, 0) as M005_ID_LOCAL,
             DECODE(NVL(E.TIPOENDERECO, 'E'), 'E', 1,
                                              'B', 0,
                                                   1) AS M005_DM_TIPO, --1 AS M005_DM_TIPO,
             trim(regexp_replace(nvl(e.cmpltologradouro, c.cmpltologradouro), '[^ [:alnum:]]')) AS M005_DS_COMPL,
             trim(regexp_replace(nvl(e.bairro, c.bairro), '[^ [:alnum:]]')) AS M005_DS_BAIRRO,
             DECODE(NVL(E.TIPOENDERECO, 'E'), 'B',
               DECODE(PEMP.UF, 'EX', '00000000000000',
                      decode( PEMP.FISICAJURIDICA,'J',
                              LPAD(PEMP.NROCGCCPF, 12, 0) || LPAD(PEMP.DIGCGCCPF, 2, 0),
                              LPAD(PEMP.NROCGCCPF, 9, 0) || LPAD(PEMP.DIGCGCCPF, 2, 0))
                     ),
              DECODE(C.UF, 'EX', '00000000000000',
                    decode( C.FISICAJURIDICA,'J',
                            LPAD(C.NROCGCCPF, 12, 0) || LPAD(C.DIGCGCCPF, 2, 0),
                            LPAD(C.NROCGCCPF, 9, 0) || LPAD(C.DIGCGCCPF, 2, 0))
                   )) as M005_NR_CNPJ,
             DD.CODIBGE AS M005_NR_IBGE_MUN,
             trim(regexp_replace(DECODE(nvl(e.nrologradouro, C.NROLOGRADOURO), NULL, 'S/N', nvl(e.nrologradouro, C.NROLOGRADOURO)), '[^ [:alnum:]]')) AS M005_NR_LOGR,
             trim(regexp_replace(nvl(e.cidade, C.CIDADE), '[^ [:alnum:]]')) AS M005_DS_MUN,
             trim(regexp_replace(nvl(e.logradouro, C.LOGRADOURO), '[^ [:alnum:]]')) AS M005_NM_LOGR,
             trim(regexp_replace(nvl(e.uf, C.UF), '[^ [:alnum:]]')) AS M005_DS_UF,
             vnSeqM000_ID_NF AS M000_ID_NF,
             trim(nvl( E.NOMERECEBEDOR, substr( C.NOMERAZAO, 1, 60 ))) AS M005_DS_NOME,
             trim(regexp_replace(nvl( e.cep, C.CEP ), '[^ [:alnum:]]')) AS M005_NR_CEP,
             trim(regexp_replace( C.PAIS, '[^ [:alnum:]]')) AS M005_DS_PAIS,
             trim(regexp_replace(nvl( E.FONEEND, SUBSTR( trim(C.FONEDDD1) || trim(C.FONENRO1), 1, 14 )), '[^ [:alnum:]]')) AS M005_NR_FONE,
             trim(nvl( E.EMAILRECEBEDOR, C.EMAIL )) AS M005_DS_EMAIL
        FROM MFLV_BASENF A, GE_PESSOA C, GE_CIDADE D, GE_PESSOAEND E, GE_CIDADE DD,
             MAX_EMPRESA F, GE_PESSOA PEMP
       WHERE A.SEQPESSOA = C.SEQPESSOA
         AND C.SEQCIDADE = D.SEQCIDADE
         AND DD.SEQCIDADE = NVL(E.SEQCIDADE, C.SEQCIDADE)
         AND A.seqpessoaend = E.SEQPESSOAEND
         AND A.SEQPESSOA = E.SEQPESSOA
         AND A.nroempresa = F.NROEMPRESA
         AND F.SEQPESSOAEMP = PEMP.SEQPESSOA
         AND A.SEQNOTAFISCAL = pnSeqNotaFiscal
         AND ((C.FISICAJURIDICA != 'F' AND
               vsPDGeraLocEntPessoaFisica = 'N')
             OR vsPDGeraLocEntPessoaFisica = 'S')
         AND A.tipuso != 'R';
      If NVL(vsPDGeraTabelaTMPM011Info, 'N') != 'N' Then
         vsSelect := '
         INSERT INTO TMP_M011_INFO(
                M011_ID_LOG,
                M011_DM_TIPO,
                M011_DS_CAMPO,
                M011_DS_TXT,
                M000_ID_NF )
         SELECT case when ''' || vsSoftwarePDV || ''' = ''OPHOSNFE'' then
                     fBuscaSeqTmpOphus(''TMP_M011_INFO'')
                else
                     S_TMP_M011_IDLOG.NEXTVAL
                end,
                M011_DM_TIPO,
                M011_DS_CAMPO,
                M011_DS_TXT,
                :vnSeqM000_ID_NF
         FROM   ' || vsPDGeraTabelaTMPM011Info || '
         WHERE  M000_ID_NF = :pnSeqNotaFiscal';
         EXECUTE IMMEDIATE vsSelect USING vnSeqM000_ID_NF, pnSeqNotaFiscal;
      End If;
      sp_AjustaItemLoteNFe(pnSeqNotaFiscal, vsIndConvEmbalagem );
      vnSeqNFeItemMed := 0;
      vsRowID_TMP_SEQUENCE := null;
      for vt in (
              SELECT
                      case
                        when vsIndIipoEmbDanfeClie = 'M' then
                              NVL((X.QUANTIDADE / fminembfamilia(B.SEQFAMILIA)), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                        when vsIndIipoEmbDanfeClie = 'V' then
                              NVL((X.QUANTIDADE / FMinEmbVendaFamiliaAtiva( A.SEQPRODUTO,A.NROEMPRESA,NVL(A.NROSEGITEM, A.NROSEGMENTO) ) ), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                      else
                              NVL((X.QUANTIDADE / X.QTDEMBALAGEM), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                      end as M017_VL_QTD_LOTE,
                      F.DTAVALIDADE as M017_DT_VALIDADE,
                      F.DTAFABRICACAO as M017_DT_FABR,
                      TRIM(F.NROLOTEESTOQUE) as M017_NR_LOTE,
                      E.M014_ID_ITEM as M014_ID_ITEM,
                      A.NROSEGMENTO,
                      A.QTDEMBALAGEM,
                      A.NROEMPRESA,
                      A.SEQPRODUTO,
                      A.QUANTIDADE,
                      B.NROREGMINSAUDE,
                      F.CODAGREGACAO,
                      B.MOTIVOISENCAOMINSAUDE
              FROM    MFLV_BASEDFITEM A,
                      MAP_PRODUTO B,
                      MAP_FAMILIA C,
                      TMP_M014_ITEM E,
                      MRL_LOTEESTOQUE F,
                      (select sum(G.QUANTIDADE) as QUANTIDADE, nvl(h.qtdembnf, G.QTDEMBALAGEM) as QTDEMBALAGEM,
                              G.NUMERODF, G.SERIEDF, G.NROEMPRESADF, G.NROSERIEECF, G.SEQPRODUTO,
                              g.SEQLOTEESTOQUE
                       from   MAD_PEDVENDAITEMLOTE G, madx_pedvendaitemlotenfe h
                       where  g.nropedvenda         = h.nropedvenda
                       and    g.seqpedvendaitemlote = h.seqpedvendaitemlote
                       and    g.seqproduto          = h.seqproduto
                       and    g.seqloteestoque      = h.seqloteestoque
                       and    h.seqnotafiscal       = pnSeqNotaFiscal
                       Group By nvl(h.qtdembnf, G.QTDEMBALAGEM),
                                G.NUMERODF, G.SERIEDF, G.NROEMPRESADF, G.NROSERIEECF, G.SEQPRODUTO,
                                g.SEQLOTEESTOQUE ) X,
                      MLF_NFITEMLOTE L,
                      MAX_EMPRESA M
              WHERE   A.SEQPRODUTO    =  B.SEQPRODUTO    AND
                      B.SEQFAMILIA    =  C.SEQFAMILIA    AND
                      E.M000_ID_NF    =  vnSeqM000_ID_NF AND
                      M.NROEMPRESA    =  A.NROEMPRESA    AND
                      NVL(A.SEQORDEMNFE, A.SEQITEMDF)    = E.M014_NR_ITEM AND
                      NVL(X.SEQLOTEESTOQUE, NVL(L.SEQLOTEESTOQUE, A.SEQLOTEESTOQUE)) = F.SEQLOTEESTOQUE AND
                      (NVL(C.INDCONTROLEVDA,'N')         = 'S' OR
                       NVL(C.INDPRECOMONITORADO,'N')     = 'S' OR
                       NVL(C.INDRECEITA,'N')             = 'S' OR
                       NVL(C.INDGENERICO,'N')            = 'S' OR
                       NVL(C.INDSIMILAR,'N')             = 'S' OR
                       NVL(C.INDMEDICAMENTO,'N')         = 'S' OR
                      (NVL(C.INDUSALOTEESTOQUE,'N') = 'S'  AND NVL(M.INDUSALOTEESTOQUE,'N') = 'S')) AND
                      F.DTAVALIDADE   IS NOT NULL        AND
                      F.DTAFABRICACAO IS NOT NULL        AND
                      F.NROLOTEESTOQUE IS NOT NULL       AND
                      A.SEQNOTAFISCAL = pnSeqNotaFiscal   AND
                      A.NUMERODF      = X.NUMERODF(+)     AND
                      A.SERIEDF       = X.SERIEDF(+)      AND
                      A.NROEMPRESA    = X.NROEMPRESADF(+) AND
                      A.NROSERIEECF   = X.NROSERIEECF(+)  AND
                      A.SEQPRODUTO    = X.SEQPRODUTO(+)   AND
                      A.Tipuso        != 'R'              AND
                      A.QTDEMBALAGEM  = X.QTDEMBALAGEM(+) AND
                      A.numerodf      = L.NUMERONF(+)     AND
                      A.seriedf       = L.SERIENF(+)      AND
                      A.nroempresa    = L.NROEMPRESA(+)   AND
                      A.seqpessoa     = L.SEQPESSOA(+)    AND
                      A.seqproduto    = L.SEQPRODUTO(+)   AND
                      A.tipnotafiscal = L.TIPNOTAFISCAL(+) AND
                      A.tipitem       = L.TIPITEM(+)       AND
                      A.tipdocfiscal  != 'T'
                      UNION
            SELECT   case
                        when vsIndIipoEmbDanfeClie = 'M' then
                              NVL((X.QUANTIDADE / fminembfamilia(B.SEQFAMILIA)), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                        when vsIndIipoEmbDanfeClie = 'V' then
                              NVL((X.QUANTIDADE / FMinEmbVendaFamiliaAtiva( A.SEQPRODUTO,A.NROEMPRESA,NVL(A.NROSEGITEM, A.NROSEGMENTO) ) ), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                      else
                              NVL((X.QUANTIDADE / X.QTDEMBALAGEM), nvl(l.quantidade, E.M014_VL_QTDE_COM))
                      end as M017_VL_QTD_LOTE,
                      F.DTAVALIDADE as M017_DT_VALIDADE,
                      F.DTAFABRICACAO as M017_DT_FABR,
                      TRIM(F.NROLOTEESTOQUE) as M017_NR_LOTE,
                      E.M014_ID_ITEM as M014_ID_ITEM,
                      A.NROSEGMENTO,
                      A.QTDEMBALAGEM,
                      A.NROEMPRESA,
                      A.SEQPRODUTO,
                      A.QUANTIDADE,
                      B.NROREGMINSAUDE,
                      F.CODAGREGACAO,
                      B.MOTIVOISENCAOMINSAUDE
              FROM    MFLV_BASEDFITEM A,
                      MAP_PRODUTO B,
                      MAP_FAMILIA C,
                      TMP_M014_ITEM E,
                      MRL_LOTEESTOQUE F,
                      (select sum(G.QUANTIDADE) as QUANTIDADE, nvl(h.qtdembnf, G.QTDEMBALAGEM) as QTDEMBALAGEM,
                              G.NUMERODF, G.SERIEDF, G.NROEMPRESADF, G.NROSERIEECF, G.SEQPRODUTO,
                              g.SEQLOTEESTOQUE
                       from   MAD_PEDVENDAITEMLOTE G, madx_pedvendaitemlotenfe h
                       where  g.nropedvenda         = h.nropedvenda
                       and    g.seqpedvendaitemlote = h.seqpedvendaitemlote
                       and    g.seqproduto          = h.seqproduto
                       and    g.seqloteestoque      = h.seqloteestoque
                       and    h.seqnotafiscal       = pnSeqNotaFiscal
                       Group By nvl(h.qtdembnf, G.QTDEMBALAGEM),
                                G.NUMERODF, G.SERIEDF, G.NROEMPRESADF, G.NROSERIEECF, G.SEQPRODUTO,
                                g.SEQLOTEESTOQUE ) X,
                      MLF_NFITEMLOTE L,
                      MAX_EMPRESA M,
                      (SELECT XX.NROEMPRESA, XX.SEQPESSOAEMP FROM MAX_EMPRESA XX) XY
              WHERE   A.SEQPRODUTO    =  B.SEQPRODUTO    AND
                      B.SEQFAMILIA    =  C.SEQFAMILIA    AND
                      M.NROEMPRESA    =  A.NROEMPRESA    AND
                      E.M000_ID_NF    =  vnSeqM000_ID_NF AND
                      NVL(A.SEQORDEMNFE, A.SEQITEMDF)           = E.M014_NR_ITEM AND
                      NVL(X.SEQLOTEESTOQUE, NVL(A.SEQLOTEESTOQUE, L.SEQLOTEESTOQUE)) = F.SEQLOTEESTOQUE AND
                      (NVL(C.INDCONTROLEVDA,'N')        = 'S' OR
                      NVL(C.INDPRECOMONITORADO,'N')     = 'S' OR
                      NVL(C.INDRECEITA,'N')             = 'S' OR
                      NVL(C.INDGENERICO,'N')            = 'S' OR
                      NVL(C.INDSIMILAR,'N')             = 'S' OR
                      NVL(C.INDMEDICAMENTO,'N')         = 'S' OR
                      (NVL(C.INDUSALOTEESTOQUE,'N') = 'S'  AND NVL(M.INDUSALOTEESTOQUE,'N') = 'S')) AND
                      F.DTAVALIDADE   IS NOT NULL        AND
                      F.DTAFABRICACAO IS NOT NULL        AND
                      F.NROLOTEESTOQUE IS NOT NULL       AND
                      A.SEQNOTAFISCAL = pnSeqNotaFiscal   AND
                      A.NUMERODF      = X.NUMERODF(+)     AND
                      A.SERIEDF       = X.SERIEDF(+)      AND
                      A.NROEMPRESA    = X.NROEMPRESADF(+) AND
                      A.NROSERIEECF   = X.NROSERIEECF(+)  AND
                      A.SEQPRODUTO    = X.SEQPRODUTO(+)   AND
                      A.TIPUSO        != 'R'              AND
                      A.NUMERODF      = L.NUMERONF(+)     AND
                      A.SERIEDF       = L.SERIENF(+)      AND
                      A.NROEMPRESA    != L.NROEMPRESA(+)  AND
                      A.SEQPESSOA     =  XY.SEQPESSOAEMP AND
                      A.SEQPESSOA     != L.SEQPESSOA(+)    AND
                      A.SEQPRODUTO     = L.SEQPRODUTO(+)   AND
                      A.QUANTIDADE     = L.QUANTIDADE (+)    AND
                      A.TIPNOTAFISCAL != L.TIPNOTAFISCAL(+) AND
                      A.TIPDOCFISCAL = 'T'
                      UNION
            SELECT  --REGRA DE VALIDAÇÃO K01-10 - MEDICAMENTOS - NCMs QUE COMEÇAM COM 3001, 3002, 3003, 3004, 3005 E 3006
                      0 as M017_VL_QTD_LOTE,
                      TRUNC (SYSDATE) as M017_DT_VALIDADE,
                      TRUNC (SYSDATE) as M017_DT_FABR,
                      '0' as M017_NR_LOTE,
                      E.M014_ID_ITEM as M014_ID_ITEM,
                      A.NROSEGMENTO,
                      A.QTDEMBALAGEM,
                      A.NROEMPRESA,
                      A.SEQPRODUTO,
                      A.QUANTIDADE,
                      B.NROREGMINSAUDE,
                      '0',
                      B.MOTIVOISENCAOMINSAUDE
              FROM    MFLV_BASEDFITEM A,
                      MAP_PRODUTO B,
                      MAP_FAMILIA C,
                      TMP_M014_ITEM E,
                      MAX_EMPRESA M
              WHERE   A.SEQPRODUTO    =  B.SEQPRODUTO    AND
                      B.SEQFAMILIA    =  C.SEQFAMILIA    AND
                      E.M000_ID_NF    =  vnSeqM000_ID_NF AND
                      M.NROEMPRESA    =  A.NROEMPRESA    AND
                      NVL(A.SEQORDEMNFE, A.SEQITEMDF)    = E.M014_NR_ITEM AND
                      A.SEQNOTAFISCAL = pnSeqNotaFiscal   AND
                      SUBSTR(E.M014_CD_NCM, 0, 4) IN ('3001','3002','3003','3004','3005','3006') AND
                      TRUNC(SYSDATE) >= NVL(to_date(vdPDGeraTagMed, 'dd/mm/yyyy'), to_date('31/12/2050', 'dd/mm/yyyy'))
                      )loop
              if  vsRowID_TMP_SEQUENCE is null and
                  vsSoftwarePDV = 'OPHOSNFE' then
                  vsSelect := '
                  select COUNT(1)
                  from   TMP_SEQUENCE A
                  where  A.SEQUENCENAME = ' || CHR(39) || 'TMP_M017_MEDICAMENTO' || CHR(39) || ' ';
                  EXECUTE IMMEDIATE vsSelect INTO vnCount;
                  if  vnCount = 0 then
                      vsSelect := '
                      INSERT INTO TMP_SEQUENCE(
                             SEQUENCENAME,
                             GENERATEDID )
                      VALUES(' || CHR(39) || 'TMP_M017_MEDICAMENTO' || CHR(39) || ',
                             0)' ;
                      EXECUTE IMMEDIATE vsSelect;
                  end if;
                  vsSelect := '
                  select A.ROWID,
                         nvl(A.GENERATEDID,0)
                  from   TMP_SEQUENCE A
                  where  A.SEQUENCENAME = ' || CHR(39) || 'TMP_M017_MEDICAMENTO' || CHR(39) || '
                  for    update';
                  EXECUTE IMMEDIATE vsSelect INTO vsRowID_TMP_SEQUENCE, vnSeqNFeItemMed;
              end if;
              vnSeqNFeItemMed := vnSeqNFeItemMed + 1;
              select nvl(max(indprecoembalagem), 'N')
              into vsIndPrecoEmbalagem
              from mad_segmento a
              where a.nrosegmento = vt.Nrosegmento;
              if vt.quantidade > 1 then
                  select min(a.precomaxconsumidor)
                    into vnPrecoMaxConsumidor
                    from mrl_prodempseg a
                   where a.seqproduto = vt.Seqproduto
                     and a.nroempresa = vt.nroempresa
                     and a.nrosegmento = vt.nrosegmento
                     and a.qtdembalagem =
                         (select max(x.qtdembalagem)
                            from mrl_prodempseg x
                           where x.seqproduto = vt.seqproduto
                             and x.nroempresa = vt.nroempresa
                             and x.nrosegmento = vt.nrosegmento
                             and x.statusvenda = 'A'
                             and x.qtdembalagem <= vt.qtdembalagem);
              else
                   select max(a.precomaxconsumidor)
                   into   vnPrecoMaxConsumidor
                   from   mrl_prodempseg a
                   where  a.seqproduto   =     vt.seqproduto     and
                          a.nroempresa   =     vt.nroempresa     and
                          a.nrosegmento  =     vt.nrosegmento    and
                          a.qtdembalagem =     vt.qtdembalagem   and
                          a.statusvenda  =     'A';
              end if;
              if vnPrecoMaxConsumidor is null or vnPrecoMaxConsumidor <= 0 or vsIndPrecoEmbalagem = 'N' then
                  select max(a.precomaxconsumidor)
                    into vnPrecoMaxConsumidor
                    from mrl_prodempseg a, map_produto b
                   where a.seqproduto = vt.seqproduto
                     and a.nroempresa = vt.nroempresa
                     and a.nrosegmento = vt.nrosegmento
                     and a.seqproduto = b.seqproduto
                     and a.qtdembalagem = fpadraoembvendaseg(b.seqfamilia, a.nrosegmento);
                   if vnPrecoMaxConsumidor is null or vnPrecoMaxConsumidor <= 0 then
                       select max(a.precomaxconsumidor)
                         into vnPrecoMaxConsumidor
                         from mrl_prodempseg a, map_produto b, max_empresa c
                        where a.seqproduto = vt.seqproduto
                          and a.nroempresa = vt.nroempresa
                          and a.nrosegmento = vt.nrosegmento
                          and a.seqproduto = b.seqproduto
                          and c.nroempresa = vt.nroempresa
                          and a.qtdembalagem = fpadraoembvenda(b.seqfamilia, c.nrodivisao);
                   end if;
              end if;
              if vnPrecoMaxConsumidor is null then
                  vnPrecoMaxConsumidor := 0;
              end if;
              insert into TMP_M017_MED(
                      M017_ID_MED,
                      M017_VL_PRECO_MAX,
                      M017_VL_QTD_LOTE,
                      M017_DT_VALIDADE,
                      M017_DT_FABR,
                      M017_NR_LOTE,
                      M014_ID_ITEM,
                      M000_ID_NF,
                      NROREGMINSAUDE,
                      CODAGREGACAO,
                      MOTIVOISENCAOMINSAUDE )
              values ((case
                         when vsSoftwarePDV = 'OPHOSNFE' then
                           vnSeqNFeItemMed
                         else
                           S_SEQNFEITEMMED.Nextval
                       end),
                      vnPrecoMaxConsumidor,
                      vt.M017_VL_QTD_LOTE,
                      vt.M017_DT_VALIDADE,
                      vt.M017_DT_FABR,
                      vt.M017_NR_LOTE,
                      vt.M014_ID_ITEM,
                      vnSeqM000_ID_NF,
                      LPAD(vt.NROREGMINSAUDE, 13, 0),
                      vt.CODAGREGACAO,
                      vt.MOTIVOISENCAOMINSAUDE );
              If vsPDEmiteInfoLoteProd = 'S' then
              UPDATE TMP_M014_ITEM T
                SET    T.M014_DS_INFO = TRIM(SUBSTR(DECODE(T.M014_DS_INFO, NULL, T.M014_DS_INFO,T.M014_DS_INFO || CHR(13))
                                                                   || 'Lote: ' || vt.m017_nr_lote
                                                                   || ', Dt. Val: ' || to_char(vt.m017_dt_validade, 'dd/MM/yyyy')
                                                                   || ', Dt. Fab: ' || to_char(vt.M017_DT_FABR, 'dd/MM/yyyy')
                                                                   || ', PMC: ' || trim(to_char(vnPrecoMaxConsumidor, '9999999990d00', 'nls_numeric_characters=''.,'''))
                                                                   || ', Qtd: ' || trim(to_char(vt.m017_vl_qtd_lote, '9999999990', 'nls_numeric_characters=''.,''' ))
                                         ,1,500))
                WHERE  T.M014_ID_ITEM = vt.m014_id_item
                AND    T.M000_ID_NF   = pnSeqNotaFiscal;
              End if;
      end loop;
      if  vsRowID_TMP_SEQUENCE is not null and vnSeqNFeItemMed > 0 and
          vsSoftwarePDV = 'OPHOSNFE' then
          vsSelect := '
          update TMP_SEQUENCE A
          set    A.GENERATEDID = ' || vnSeqNFeItemMed ||'
          where  A.ROWID = ' || CHR(39) || vsRowID_TMP_SEQUENCE || CHR(39);
          EXECUTE IMMEDIATE vsSelect;
      end if;
        insert into tmp_m018_comb(
                M014_ID_ITEM,
                M018_NR_PROD_ANP,
                M018_VL_ICMS ,
                M018_VL_BC_ICMS_ST,
                M018_VL_ICMS_ST  ,
                M018_VL_BC_ICMS  ,
                M018_DS_UF_CON,
                M018_NR_CODIF,
                M018_QT_COMB_TEMP,
                M000_ID_NF,
                M018_VL_PERC_GAS_NATURALC5,
                M018_DESCRICAOANP,
                M018_VL_PERCGASNATURALNACIONAL,
                M018_VL_PERCGASNATURALIMPORT,
                M018_VL_VLRPARTIDAGLP,
                M018_VL_PERC_BIODIESEL)
         select   b.M014_ID_ITEM              as m014_id_item,
                  b.codigoanpc5               as M018_NR_PROD_ANP,
                  0                           as M018_VL_ICMS,
                  0                           as M018_VL_BC_ICMS_ST,
                  0                           as M018_VL_ICMS_ST,
                  0                           as M018_VL_BC_ICMS,
                  a.ufclientec5               as M018_DS_UF_CON,
                  nvl(b.codigoifc5, '000000000000000000000')  as M018_NR_CODIF,
                  b.m014_vl_qtde_trib                         as M018_QT_COMB_TEMP,
                  A.M000_ID_NF                 as M000_ID_NF,
                  B.M014_VL_PERC_GAS_NATURALC5 as M018_VL_PERC_GAS_NATURALC5,
                  B.M014_DESCRICAOANP          as M018_DESCRICAOANP,
                  B.M014_VL_PERCGASNATURALNACIONAL as M018_VL_PERCGASNATURALNACIONAL,
                  B.M014_VL_PERCGASNATURALIMPORT   as M018_VL_PERCGASNATURALIMPORT,
                  B.M014_VL_VLRPARTIDAGLP          as M018_VL_VLRPARTIDAGLP,
                  B.M014_VL_PERC_BIODIESEL         as M018_VL_PERC_BIODIESEL
          FROM    TMP_M000_NF A, TMP_M014_ITEM b
          WHERE   A.M000_NR_REF_SIS = to_char(pnSeqNotaFiscal)
          AND     A.M000_ID_NF      = B.M000_ID_NF
          AND     b.codigoanpc5     > 0;
        insert into TMP_M018_ORIG_COMB(
                M018_ORIG_COMB_ID,
                M000_ID_NF,
                M014_ID_ITEM,
                M018_ORIG_COMB_IND_IMPORT,
                M018_ORIG_COMB_COD_UF_ORIG,
                M018_ORIG_COMB_VL_PERC_ORIG)
         SELECT   s_tmp_m018_orig_comb.nextval as M018_ORIG_COMB_ID,
                  a.m000_id_nf                 as M000_ID_NF,
                  b.m014_id_item               as M014_ID_ITEM,
                  c.tipindicador               as M018_ORIG_COMB_IND_IMPORT ,
                  c.codufibge                  as M018_ORIG_COMB_COD_UF_ORIG,
                  c.percorigemuf               as M018_ORIG_COMB_VL_PERC_ORIG
          FROM    TMP_M000_NF A, TMP_M014_ITEM b, MAP_PRODORIGEMCOMBUSTIVEL c
          WHERE   A.M000_NR_REF_SIS = to_char(pnSeqNotaFiscal)
          AND     A.M000_ID_NF      = B.M000_ID_NF
          AND     B.M014_CD_PRODUTO    = C.SEQPRODUTO
          AND     (A.M000_DM_FIN_EM != 2 OR A.M000_DM_FIN_EM != 4)
          AND     B.M014_CD_CFOP   not in (5922, 6922)
          AND     A.M000_INDFINAL  != 1
          AND     b.codigoanpc5     > 0
          AND     c.percorigemuf    > 0;
          Select nvl(max(a.m019_id_di), 0)
          into   vnM019_id_di
          from   tmp_m019_di a;
          insert into tmp_m019_di
                 (m019_id_di,
                  m014_id_item,
                  m019_cd_exportador,
                  m019_nr_documento,
                  m019_ds_local,
                  m019_ds_uf,
                  m019_dt_registro,
                  m019_dt_saida
                  )
          select vnM019_id_di + rownum       as m019_id_di,
                 b.M014_ID_ITEM              as m014_id_item,
                 a.CODEXPORTADORC5           as m019_cd_exportador,
                 a.nrodeclaraimportc5        as m019_nr_documento,
                 regexp_replace(a.localdesembaracodic5, '[!"@#$%¨&*()_+={ª}º|\,<.>;:?/°^~¹²³£¢¬-]')      as m019_ds_local,
                 a.ufdesembaracodic5         as m019_ds_uf,
                 a.dtaregistrodic5           as m019_dt_registro,
                 a.dtadesembaracodic5        as m019_dt_saida
          FROM    TMP_M000_NF A, TMP_M014_ITEM B
          WHERE   A.M000_NR_REF_SIS = to_char(pnSeqNotaFiscal)
          AND     A.M000_ID_NF      = B.M000_ID_NF
          AND     A.NRODECLARAIMPORTC5 IS NOT NULL ;
          Select nvl(max(a.m020_id_adicao), 0)
          into   vnM020_id_adicao
          from   tmp_m020_adicao a;
          insert into tmp_m020_adicao
                  (
                  M020_ID_ADICAO,
                  M020_NR_SEQ,
                  M020_CD_FABRICANTE,
                  M020_NR_ADICAO,
                  M020_VL_DESCONTO,
                  M019_ID_DI,
                  M020_NR_DRAWBACK )
          select
                   vnM020_id_adicao + rownum   as M020_ID_ADICAO,
                   nvl(b.seqadicaoc5, rownum)  as M020_NR_SEQ,
                   c.m019_cd_exportador        as M020_CD_FABRICANTE,
                   b.nroadicaoc5               as M020_NR_ADICAO,
                   nvl(b.vlrdescadicaodic5, 0) as M020_VL_DESCONTO,
                   c.m019_id_di                as m019_id_di,
                   b.nrodrawbackdic5           as M020_NR_DRAWBACK
          FROM    TMP_M000_NF A, TMP_M014_ITEM B, TMP_M019_DI C
          WHERE   A.M000_NR_REF_SIS = to_char(pnSeqNotaFiscal)
          AND     A.M000_ID_NF      = B.M000_ID_NF
          AND     A.NRODECLARAIMPORTC5 IS NOT NULL
          AND     C.M014_ID_ITEM    = B.M014_ID_ITEM;
---Objeto Customização
      voTP_SP_EXPNFE_2G.cnSeqNotaFiscal := pnSeqNotaFiscal;
      voTP_SP_EXPNFE_2G.cnSeqM000_ID_NF := vnSeqM000_ID_NF;
      voTP_SP_EXPNFE_2G.vsSoftwarePDV   := vsSoftwarePDV;
      voTP_SP_EXPNFE_2G.vnNroEmpresa    := vnNroEmpresa;
      SP_EXPNFE_2G_CUST(voTP_SP_EXPNFE_2G);
---
    End If;
  exception
    when others then
      raise_application_error (-20200, 'SP_EXPNFE_2G - Erro ao exportar os dados p/ NFe - '|| SQLERRM);
END SP_EXPNFE_2G;

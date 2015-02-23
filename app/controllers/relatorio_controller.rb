# encoding: UTF-8
require "erb"
include ERB::Util

class RelatorioController < ApplicationController

  def index
    @vLstRelatorio = []
    @vLstRelatorio << EasyReport.new( 1, 'About Person', 'all_about_person', '/familias/familia', 'R',
    [%{SELECT f.cdg_familia, 
     p.nme_pessoa nme_responsavel, 
     c.dsc_comunidade, 
     COALESCE( lg.dsc_tipo_logradouro, '') || ' ' || COALESCE( lg.dsc_titulo_logradouro, '') || ' ' || lg.dsc_logradouro dsc_logradouro, 
     pe.nmr_endereco, 
     COALESCE( pe.dsc_complemento, '-' ) dsc_complemento, 
     lc.dsc_localidade || '/' || es.dsc_sigla dsc_localidade, 
     cp.nmr_cep, 
     COALESCE( b.dsc_bairro, pe.dsc_bairro_ncad ) dsc_bairro 
    FROM family f 
     INNER JOIN community c ON c.cdg_comunidade = f.cdg_comunidade 
     INNER JOIN family_member fm ON f.cdg_familia = fm.cdg_familia AND fm.sta_responsavel = 'S' 
     INNER JOIN person p ON p.cdg_pessoa = fm.cdg_pessoa 
     INNER JOIN person_adress pe ON pe.cdg_pessoa = fm.cdg_pessoa 
     INNER JOIN locality lc ON lc.cdg_localidade = pe.cdg_localidade 
     INNER JOIN country es ON es.cdg_estado = lc.cdg_estado 
     INNER JOIN adress lg ON lg.cdg_logradouro = pe.cdg_logradouro AND lg.cdg_localidade = pe.cdg_localidade 
     LEFT JOIN zip_code as cp ON pe.cdg_localidade = cp.cdg_localidade AND pe.cdg_logradouro = cp.cdg_logradouro 
     LEFT JOIN neighborhood b ON b.cdg_localidade = cp.cdg_localidade AND b.cdg_bairro = cp.cdg_bairro 
    WHERE f.sta_situacao = 'A' AND c.cdg_comunidade = {?pCdgComunidade} 
    WITH UR},
    #-- another select...
    %{SELECT fm.cdg_familia,
     p.cdg_pessoa,
     p.nme_pessoa,
     (CASE WHEN p.tpo_sexo = 'M' THEN 'Masculino' ELSE 'Feminino' END ) dsc_sexo,
     pt.nmr_ddd,
     pt.nmr_telefone,
     CASE p.sta_situacao
       WHEN 'A' THEN 'Ativo'
       WHEN 'I' THEN 'Inativo'
       WHEN 'U' THEN 'Unificado'
       WHEN 'F' THEN 'Falecido'
     END sta_situacao
    FROM family_member fm
     INNER JOIN family f ON f.cdg_familia = fm.cdg_familia
     INNER JOIN person p ON p.cdg_pessoa = fm.cdg_pessoa
     LEFT JOIN person_phone pt ON pt.cdg_pessoa = p.cdg_pessoa AND pt.sqc_sequencia = 1
    WHERE f.sta_situacao = 'A' AND f.cdg_comunidade = {?pCdgComunidade}
    ORDER BY p.nme_pessoa
    WITH UR}],
    nil,
    [ EasyReportParam.new(1, 'Regional',  'pCdgRegional',   'CBO', GlbListaValoresParametro.new( 'GlbRegional.Carregar', 'cdg_orgao_operacional', 'dsc_orgao_operacional' ), usuario_logado.UnidadePrincipal.cdg_unidade_sup, "combobox({ url: '/unidade/CarregarLstUnidade', url_params: ['pCdgRegional='+$F('pCdgRegional')], combobox: $('pCdgUnidade') });" ),
    EasyReportParam.new(2, 'Unidade',     'pCdgUnidade',    'CBO', nil, usuario_logado.cdg_unidade_principal, "combobox({ url: '/comunidades/CarregarLstBasicaComunidadePorUnidade', url_params: ['pCdgUnidade='+$F('pCdgUnidade')], combobox: $('pCdgComunidade') });" ),
    EasyReportParam.new(3, 'Comunidade',  'pCdgComunidade', 'CBO', nil, 0 ) ],
    'PMS_VIS_RLFICHF')

  @vLstRelatorio << EasyReport.new( 8, 'Audit records', 'audit_records', '/unidades/unidade', 'R',
    %{SELECT r.dsc_orgao_operacional dsc_regional, 
           oo.dsc_orgao_operacional dsc_unidade, 
           COALESCE( p.qtd_pessoa, 0 ) qtd_pessoa , 
           COALESCE( f.qtd_familia, 0 ) qtd_familia,  
           COALESCE( pes.qtd_pessoa_regional, 0 ) qtd_pessoa_regional, 
           COALESCE( fam.qtd_familia_regional, 0 ) qtd_familia_regional 
    FROM unit oo 
     INNER JOIN unit r ON r.cdg_orgao_operacional = oo.cdg_orgao_operacional_sup 
     LEFT JOIN ( 
       SELECT ol.cdg_orgao_operacional, count(p.cdg_pessoa) qtd_pessoa 
       FROM person p 
         INNER JOIN family_member fm ON fm.cdg_pessoa = p.cdg_pessoa 
         INNER JOIN family f ON f.cdg_familia = fm.cdg_familia 
         INNER JOIN community c ON c.cdg_comunidade = f.cdg_comunidade 
         INNER JOIN local_unit ol ON ol.cdg_localidade = c.cdg_localidade 
       WHERE p.sta_situacao = 'A' AND p.dta_cadastro BETWEEN UTL.CHAR_TS('{?pDtaCadInicial} 00:00:00') AND UTL.CHAR_TS('{?pDtaCadFinal} 23:59:59') 
       GROUP BY ol.cdg_orgao_operacional ) p ON p.cdg_orgao_operacional = oo.cdg_orgao_operacional 
     LEFT JOIN ( 
       SELECT ol.cdg_orgao_operacional, count(f.cdg_familia) qtd_familia 
       FROM family f 
         INNER JOIN community c ON c.cdg_comunidade = f.cdg_comunidade 
         INNER JOIN local_unit ol ON ol.cdg_localidade = c.cdg_localidade 
       WHERE f.sta_situacao = 'A' AND f.dta_cadastro BETWEEN UTL.CHAR_TS('{?pDtaCadInicial} 00:00:00') AND UTL.CHAR_TS('{?pDtaCadFinal} 23:59:59') 
       GROUP BY ol.cdg_orgao_operacional ) f ON f.cdg_orgao_operacional = oo.cdg_orgao_operacional 
     LEFT JOIN ( 
       SELECT r.cdg_orgao_operacional, count(distinct cdg_familia) qtd_familia_regional 
       FROM family f 
       INNER JOIN community c ON c.cdg_comunidade = f.cdg_comunidade 
       LEFT JOIN local_unit ol ON ol.cdg_localidade = c.cdg_localidade 
       LEFT JOIN unit oo ON oo.cdg_orgao_operacional = ol.cdg_orgao_operacional 
       LEFT JOIN unit r ON r.cdg_orgao_operacional = oo.cdg_orgao_operacional_sup 
       WHERE f.sta_situacao = 'A' AND f.dta_cadastro BETWEEN UTL.CHAR_TS('{?pDtaCadInicial} 00:00:00') AND UTL.CHAR_TS('{?pDtaCadFinal} 23:59:59') 
       GROUP BY r.cdg_orgao_operacional ) fam ON r.cdg_orgao_operacional = fam.cdg_orgao_operacional 
     LEFT JOIN ( 
       SELECT r.cdg_orgao_operacional, count(distinct p.cdg_pessoa) qtd_pessoa_regional 
       FROM person p 
       INNER JOIN family_member fm ON fm.cdg_pessoa = p.cdg_pessoa 
       INNER JOIN family f ON f.cdg_familia = fm.cdg_familia 
       INNER JOIN community c ON c.cdg_comunidade = f.cdg_comunidade 
       LEFT JOIN local_unit ol ON ol.cdg_localidade = c.cdg_localidade 
       LEFT JOIN unit oo ON oo.cdg_orgao_operacional = ol.cdg_orgao_operacional 
       LEFT JOIN unit r ON r.cdg_orgao_operacional = oo.cdg_orgao_operacional_sup 
       WHERE p.sta_situacao = 'A' AND p.dta_cadastro BETWEEN UTL.CHAR_TS('{?pDtaCadInicial} 00:00:00') AND UTL.CHAR_TS('{?pDtaCadFinal} 23:59:59') 
       GROUP BY r.cdg_orgao_operacional ) pes ON r.cdg_orgao_operacional = pes.cdg_orgao_operacional 
    [:WHERE] 
    ORDER BY r.dsc_orgao_operacional, oo.dsc_orgao_operacional 
    WITH UR},
    [ EasyReportCondition.new("'{?pCdgRegional}' != 'T'", "r.cdg_orgao_operacional = {?pCdgRegional}") ],
    [ EasyReportParam.new(1, 'Regional', 'pCdgRegional', 'CBOT', GlbListaValoresParametro.new( 'GlbRegional.Carregar', 'cdg_orgao_operacional', 'dsc_orgao_operacional' ), usuario_logado.UnidadePrincipal.cdg_unidade_sup ),
    EasyReportParam.new(3, 'Período de cadastro', 'pDtaCad', 'PDTA', nil, '' ),
    EasyReportParam.new(4, 'Usuário', 'pNmeUsuario', 'TXT', nil, usuario_logado.nme_login, nil, false ) ],
    'PMS_VIS_RLCADFP')

    session[:reports] = @vLstRelatorio
  end

  def CarregarRelatorio
    report = session[:reports].detect{|p| p.cdg_relatorio == params[:id].to_i }
  end

  def VisualizarRelatorio
    report = session[:reports].detect{|p| p.cdg_relatorio == params[:id].to_i }

    @vLstResultado = report.rodar_select( params )
  
    render_report('/relatorio/'+report.nme_relatorio, report.xml_path, report.nme_relatorio,"#{report.nme_relatorio}#{Time.now}", params[:pFormato] )
  rescue => e
    flash[:notice] = mensagem( :erro => e )
  end

  protected
  def cache_hack
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = ''
      headers['Cache-Control'] = ''
    else
      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-cache, must-revalidate'
    end
  end

  def render_report(template_file, xml_start_path, jasper_file, file_name_output, output_type = 'pdf')
    xml_contents = render_to_string(:template => template_file , :layout => false, :formats=>[:xml], :handlers=>[:builder])

    case output_type
      when 'csv'
        extensao = 'csv'
        mime_type = 'text/plain'
        jasper_type = 'csv'
      when 'xls'
        extensao = 'xls'
        mime_type = 'application/xls'
        jasper_type = 'xls'
      else
        extensao = 'pdf'
        mime_type = 'application/pdf'
        jasper_type = 'pdf'
    end

    cache_hack
    send_data( Jasper4rails::Report.load(xml_contents, jasper_file, jasper_type, xml_start_path),
      :filename => "#{file_name_output}.#{extensao}", :type => mime_type, :disposition => 'attachment')
  end
end
   

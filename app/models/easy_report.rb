# encoding: UTF-8
class EasyReport < ActiveRecord::Base
  attr_accessor :cdg_relatorio, :dsc_relatorio, :nme_relatorio, :selects, :xml_path, :tpo_relatorio, :nme_permissao, :parametros, :condicoes

  def initialize( p_cdg_relatorio, p_dsc_relatorio, p_nme_relatorio, p_xml_path, p_tipo_relatorio, p_arr_select, p_arr_condicao, p_arr_parametro, p_nme_permissao )
    @cdg_relatorio  = p_cdg_relatorio
    @dsc_relatorio  = p_dsc_relatorio
    @nme_relatorio  = p_nme_relatorio
    @xml_path       = p_xml_path
    @tpo_relatorio  = p_tipo_relatorio
    @selects    = [*p_arr_select]
    @condicoes    = p_arr_condicao
    @parametros   = p_arr_parametro
    @nme_permissao  = p_nme_permissao
  end

  def rodar_select( p_parametros )
    arr_resultados = Array.new

    # Retira os parâmetros que sejam nulos ou que o seu índice seja uma palavra desconsiderada(ex: action )
    p_parametros.reject!{|chave, valor| obter_parametros_desconsiderados.include?( chave ) || valor.nil? }

    for select in self.selects
      str_select = select.clone
      arr_condicao = Array.new

      p_parametros.each_pair {|param, valor| str_select.gsub!( "{?#{param}}", formatar_valor_parametro( valor ) ) }

      if !self.condicoes.nil?
        self.condicoes.each do |condicao|
          str_condicao_testar = condicao.str_condicao_testar.clone
          str_condicao = condicao.str_condicao.clone

          p_parametros.each_pair do |param, valor|
            valor = formatar_valor_parametro( valor )
            str_select.gsub!( "{?#{param}}", valor )
            str_condicao_testar.gsub!( "{?#{param}}", valor )
            str_condicao.gsub!( "{?#{param}}", valor )
          end

          arr_condicao << "(#{str_condicao})" if eval( str_condicao_testar )
        end

        if arr_condicao.size > 0
          str_select.gsub!("[:WHERE]", "WHERE #{arr_condicao.join(' AND ')}" )
        else
          str_select.gsub!("[:WHERE]", "" )
        end
      end

      logger.info "SQL do relatório #{@cdg_relatorio}: \n #{str_select}"

      arr_resultados << EasyReport.find_by_sql( str_select )
    end

    return self.selects.size == 1 ? arr_resultados.flatten : arr_resultados
  end

  class << self
    include Config

    def gerar_relatorio(p_xml_data, p_nme_relatorio, p_output_type, p_select_criteria)
      report_design =  p_nme_relatorio + '.jasper'
      interface_classpath = Dir.getwd+"/app/jasper/bin"

      mode = "w+"
      Dir.foreach(Dir.getwd+"/app/jasper/lib") do |file|
        interface_classpath << ":#{Dir.getwd}/app/jasper/lib/"+file if (file != '.' and file != '..' and file.match(/.jar/))
      end

      result = nil
      cmd = "java -Djava.awt.headless=true -cp \"#{interface_classpath}\" XmlJasperInterface -o#{p_output_type} -f#{Dir.getwd}/app/reports/#{report_design} -x#{p_select_criteria}"
      IO.popen cmd, mode do |pipe|
        pipe.write p_xml_data
        pipe.close_write
        result = pipe.read
        pipe.close
      end
      return result
    end
  end

  private
  def obter_parametros_desconsiderados
    ['action', 'controller', 'rnd', 'aRdBxFormatoExportar', 'pFormato']
  end

  def formatar_valor_parametro( p_valor )
    valor = ( p_valor )
    # Verifica se o valor é uma data(ex: 10/05/2040); se for, troca o '/' por '.'
    valor.gsub!('/', '.') if !(valor =~ /^((0?[1-9]|[12]\d)\/(0?[1-9]|1[0-2])|30\/(0?[13-9]|1[0-2])|31\/(0?[13578]|1[02]))\/(19|20)?\d{2}$/).nil?

    # Verifica se o valor é uma data(ex: 05/2040); se for, troca o '/' por '.'
    valor.gsub!('/', '.') if !(valor =~ /^((0?[1-9]|1[0-2])|30\/(0?[13-9]|1[0-2])|31\/(0?[13578]|1[02]))\/(19|20)?\d{2}$/).nil?

    return valor
  end
end

class EasyReportCondition
  attr_accessor :str_condicao_testar, :str_condicao

  def initialize( p_str_condicao_testar, p_str_condicao )
    @str_condicao_testar  = p_str_condicao_testar
    @str_condicao = p_str_condicao
  end
end

class EasyReportParam
  attr_accessor :cdg_parametro, :dsc_parametro, :nme_parametro, :tpo_parametro, :nme_func_carregar_filho, :valor_default, :parametro_visivel, :ObjValores

  def initialize( p_cdg_parametro, p_dsc_parametro, p_nme_parametro, p_tipo_parametro, p_arr_valores, p_valor_padrao, p_nme_func_carregar_filho = nil, p_parametro_visivel = true )
    @cdg_parametro       = p_cdg_parametro
    @dsc_parametro       = p_dsc_parametro
    @nme_parametro       = p_nme_parametro
    @tpo_parametro       = p_tipo_parametro
    @nme_func_carregar_filho = p_nme_func_carregar_filho
    @valor_default       = p_valor_padrao
    @parametro_visivel     = p_parametro_visivel
    @ObjValores        = p_arr_valores
  end
end

class GlbListaValoresParametro
  attr_accessor :nme_coluna_codigo, :nme_coluna_descricao, :Valores

  def initialize( p_arr_valores, p_nme_coluna_codigo, p_nme_coluna_descricao )
    @nme_coluna_codigo    = p_nme_coluna_codigo
    @nme_coluna_descricao = p_nme_coluna_descricao
    @Valores          = p_arr_valores
  end
end
xml.instruct!(:xml)
xml.unidades do
	xml.parametros do
		xml.regional(@vLstParametros[:pCdgRegionalValor])
		xml.dta_inicial(@vLstParametros[:pDtaCadInicial])
		xml.dta_final(@vLstParametros[:pDtaCadFinal])
		xml.datahora(@vDataHora)
		xml.pensamento(( @vObjPensamento ) ? @vObjPensamento.dsc_pensamento_autor : '')
	end
  @vLstResultado.each do |r|
		xml << r.to_xml( :dasherize => false, :skip_instruct => true, :only => [:dsc_regional, :dsc_unidade, :qtd_pessoa, :qtd_familia, :qtd_pessoa_regional, :qtd_familia_regional], :root => "unidade")
  end
end
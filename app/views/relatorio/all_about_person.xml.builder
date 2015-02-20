xml.instruct!(:xml)
xml.familias do
	xml.parametros do
		xml.regional(@vLstParametros[:pCdgRegionalValor])
		xml.unidade(@vLstParametros[:pCdgUnidadeValor])
		xml.comunidade(@vLstParametros[:pCdgComunidadeValor])
		xml.datahora(@vDataHora)
		xml.pensamento(( @vObjPensamento ) ? @vObjPensamento.dsc_pensamento_autor : '')
	end
  @vLstResultado[0].each do |r|
  	xml.familia do
  		xml.cdg_familia( r.cdg_familia )
  		xml.nme_responsavel( r.nme_responsavel )
  		xml.dsc_comunidade( r.dsc_comunidade )
  		xml.dsc_logradouro( r.dsc_logradouro )
  		xml.nmr_endereco( r.nmr_endereco )
  		xml.dsc_complemento( r.dsc_complemento )
  		xml.dsc_localidade( r.dsc_localidade )
  		xml.nmr_cep( r.nmr_cep )
  		xml.dsc_bairro( r.dsc_bairro )

			xml.campos do
				@vLstResultado[1].select{|m| r.cdg_familia == m.cdg_familia}.each do |m|
  				xml << m.to_xml( :dasherize=>false, :skip_instruct=>true, :only => [:nme_categoria, :dsc_rotulo, :dsc_conteudo], :root => "campo")
  			end
			end

			xml.membros do
  			@vLstResultado[2].select{|m| r.cdg_familia == m.cdg_familia}.each do |m|
  				xml << m.to_xml( :dasherize=>false, :skip_instruct=>true, :only => [:cdg_pessoa, :nme_pessoa, :dsc_sexo, :nmr_ddd, :nmr_telefone, :sta_situacao], :root => "membro")
  			end
  		end
  	end
  end
end
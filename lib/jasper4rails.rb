module Jasper4rails
	class Report
    def self.load(p_xml_data, p_nme_relatorio, p_output_type, p_select_criteria)
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
end

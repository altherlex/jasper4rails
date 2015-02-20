$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jasper4rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jasper4rails"
  s.version     = Jasper4rails::VERSION
  s.authors     = ["Alther"]
  s.email       = ["para.alves@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "JasperReports for RoR"
  s.description = "Reports for JasperReports and Rails"

  # Load app dir whether you want use the helpers to make the pages
  #s.files = Dir["{app,lib}/**/*"]
  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.17"

  s.add_development_dependency "sqlite3"
end

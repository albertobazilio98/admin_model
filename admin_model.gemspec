$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'admin_model/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'admin_model'
  spec.version     = AdminModels::VERSION
  spec.authors     = ['Alberto Bazilio']
  spec.email       = ['albertobazilio98@gmail.com.br']
  spec.homepage    = 'https://github.com/albertobazilio98/admin_model'
  spec.summary     = 'Quickly create rails admin stuff'
  spec.description = 'Create concerns and I18n keys for rails admin'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 5.2.4', '>= 5.2.4.3'
  spec.add_dependency 'rails_admin', '> 0'

  spec.add_development_dependency 'sqlite3'
end

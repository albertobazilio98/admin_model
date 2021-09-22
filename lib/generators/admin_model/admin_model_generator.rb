require 'yaml'

class AdminModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: []

  def generate_model
    generate('model', @_initializer[0].join(' '))
  end

  def crate_rails_admin_concern
    @class_name = class_name
    @fields_list = ''
    @attributes.each do |attribute|
      @fields_list << "\n        field :#{attribute.name}"
    end
    template 'admin_model.template', "app/models/concerns/rails_admin/#{file_name}.rb"
  end

  def include_rails_admin
    inject_into_class "app/models/#{file_name}.rb", class_name, "  include RailsAdmin::#{class_name}\n"
  end

  def get_translation_file
    ptbr = File.read('config/locales/pt-BR.yml')
    @ptbr_hash = YAML.load(ptbr)
  end

  def insert_deafult_attributes_translations_if_necessary
    if @ptbr_hash["pt-BR"]["activerecord"]["attributes"]["default_attributes"].nil?
      inject_into_file 'config/locales/pt-BR.yml', after: "\n    attributes:\n" do
        <<-YML
      default_attributes: &default_attributes
        id: '#'
        name: Nome
        created_at: Data de criação
        updated_at: Data de atualização
        YML
      end
    end
  end

  def insert_base_errors_translations_if_necessary
    if @ptbr_hash["pt-BR"]["activerecord"]["errors"]["models"]["base_errors"].nil?
      inject_into_file 'config/locales/pt-BR.yml', after: "    errors:\n      models:\n" do
        <<-YML
        base_errors: &base_errors
          blank: não pode ficar em branco
          invalid: invalido
          required: é requirido
          taken: já existe e deve ser único
        YML
      end
    end
  end

  def inssert_model_translation_keys
    inject_into_file 'config/locales/pt-BR.yml', after: "\n    models:\n" do
      <<-YML
      #{name}:
        one: please fill me
        other: please fill me
      YML
    end
  end

  def insert_attributes_translation_keys
    model_attriutes = @attributes.reduce('') do |acc, attribute|
      "#{acc}\n        #{attribute.name}: please fill me"
    end
    ptbr = File.read("config/locales/pt-BR.yml")
    inject_into_file 'config/locales/pt-BR.yml', after: ptbr[/pt-BR:\n(.*\n)* {2}activerecord:\n(.*\n)* {4}attributes:\n( {6}.+(\n( {8}.+\n)+))+/] do
      <<-YML
      #{name}:\n        <<: *default_attributes#{model_attriutes}
      YML
    end
  end

  def insert_attributes_errors_translation_keys
    model_attriutes = @attributes.reduce('') do |acc, attribute|
      "#{acc}\n            #{attribute.name}:\n              <<: *base_errors"
    end
    ptbr = File.read("config/locales/pt-BR.yml")
    inject_into_file 'config/locales/pt-BR.yml', after: ptbr[/pt-BR:\n(.*\n)* {2}activerecord:\n(.*\n)* {4}errors:\n(.*\n)* {6}models:\n( {8}.+(\n( {10}.+\n)+))+/] do
      <<-YML
        #{name}:\n          attributes:#{model_attriutes}
      YML
    end
  end
end

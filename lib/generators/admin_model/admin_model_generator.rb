require 'yaml'

class AdminModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: []

  def generate_model
    generate('model', @_initializer[0].join(' '))
  end

  def crate_rails_admin_concern
    @pascal_name = class_name.singularize
    @snake_name = file_name.singularize
    @fields_list = ''
    @attributes.each do |attribute|
      @fields_list << "\n        field :#{attribute.name}"
    end
    template 'admin_model.template', "app/models/concerns/rails_admin/#{@snake_name}.rb"
  end

  def include_rails_admin
    inject_into_class "app/models/#{@snake_name}.rb", @pascal_name, "  include RailsAdmin::#{@pascal_name}\n"
  end

  def get_translation_file
    @ptbr_path = 'config/locales/pt-BR.yml'
    ptbr = File.read(@ptbr_path)
    @ptbr_hash = YAML.load(ptbr)
  end
  def inssert_model_translation_keys
    ptbr = File.read(@ptbr_path)
    inject_into_file @ptbr_path, after: ptbr[/pt-BR:\n(.*\n)* {2}activerecord:\n(.*\n)* {4}models:\n( {6}.+(\n( {8}.+\n)+))+/] do
      <<-YML
      #{@snake_name}:
        one: please fill me
        other: please fill me
      YML
    end
  end

  def insert_attributes_translation_keys
    model_attriutes = @attributes.reduce('') do |acc, attribute|
      "#{acc}\n        #{attribute.name}: please fill me"
    end
    ptbr = File.read(@ptbr_path)
    inject_into_file @ptbr_path, after: ptbr[/pt-BR:\n(.*\n)* {2}activerecord:\n(.*\n)* {4}attributes:\n( {6}.+(\n( {8}.+\n)+))+/] do
      <<-YML
      #{@snake_name}:#{model_attriutes}
      YML
    end
  end

  def insert_attributes_errors_translation_keys
    model_attriutes = @attributes.reduce('') do |acc, attribute|
      "#{acc}\n            #{attribute.name}:"
    end
    ptbr = File.read(@ptbr_path)
    inject_into_file @ptbr_path, after: ptbr[/pt-BR:\n(.*\n)* {2}activerecord:\n(.*\n)* {4}errors:\n(.*\n)* {6}models:\n( {8}.+(\n( {10}.+\n)+))+/] do
      <<-YML
        #{@snake_name}:\n          attributes:#{model_attriutes}
      YML
    end
  end
end

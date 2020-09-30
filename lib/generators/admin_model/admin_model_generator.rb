class AdminModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :attributes, type: :array, default: []

  def generate_model
    generate('model', @_initializer[0].join(' '))
  end

  def crate_rails_admin_concern
    @fields_list = ''
    @attributes.each do |attribute|
      @fields_list << "\n        field :#{attribute.name}"
    end
    template 'admin_model.template', "app/models/concerns/rails_admin/#{file_name}.rb"
  end

  def include_rails_admin
    inject_into_class "app/models/#{file_name}.rb", class_name, "  include RailsAdmin::#{class_name}\n"
  end

  def create_translation_keys
    inject_into_file 'config/locales/pt-BR.yml', after: "\n    models:\n" do
      <<-YML
      #{name}:
        one: please fill me
        other: please fill me
      YML
    end
    model_attriutes = ''
    @attributes.each do |attribute|
      model_attriutes << "\n        #{attribute.name}: please fill me"
    end
    inject_into_file 'config/locales/pt-BR.yml', after: "\n    attributes:\n" do
      <<-YML
      #{name}: please fill me#{model_attriutes}
      YML
    end
  end


end

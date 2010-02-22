class StatisticModelGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template 'migration.rb',"db/migrate", :migration_file_name => "create_#{plural_name}"
      m.directory "app/models/statistic/"
      m.template 'model.rb',"app/models/statistic/#{singular_name}.rb"
    end
  end
end

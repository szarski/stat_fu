require 'activerecord'
require File.join(File.dirname(__FILE__), '..', 'init.rb')

stat_models_dir = ENV['STATISTIC_MODELS_PATH']
if stat_models_dir.nil? and defined?(RAILS_ROOT)
  stat_models_dir = File.join(RAILS_ROOT, 'app', 'models', 'statistic')
end

if stat_models_dir
  Dir.entries(stat_models_dir).each do |file_name|
    unless file_name =~ /^\./
      file_dir = File.join(RAILS_ROOT, 'app', 'models', 'statistic', file_name)
      require file_dir
    end
  end
end

namespace :stats do
  desc "display help"
  task :help do
    puts "\e[32mStat_fu\e[0m rake tasks help."
    puts "  You can define tasks for your stats in your models."
    if Statistic.rake_tasks.empty?
      puts "  \e[31mNo tasks defined yet.\e[0m\n"
    else
      puts "  Currently available tasks:\n\n"
      puts Statistic.rake_tasks.collect {|t| "    \e[31m#{t.to_s}\e[0m\n      #{t.description}\n\n"}
    end
    puts "For help go to http://github.com/szarski/stat_fu"
  end
end

Statistic.rake_tasks.each do |task_specification|
  task_specification.call_creating_method
end

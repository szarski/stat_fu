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
    puts "These are the stats rake tasks."
  end

  Statistic.rake_tasks.each do |options|
    add_task = lambda{
      desc options[:description]
      task options[:name] => :environment do
        options[:block].call
      end
    }
    calls = [add_task]
    options[:namespaces].reverse.each_with_index do |name, index|
      calls[index+1] = lambda{
        namespace name do
          calls[index].call
        end
      }
    end
    calls.last.call
  end
end

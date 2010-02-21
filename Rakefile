require 'rake'
require 'rake/rdoctask'
require 'spec'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :rspec

desc 'Test the stat_fu plugin.'
Spec::Rake::SpecTask.new(:rspec) do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.spec_files = FileList['spec/stat_fu/*.rb']
end

desc 'Generate documentation for the stat_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'StatFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

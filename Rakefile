require 'rake'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/*_spec.rb"
end

desc 'Generate documentation for the public_activity plugin.'
YARD::Rake::YardocTask.new do |doc|
  doc.files = ['lib/**/*.rb']
end

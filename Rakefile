require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "scaffolder"
  gem.homepage = "http://www.michaelbarton.me.uk/scaffolder/"
  gem.license = "MIT"
  gem.summary = %Q{Genome scaffolding for human beings.}
  gem.description = %Q{Organise sequence contigs into genome scaffolds using simple human-readable YAML files.}
  gem.email = "mail@michaelbarton.me.uk"
  gem.authors = ["Michael Barton"]
  gem.add_runtime_dependency "bio", ">= 0"
  gem.add_development_dependency "mocha", "~> 0.9"
  gem.add_development_dependency "shoulda", "~> 2.11"
  gem.add_development_dependency "redgreen", "~> 1.2"
  gem.add_development_dependency "yard", "~> 0.6"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new

task :default => :test

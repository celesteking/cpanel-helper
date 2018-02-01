
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'erb'

require 'cpanelhelper/version'

@gemname = 'rbenv-rubygem-cpanel-helper'
@specfile = "#{@gemname}.spec"

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

RSpec::Core::RakeTask.new(:spec)

desc 'Build SRPM'
task srpm: [:build, :template_spec] do |t|
  sh "rpmbuild -bs -D '_sourcedir #{Dir.pwd}/pkg' -D '_srcrpmdir #{Dir.pwd}/pkg' #{@specfile}"
  $?.success? || raise('Failure building SRPM')
end

task :template_spec do
  spectempl = "#{@specfile}.in"

  gem_version = CPanelHelper::Version.string
  ruby_version = RUBY_VERSION

  erb = ERB.new(File.read(spectempl))
  erb.filename = spectempl
  File.write(@specfile, erb.result(binding), mode: 'w+')
end

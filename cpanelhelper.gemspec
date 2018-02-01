# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'cpanelhelper/version'

Gem::Specification.new do |s|
  s.name        = 'cpanel-helper'
  s.version     = CPanelHelper::Version.string
  s.authors     = CPanelHelper::Version.authors
  s.email       = %w(yuri@fused.internal)
  s.homepage    = 'http://dev.fused.net'
  s.summary     = %q{Rubinized CPanel API interface}
  s.description = %q{CPanel API library that acts like small proxy between your app and CPanel. Can execute external JSON/XML CPanel API and internal XML'zed CPanel API2}

  s.files         = %w(README.textile Rakefile) + Dir.glob('{bin,lib,spec}/**/*')
  s.test_files    = Dir.glob('{test,spec,features}/**/*')
  s.require_paths = %w(lib)

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'RedCloth'

  s.add_runtime_dependency 'activesupport', '>= 3.0.8'

  s.requirements << 'Any JSON implementation that works by require "json"'
  s.requirements << 'ActiveSupport 3.x from Rails'
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cpanelhelper/version"

Gem::Specification.new do |s|
  s.name        = "cpanel-helper"
  s.version     = CPanelHelper::Version.string
  s.authors     = CPanelHelper::Version.authors
  s.email       = %w(yuri@fused.com)
  s.homepage    = "http://dev.fused.net"
  s.summary     = %q{Rubinized CPanel API interface}
  s.description = %q{CPanel API library that acts like small proxy between your app and CPanel. Can execute external JSON/XML CPanel API and internal XML'zed CPanel API2}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'ruby-debug'
  s.add_development_dependency 'shoulda-context'

  s.add_runtime_dependency 'activesupport', '>= 3.0.8'

	s.requirements << 'Any JSON implementation that works by require "json"'
  s.requirements << 'ActiveSupport 3.x from Rails'
end

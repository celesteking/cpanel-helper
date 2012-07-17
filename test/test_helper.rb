
$: << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'test/unit'

require "bundler/setup"

require 'cpanelhelper'
require 'shoulda-context'

module Shoulda::Context::ClassMethods
	def xcontext(*args, &block)
		# nothing
	end
end

#!/bin/env ruby

require File.expand_path('../../test_helper', __FILE__)
require 'pp'
require 'logger'

CPanelHelper.configure do |config|
	config.logger = Logger.new($stderr)
	#config.access_hash = open('/root/.accesshash').read
end

class LocalTest < Test::Unit::TestCase

	context 'local cpanel information' do
		should 'retrieve user info' do
			userinfo = CPanelHelper::Local.get_cpstore_user_info('bigbang')
			assert_instance_of(Hash, userinfo)
			assert_equal 'bigbang', userinfo[:username]
		end

		should 'fail on nonexistent user' do
			assert_raise CPanelHelper::NotFoundError do
				CPanelHelper::Local.get_cpstore_user_info('doesntexistnevahrrer34')
			end
		end
	end
end

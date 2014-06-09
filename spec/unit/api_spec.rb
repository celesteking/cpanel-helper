#!/bin/env ruby

require File.expand_path('../../spec_helper', __FILE__)
require 'pp'
require 'logger'

CPanelHelper.configure do |config|
	config.uri_host = 'https://172.20.0.15:2087'
	config.user = 'root'
	config.password = 'test15'
	config.logger = Logger.new($stderr)
	config.call_type = :json
	#config.access_hash = open('/root/.accesshash').read
end

describe 'external cpanel API' do

	it 'lists available API calls' do
		applist = CPanelHelper::API.applist
		assert_not_nil applist
		assert_instance_of(Array, applist['app'])
		assert !applist['app'].empty?
	end

	it 'lists accounts' do
		accounts = CPanelHelper::API.listaccts('domain', '.*')
		assert_instance_of(Array, accounts)
		assert !accounts.empty?
	end

	it 'error out on wrong function name or params' do
		# wrong call
		assert_raise CPanelHelper::CallError do
			accounts = CPanelHelper::API.doesntexist(:blah => 'sdf', :bloh => '234324')
		end

		assert_raise CPanelHelper::CallError do
			CPanelHelper::API.limitbw('doesntexist', 30000)
		end
	end
end

describe 'internal CPanel API' do
	it 'invokes dns lookup and return an ip' do
		host = 'a.root-servers.net'
		ip = '198.41.0.4'

		result = CPanelHelper::API.call_internal('bigbang@DnsLookup::name2ip', :domain => host)
		assert_equal ip, result['ip']
	end

	it 'errors out on wrong function name or params' do
		# wrong func name
		assert_raise CPanelHelper::CallError do
			CPanelHelper::API.call_internal('bigbang@DnsLookup::doesntexist')
		end

		# wrong params
		assert_raise CPanelHelper::CallError do
			CPanelHelper::API.call_internal('bigbang@SubDomain::delsubdomain', :length => 'shithappens')
		end
	end
end
#!/bin/env ruby

require File.expand_path('../../spec_helper', __FILE__)
require 'pp'
require 'logger'

CPanelHelper.configure do |config|
	config.uri_host = 'https://cpup5.local:2087'
	config.user = 'root'
	config.password = 'test15'
	config.logger = Logger.new($stderr)
	config.call_type = :json
	#config.access_hash = open('/root/.accesshash').read
end

describe 'external cpanel API' do

	it 'lists available API calls' do
		applist = CPanelHelper::API.applist
    expect(applist).to_not be_nil
    expect(applist['app']).to be_instance_of Array
    expect(applist['app']).to_not be_empty
	end

	it 'lists accounts' do
		accounts = CPanelHelper::API.listaccts('domain', '.*')
    expect(accounts).to be_instance_of Array
    expect(accounts).to_not be_empty
	end

	it 'error out on wrong function name or params' do
		# wrong call
		expect {
      accounts = CPanelHelper::API.doesntexist(:blah => 'sdf', :bloh => '234324')
    }.to raise_error(CPanelHelper::CallError)

    expect {
			CPanelHelper::API.limitbw('doesntexist', 30000)
    }.to raise_error(RuntimeError)
	end
end

describe 'internal CPanel API' do
	it 'invokes dns lookup and return an ip' do
		host = 'a.root-servers.net'
		ip = '198.41.0.4'

		result = CPanelHelper::API.call_internal('toster@DnsLookup::name2ip', :domain => host)
		expect(result['ip']).to eq ip
	end

	it 'errors out on wrong function name or params' do
		# wrong func name
    expect {
			CPanelHelper::API.call_internal('toster@DnsLookup::doesntexist')
    }.to raise_error CPanelHelper::CallError

		# wrong params
    expect {
			CPanelHelper::API.call_internal('toster@SubDomain::delsubdomain', :length => 'shithappens')
    }.to raise_error CPanelHelper::CallError
	end
end

describe 'CPanel UAPI' do
	it 'calling a missing function raises an error' do
		expect {
			CPanelHelper::API.call_uapi('toster', 'Email', 'doesntexist', blah: :bleh)
		}.to raise_error CPanelHelper::CallError
  end

  it 'calling a missing module raises an error' do
 		expect {
 			CPanelHelper::API.call_uapi('toster', 'Doesntexist', 'get_user_information')
 		}.to raise_error CPanelHelper::CallError
  end

  it 'successfully called' do
    result = CPanelHelper::API.call_uapi('toster', 'Variables', 'get_user_information', name: :domains)
    expect(result).to_not be_nil
    expect(result['domains']).to be_instance_of Array
    expect(result['domains']).to_not be_empty
  end
end

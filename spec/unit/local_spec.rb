#!/bin/env ruby

require File.expand_path('../../spec_helper', __FILE__)
require 'pp'
require 'logger'

CPanelHelper.configure do |config|
	config.logger = Logger.new($stderr)
	#config.access_hash = open('/root/.accesshash').read
end

describe 'Local CPanel information ' do
	# FIXME: dump test users/ dir into spec/data/ and use that for testing. no mocks please.
	xit 'retrieves user info' do
		userinfo = CPanelHelper::Local.get_cpstore_user_info('bigbang')
		assert_instance_of(Hash, userinfo)
		assert_equal 'bigbang', userinfo[:username]
	end

	it 'fails on nonexistent user' do
		expect {
			CPanelHelper::Local.get_cpstore_user_info('doesntexistnevahrrer34')
		}.to raise_error(CPanelHelper::NotFoundError)
	end

	context 'SSL functions' do
		context 'get certificates' do
			def get_certs(filter = nil)
				CPanelHelper::Local.get_installed_certificates(filter)
			end

			before (:all) do
				CPanelHelper.configure do |config|
					config.ssl_certs_db = File.expand_path('../../data/ssl.db', __FILE__)
				end
			end

			it 'for all domains' do
				certs = get_certs()
				expect(certs).not_to be_empty
				expect(certs).to have(3).hashes
				ci_ssl1 = certs.find{|ci| ci['owner'] == 'ssl1'}
				ci_ssl2 = certs.find{|ci| ci['owner'] == 'ssl2'}

				expect(certs.first.keys).to include(*%w{domains id issuer.commonName modulus not_after not_before owner subject.commonName crt_path})
				expect(ci_ssl1['not_after']).to eq(Time.at(1328796854).utc)
				expect(ci_ssl1['not_before']).to eq(Time.at(1328639002).utc)
				expect(ci_ssl1['domains']).to include('ssl1.cp2.test.fused.net')
				expect(ci_ssl1['subject.commonName']).to eq('ssl1.cp2.test.fused.net')
				expect(ci_ssl2['domains']).to include('cptest.com')
				#expect(certs).to contain
			end

			context 'for selected domain only' do
				it 'by regex filter' do
					certs = get_certs(/cptest/)
					expect(certs.first['domains']).to include('cptest.com')
				end

				it 'by string filter' do
					certs = get_certs('cptest.com')
					expect(certs.first['domains']).to include('cptest.com')
				end

			end
		end
	end
end
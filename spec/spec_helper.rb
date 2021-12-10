
$: << File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'rubygems'
require 'openssl'
require 'cpanelhelper'

require 'shoulda-matchers'


Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end

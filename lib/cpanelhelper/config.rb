require 'ostruct'

module CPanelHelper
	class Config
		# CPanel access hash, takes precedence over password auth
		attr_accessor :access_hash
		# Logger derivative
		attr_accessor :logger

		# Auth username
		attr_accessor :user
		attr_accessor :password

		# WHM API URI, with proto and port
		attr_accessor :uri_host

		# Call encoding
		attr_accessor :call_type

		# Domain data file
		attr_accessor :cpanel_domain_data_file

		attr_accessor :cpanel_user_data_dir

		# Set default values
		def initialize
			@cpanel_domain_data_file = '/etc/userdatadomains'
			@cpanel_user_data_dir    = '/var/cpanel/users'
		end
	end
end
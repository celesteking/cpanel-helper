
require 'cpanelhelper/core_ext/want-json'
require 'yaml'

require 'uri'
require 'forwardable'
require 'active_support/core_ext/hash'

require 'cpanelhelper/core_ext/open-yuri'
require 'cpanelhelper/logger_shim'
require 'cpanelhelper/api/adjusted_functions'

module CPanelHelper
	# CPanel API interaction module, deals with calling CPanel functions.
	module API
		class << self
			include LoggerShim
			include AdjustedFunctions

			def method_missing(method, *args)
				call(method.to_s, *args)
			end

			# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			# Call internal CPanel function.
			# @param [String] function_thunk Function name, format: username@ModuleName::function
			# @param [Hash] args Function arguments
			def call_internal(function_thunk, *args)
				args = args.extract_options!

				unless function_thunk.match(/^(([^@]+)@)?([^:]+?)::(.+)$/)
					raise(ArgumentError, "Wrong function name.")
				end

				query_args_add = {
						:cpanel_jsonapi_user => ($2 || 'root'),
						:cpanel_jsonapi_module => $3,
						:cpanel_jsonapi_func  => $4,
				}

				reply = cpanel(query_args_add.merge(args))

				error_string = reply['cpanelresult']['error'] rescue 'unkown error returned'
				if error_string
					error "[API] Internal call returned error: #{error_string}"
					raise(CallError, error_string)
				end

				[reply['cpanelresult']['data']].flatten.first
			end

			# Call CPanel JSON/XMLAPI function
			# @param [String] function Function name
			# @param [Hash] args Function arguments
			def call(function, *args)
				args = args.extract_options!

				call_type = config.call_type.to_sym

				auth_thunk = if config.access_hash
					"WHM root:#{config.access_hash}"
				else
					"Basic " + Base64.strict_encode64("#{config.user}:#{config.password}")
				end

				uri_path = (call_type == :json) ? "/json-api/#{function}" : raise(NotImplementedError)
				debug "[API] Calling #{config.uri_host}#{uri_path}, query: #{query_args(args)}"

				begin
					open(config.uri_host + uri_path + '?' + query_args(args), { "Authorization" => auth_thunk, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE }) do |resp|
						if call_type == :json
							reply = JSON.parse(resp.read)
						else
							raise NotImplementedError
						end

						if err_str = reply['error']
							error "[API] Error returned: #{err_str}"
							raise(CallError, err_str)
						end

						reply
					end
				rescue SystemExit
					error "Asked to terminate."
				rescue Exception => e
					error "Server reported error: #{e}"
					raise(CallError, e.message)
				end
			end

			# -----------------------------------------------------------------------------
			# load and set whm API key from local file
			def load_api_key(file_path)
				begin
					 config.access_hash = File.open(file_path).read.gsub!(/[\n\s\t]+/s, '')
				rescue SystemCallError => e
					error "Tried to load API KEY from #{file_path} but failed: #{e}."
					raise(CallError, 'API key load error')
				end
			end

			# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			protected
			def logger
				config.logger
			end

			private
			# Craft query string from supplied [Hash] ]args
			def query_args(*args)
				args = args.extract_options!

				args.collect {|k, v| "#{k}=#{v}"}.join('&')
			end

			def config
				CPanelHelper.config
			end
		end
	end
end

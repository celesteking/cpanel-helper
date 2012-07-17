
module CPanelHelper
	module API
		# Implements some adjustments / alternations to called functions and their results
		module AdjustedFunctions
			# Displays pertinent information about a specific account.
			# @param [String] user Username associated with the acount you wish to display.
			def accountsummary(user)
				result = call_api(__method__, :user => user)

				raise(RuntimeError, log_err_prefix + result['statusmsg']) if result['status'].nil? or result['status'] != 1

				result['acct'][0]
			end

			#
			def editquota(user, quota)
				debug "Setting quota for #{user} to #{quota} MB."

				result = call_api(__method__, :user => user, :quota => quota)

				raise(RuntimeError, log_err_prefix + result['output']) unless (result['result'][0]['status'] rescue nil)
				result['output']
			end

			# retrieves bw utilization for user/domain/package
			def showbw(*args)
				args = args.extract_options!
				raise ArgumentError, "required keys missing" unless ([:search, :searchtype] - args.keys).empty?

				result = call_api(__method__, args)
				raise(RuntimeError, "[API] (no data found)") if (result['bandwidth'][0]['acct'].empty? rescue true)

				result['bandwidth'][0]['acct'][0]
			end

			# sets bw limit
			def limitbw(user, limit)
				limit = 'unlimited' if limit == 0

				result = call_api(__method__, :user => user, :bwlimit => limit)

				raise(RuntimeError, log_err_prefix) if (result['result'][0]['status'] != 1 rescue true)

				{
						:statusmsg    => result['result'][0]['statusmsg'],
						:limit        => (result['result'][0]['bwlimit']['bwlimit'].to_i / 1024 / 1024).round,
						:human_bwused => result['result'][0]['bwlimit']['human_bwused']
				}
			end

			#
			def suspendacct(user, reason = nil)
				reason ||= '[empty]'
				reason = URI.escape(reason)

				result = call_api(__method__, :user => user, :reason => reason)

				raise(RuntimeError, log_err_prefix + result['result'][0]['statusmsg']) if (result['result'][0]['status'] != 1 rescue true)

				result['result'][0]['statusmsg']
			end

			#
			def unsuspendacct(user)
				result = call_api(__method__, :user => user)

				raise(RuntimeError, log_err_prefix + result['result'][0]['statusmsg']) if (result['result'][0]['status'] != 1 rescue true)

				result['result'][0]['statusmsg']
			end

			#
			def modifyacct(user, params)
				locase_params = [:domain, :newuser, :owner, :shell]
				fixup_params = {:maxparked => :maxpark, :maxaddons => :maxaddon }

				params.symbolize_keys!
				# fixup fuckup with naming
				params = Hash[params.collect {|k, v| fixup_params.include?(k) ? [fixup_params[k], v] : [k, v] }]

				# locase some params, upcasing all others
				params = Hash[params.collect {|k, v| locase_params.include?(k) ? [k.to_s, v] : [k.to_s.upcase, v] }]

				result = call_api(__method__, { :user => user }.merge(params))

				raise(RuntimeError, log_err_prefix + result['result'][0]['statusmsg']) if (result['result'][0]['status'] != 1 rescue true)

				result['result'][0]['newcfg']['cpuser']
			end

			#
			def changepackage(user, package)
				result = call_api(__method__, :user => user, :pkg => package)

				raise(RuntimeError, log_err_prefix + result['result'][0]['statusmsg']) if (result['result'][0]['status'] != 1 rescue true)

				result['result'][0]
			end

			#
			def listaccts(type, query)
				result = call_api(__method__, :searchtype => type, :search => query)

				raise(RuntimeError, log_err_prefix + result['statusmsg']) unless (result['status'] rescue nil)
				result['acct']
			end

			private
			# Make CPanel API call
			def call_api(func, *args)
				API.call(func, *args)
			end

			def log_err_prefix
				"[API] (call error) "
			end
		end
	end
end

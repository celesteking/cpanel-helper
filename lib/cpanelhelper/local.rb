
require 'active_support/core_ext/hash'
require 'active_support/core_ext/date_time/conversions'

require 'cpanelhelper/logger_shim'
require 'cpanelhelper/config'


module CPanelHelper
	# Deals with local functions invoked on local server. Requires access to _/var/cpanel_ and _/etc_ dir.
	module Local
		class << self
			include LoggerShim

			# Retrieve user information (fast)
			# @param [String] user
			# @return [Hash] userinfo
			# @raise [NotFoundError] on user not found
			def get_cpstore_user_info(user)
				user_data_file = File.join(user_data_dir, user)
				begin
					user_data_str = File.open(user_data_file).read
					user_data     = Hash[user_data_str.scan(/^([^=#\s]+)=(.*)$/).map { |e| [e[0].downcase, e[1]] }]
				rescue Errno::ENOENT, Errno::EACCES => e
					raise(NotFoundError, "Username #{user} not found")
				end
			end

			# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

			# Get domain info by domain name
			# @param [String] domain
			# @return [Hash] dominfo
			def get_dominfo_by_domain(domain)
				info = nil
				traverse_text_file(domain_data_file) do |line|
					if line.index(domain + ':') == 0
						info = parse_domain_data_line(line)
						break
					end
				end

				info
			end

			# Get dominfo by user
			# @param [String, NilClass] user Username or omit if you want all domain info to be returned
			# @return [Hash] Hash of dominfo values keyed by domain name
			def get_dominfo_by_user(user = nil)
				info = {}
				traverse_text_file(domain_data_file) do |line|
					dominfo = parse_domain_data_line(line)
					info[dominfo[:domain]] = dominfo if user.nil? or dominfo[:user] == user
				end

				info
			end

			# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

			# Find accounts by contact query
			# @param [String] query Search string
			# @param [String] matchtype One of 'exact', 'partial', 'regexp'
			# @return [Hash{String: String] Hash of usernames as keys with supplied query string as values
			def find_accounts_by_string(query, matchtype = 'exact')
				matches =
						case matchtype
							when 'partial'
								begin
									query = "*#{query}*" unless query.match(/^\*.+\*$/)
									Dir["#{user_data_dir}/#{query}"].collect { |x| File.basename(x) }
								rescue Errno::ENOENT
									[]
								end
							when 'regexp'
								Dir.new(user_data_dir).entries.select { |x| not x.match(/^\.{1,2}$/) and x.match(query) }.collect { |x| File.basename(x) }
							else
								File.file?(File.join(user_data_dir, query)) ? [query] : []
						end

				Hash[matches.collect { |userid| [userid, query] }]
			end

			# Find accounts by domain query
			# @param [String] query Search string
			# @param [String] matchtype One of 'exact', 'partial', 'regexp'
			# @return [Hash{Symbol: Array<String>] Values of (Array of domain names) keyed by username
			def find_accounts_by_domain(query, matchtype = 'exact')
				accounts = { }

				traverse_text_file(domain_data_file) do |line|
					dominfo     = parse_domain_data_line(line)
					domain_name = dominfo[:domain]
					userid      = dominfo[:user]

					got_match =
							case matchtype.to_s
								when 'regexp'
									domain_name.match(query)
								when 'partial'
									query.gsub!(/(^\*|\*$)/, '')
									domain_name.include?(query)
								else # exact
									domain_name == query
							end

					if got_match
						accounts[userid] ||= []
						accounts[userid].push(domain_name)
					end
				end

				accounts
			end

			# Find accounts by contact email query
			# @param [String] query Search string
			# @param [String] matchtype One of 'exact', 'partial', 'regexp'
			# @return [Hash{Symbol: Array<String>] Values of (Array of contact emails) keyed by username
			def find_accounts_by_email(query, matchtype = 'exact')
				accounts = { }

				for_all_cpanel_users do |userid|
					userinfo      = get_cpstore_user_info(userid)
					email, email2 = userinfo['contactemail'], userinfo['contactemail2']

					got_match =
							case matchtype.to_s
								when 'regexp'
									email.match(query) #or email2.match(query)
								when 'partial'
									query.gsub!(/(^\*|\*$)/, '')
									email.include?(query) #or email2.include?(query)
								else # exact
									email == query #or email2 == query
							end

					if got_match
						accounts[userid] ||= []
						accounts[userid].push(email)
						#						accounts[userid].push(email2) if email2 and not email2.empty?
					end
				end

				accounts
			end

			# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

			# Parses domain data line into Hash
			# @example
			#   $domain: $userid==$owner==$type==$main_domain==$docroot==$ip_port==$ssl_ip_port
			#   qwerty.cp2.test.fused.net: qwertycp==root==main==qwerty.cp2.test.fused.net==/home/qwertycp/public_html==69.162.148.26:80==69.162.148.26:443
			#   parked.cp.test.fused.net: law==root==parked==law.cp.test.fused.net==/home/law/public_html==69.162.148.25:80==
			# @return [Hash] {:user, :owner, :type, :main_domain, :docroot, :ip, :ssl, :domain}
			def parse_domain_data_line(line)
				return nil unless line.match(/^(.*?): (.*)$/)
				domain, domdata = $1, $2
				domdata_arr     = domdata.split('==')

				info = { :domain => domain }
				[:user, :owner, :type, :main_domain, :docroot, :ip, :ssl].each_with_index do |sym, idx|
					info[sym] = domdata_arr[idx]
				end

				info
			end

			# iterates over all users in *user_data_dir*
			def for_all_cpanel_users(&block)
				Dir.foreach(user_data_dir) do |filename|
					next if filename == '.' or filename == '..'
					block.call(filename)
				end
			end

			private
			# Iterates over a file, yielding each line
			# @raise [Errno::ENOENT] on error
			def traverse_text_file(text_file, &block)
				begin
					File.open(text_file) do |dfh|
						dfh.each_line do |line|
							block.call(line)
						end
					end
				rescue Errno::ENOENT, Errno::EACCES => e
					raise(Errno::ENOENT, "Error opening  #{text_file}: #{e}.")
				end
			end

			def user_data_dir
				CPanelHelper.config.cpanel_user_data_dir
			end

			def domain_data_file
				CPanelHelper.config.cpanel_domain_data_file
			end
		end
	end
end

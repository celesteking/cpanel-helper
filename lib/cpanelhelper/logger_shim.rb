
module CPanelHelper
	# Contains logger functions
	module LoggerShim
		# Logger functions
		%w{fatal error warn info debug}.each do |log_lvl|
			define_method(log_lvl) do |*opts|
				logger.send(log_lvl, opts.join) if logger
			end
		end
	end
end

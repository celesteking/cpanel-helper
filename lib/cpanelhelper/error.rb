module CPanelHelper
  # All cpanelhelper errors derive from this one
  class Error < StandardError
  end

  # CPanel API call error
  class CallError < Error
  end

  # No such entity (username, domain, email, ...) was found
  class NotFoundError < Error
  end
end
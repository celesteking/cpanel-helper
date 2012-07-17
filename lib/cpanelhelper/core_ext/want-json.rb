
unless Object.const_defined?(:JSON)
  begin
    require 'json_pure'
  rescue LoadError
    begin
      require 'json-ruby'
    rescue LoadError
      require 'json'
    end
  end
end

unless Object.const_defined?(:JSON)
  raise "Could not find any suitable JSON variant. Did you install one of json_pure, json-ruby, or the C-based json library?"
end

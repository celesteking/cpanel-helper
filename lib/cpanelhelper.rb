require 'cpanelhelper/version'
require 'cpanelhelper/error'
require 'cpanelhelper/config'

module CPanelHelper
  autoload :API, 'cpanelhelper/api'
  autoload :Local, 'cpanelhelper/local'

  @config ||= Config.new

  class << self
    attr_accessor :config

    def configure
      yield(config) if block_given?
      config
    end
  end
end

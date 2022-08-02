# frozen_string_literal: true

require_relative "plugins/version"

require "kramdown"

module Kramdown
  module KramdownPlugins
    @registered_plugins = []

    def self.registered_plugins
      @registered_plugins
    end

    def self.register_plugin(plugin)
      @registered_plugins << plugin
    end
  end
end

require_relative "parser/plugins_parser"

# frozen_string_literal: true

module Kramdown
  module Parser
    class PluginsParser < Kramdown::Parser::Kramdown
      attr_accessor :block_parsers, :span_parsers

      def self.define_parser(name, start_re, span_start = nil, meth_name = "parse_#{name}")
        # Don't raise an error like Kramdown's default, just return existing parser
        @@parsers[name] ||= Data.new(name, start_re, span_start, meth_name)
      end

      # Make default codeblock regex a little more like GFM
      @@parsers.delete(:codeblock_fenced)
      FENCED_CODEBLOCK_START = %r{^ {0,3}[~`]{3,}}.freeze
      FENCED_CODEBLOCK_MATCH = %r{^ {0,3}(([~`]){3,})\s*?((\S+?)(?:\?\S*)?)?\s*?\n(.*?)^\1\2*\s*?\n}m.freeze
      define_parser(:codeblock_fenced, FENCED_CODEBLOCK_START)

      def initialize(source, options)
        source, options = configure_registered_plugins(source, options)

        super

        include_registered_plugins
      end

      def parse
        super

        Kramdown::KramdownPlugins.registered_plugins.each do |plugin|
          plugin.after_parse(self) if plugin.respond_to?(:after_parse)
        end
      end

      def parse_codeblock_fenced
        ret = catch :codeblock_processed do
          Kramdown::KramdownPlugins.registered_plugins.each do |plugin|
            send(plugin.fenced_codeblock_extension) if plugin.respond_to?(:fenced_codeblock_extension)
          end
          nil # make sure to return nil if nothing had been caught
        end

        if ret.nil?
          # We'll just pass along to the basic Kramdown parsing
          super
        else
          ret
        end
      end

      private

      def configure_registered_plugins(source, options)
        Kramdown::KramdownPlugins.registered_plugins.each do |plugin|
          ret = plugin.configure(self.class, source, options)

          if ret.is_a?(Hash)
            source = ret[:source] if ret[:source]
            options = ret[:options] if ret[:options]
          end
        end

        [source, options]
      end

      def include_registered_plugins
        Kramdown::KramdownPlugins.registered_plugins.each do |plugin|
          plugin.parsers(self)

          singleton_class.extend plugin::ClassMethods if defined?(plugin::ClassMethods)
          singleton_class.include plugin::InstanceMethods if defined?(plugin::InstanceMethods)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "test_helper"

module Kramdown
  module KramdownPlugins
    module Mark
      MARK_DELIMITER = %r{(==|::)+}.freeze
      MARK_MATCH = %r{#{MARK_DELIMITER}(?!\s|=|:).*?[^\s=:]#{MARK_DELIMITER}}m.freeze

      def self.configure(klass, source, options)
        klass.define_parser :mark, MARK_MATCH

        raise "options are missing!" unless options[:input] == :PluginsParser

        {
          source: "#{source}\nHaha!"
        }
      end

      def self.parsers(parser)
        parser.span_parsers << :mark
      end

      module InstanceMethods
        def parse_mark
          line_number = @src.current_line_number

          @src.pos += @src.matched_size
          el = Element.new(:html_element, "mark", {}, category: :span, line: line_number)
          @tree.children << el

          env = save_env
          reset_env(src: Kramdown::Utils::StringScanner.new(@src.matched[2..-3], line_number),
                    text_type: :text)
          parse_spans(el)
          restore_env(env)

          el
        end
      end
    end

    register_plugin Mark
  end
end

class Kramdown::TestPlugins < Minitest::Test
  def setup
    @text = <<~MD
      # Regular Markdown Here

      *More ::Markdown:: continues...*

      That's pretty ==awesome==.

      ```ruby
      @a = 123
      ```
    MD
  end

  def test_correct_output
    doc = Kramdown::Document.new(@text, { input: :PluginsParser })
    html = doc.to_html
    assert_equal 2, html.scan("<mark>").size
    assert_equal 1, html.scan("Haha!").size
    assert_equal 1, html.scan('<pre><code class="language-ruby">@a = 123').size
  end
end

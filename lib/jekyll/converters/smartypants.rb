# frozen_string_literal: true

module Kramdown
  module Parser
    class SmartyPants < Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @block_parsers = [:block_html, :content]
        @span_parsers =  [:smart_quotes, :html_entity, :typographic_syms, :span_html]
      end

      def parse_content
        add_text @src.scan(%r!\A.*\n!)
      end
      define_parser(:content, %r!\A!)
    end
  end
end

module Jekyll
  module Converters
    class SmartyPants < Converter
      safe true
      priority :low

      def initialize(config)
        Jekyll::External.require_with_graceful_fail "kramdown" unless defined?(Kramdown)
        @config = config["kramdown"].dup || {}
        @config[:input] = :SmartyPants
      end

      def matches(_)
        false
      end

      def output_ext(_)
        nil
      end

      def convert(content)
        document = Kramdown::Document.new(content, @config)
        html_output = document.to_html.chomp
        if @config["show_warnings"]
          document.warnings.each do |warning|
            Jekyll.logger.warn "Kramdown warning:", warning.sub(%r!^Warning:\s+!, "")
          end
        end
        html_output
      end
    end
  end
end

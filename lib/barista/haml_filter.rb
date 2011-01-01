module Barista
  module HamlFilter
    module CoffeeScript
      
      def render_with_options(text, options)
        type = render_type
        case type
        when :coffeescript
          content_type  = 'text/coffeescript'
          cdata_wrapper = '#%s'
          inner         = text
        when :javascript
          content_type  = 'text/javascript'
          cdata_wrapper = '//%s'
          inner         = Barista::Compiler.compile(text)
        end
        output = []
        output << "<script type=#{options[:attr_wrapper]}#{content_type(type)}#{options[:attr_wrapper]}>"
        output << "  #{cdata_wrapper % '<![CDATA['}"
        output << "  #{inner}".rstrip.gsub("\n", "\n  ")
        output << "  #{cdata_wrapper % ']]>'}"
        output << "</script>"
        output.join("\n")
      end
     
      def render_type
        Barista.embedded_interpreter? ? :coffeescript : :javascript
      end
      
      def content_type(render_type)
        Barista::Server::CONTENT_TYPE_MAPPING[render_type]
      end
        
    end
    
    def self.setup
      if defined?(Haml)
        require 'haml/filters'
        CoffeeScript.module_eval { include Haml::Filters::Base }
      end
    end
  end
end
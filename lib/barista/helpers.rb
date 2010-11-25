module Barista
  module Helpers
    
    def coffeescript_interpreter_js
      return if defined?(@coffeescript_embedded) && @coffeescript_embedded
      check_for_helper_method! :javascript_include_tag
      @coffeescript_embedded = true
      if Barista.embedded_interpreter?
        javascript_include_tag 'coffeescript'
      end
    end
    
    def coffeescript_include_tag(*names)
      check_for_helper_method! :javascript_include_tag
      if Barista.embedded_interpreter?
        output = defined?(ActiveSupport::SafeBuffer) ? ActiveSupport::SafeBuffer.new : ""
        output << coffeescript_interpreter_js
        check_for_helper_method! :content_tag
        Array(names).each do |name|
          output << "\n"
          output << content_tag(:script, '', :type => 'text/coffeescript', :src => normalise_coffeescript_path(name.to_s))
        end
        output
      else
        javascript_include_tag(*names)
      end
    end
    
    def coffeescript_tag(code, html_options = {})
      check_for_helper_method! :javascript_tag
      if Barista.embedded_interpreter?
        check_for_helper_method! :content_tag
        output = defined?(ActiveSupport::SafeBuffer) ? ActiveSupport::SafeBuffer.new : ""
        output << coffeescript_interpreter_js 
        embed = "\n#<![CDATA[\n#{code}\n#]]>\n"
        embed = embed.html_safe if embed.respond_to?(:html_safe)  
        output << content_tag(:script, embed, html_options.merge(:type => 'text/coffeescript'))
        output
      else
        javascript_tag Barista::Compiler.compile(code), html_options
      end
    end
    
    protected
    
    def normalise_coffeescript_path(path)
      if respond_to?(:compute_public_path)
        compute_public_path path, 'coffeescript', 'coffee'
      else
        path = path.gsub(/\.(js|coffee)$/, '') + '.coffee'
        path = "/coffeescripts/#{path}" unless path =~ /^\//
        path
      end
    end
    
    def check_for_helper_method!(name)
      raise "Please make sure #{name} is available." unless respond_to?(name)
    end
    
  end
end
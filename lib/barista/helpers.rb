module Barista
  module Helpers
    
    def coffeescript_interpreter_js
      return if defined?(@coffeescript_embedded) && @coffeescript_embedded
      if Barista.embedded_interpreter?
        @coffeescript_embedded = true
        embed = '<script type="text/javascript" src="/javascripts/coffeescript.js"></script>'
        embed = embed.html_safe if embed.respond_to?(:html_safe)
        embed
      end
    end
    
    def coffeescript_include_tag(*names)
      raise 'Please make sure javascript_include_tag is defined' unless respond_to?(:javascript_include_tag)
      if Barista.embedded_interpreter?
        output = defined?(ActiveSupport::SafeBuffer) ? ActiveSupport::SafeBuffer.new : ""
        output << coffeescript_interpreter_js
        raise 'Please make sure content_tag is defined' unless respond_to?(:content_tag)
        Array(names).each do |name|
          output << "\n"
          output << content_tag(:script, '', :type => 'text/coffeescript', :src => normalise_coffeescript_path(name.to_s))
        end
        output
      else
        javascript_include_tag *names
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
    
  end
end
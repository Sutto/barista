require 'rack/utils'

module Barista
  class Server

    CACHE_FOR_SECONDS   = 300
    JS_CONTENT_TYPE     = 'text/javascript'
    COFFEE_CONTENT_TYPE = 'text/coffeescript'
    PATH_REGEXP         = /^\/(coffee|java)scripts\//
    
    # Extensions to the type.
    EXTENSION_MAPPING   = {
      '.coffee' => :coffeescript,
      '.js'     => :javascript
    }
    
    # Content types for responses.
    CONTENT_TYPE_MAPPING = {
      :coffeescript => COFFEE_CONTENT_TYPE,
      :javascript   => JS_CONTENT_TYPE
    }
    
    class Proxy
      
      def initialize(app)
        @app = app
        @server = Server.new
      end
      
      def call(env)
        result = @server.call(env)
        if result[0] == 404
          @app.call(env)
        else
          result
        end
      end
      
    end

    def initialize
      # Cache the responses for common errors.
      forbidden
      not_found
    end

    def call(env)
      dup._call(env)
    end
    
    def _call(env)
      @path_info = Rack::Utils.unescape(env['PATH_INFO'].to_s)
      return not_found unless @path_info =~ PATH_REGEXP
      # Strip the prefix.
      @path_info.gsub! PATH_REGEXP, ''
      # Check it's a valid path.
      return forbidden if @path_info.include?('..')
      
      # If coffeescript.js is the request, render the coffeescript compiler code.
      if @path_info == 'coffeescript.js'
        return response_for_text(CoffeeScript::Source.contents)
      end
      # Look up the type of the file based off of the extension.
      @result_type = EXTENSION_MAPPING[File.extname(@path_info)]
      return not_found if @result_type.nil? || (@result_type == :coffeescript && !Barista.embedded_interpreter?)
      # Process the difference in content type.
      content, last_modified = Barista::Compiler.compile_as(@path_info, @result_type)
      if content.nil?
        not_found
      else
        response_for_text content, CONTENT_TYPE_MAPPING[@result_type], last_modified
      end
    end
    
    protected
    
    def forbidden
      @_forbidden_response ||= begin
        body = "Forbidden\n"
        [403, {
          'Content-Type'   => 'text/plain',
          'Content-Length' => Rack::Utils.bytesize(body).to_s,
          'X-Cascade'      => 'pass'
        }, [body]]
      end
    end
    
    def not_found
      @_not_found_response ||= begin
        body = "Not Found\n"
        [404, {
          'Content-Type'   => 'text/plain',
          'Content-Length' => Rack::Utils.bytesize(body).to_s,
          'X-Cascade'      => 'pass'
        }, [body]]
      end
    end
    
    def response_for_text(content, content_type = 'text/javascript', modified_at = nil)
      headers = {
        'Content-Type'   => content_type,
        'Content-Length' => Rack::Utils.bytesize(content).to_s,
        'Cache-Control'  => "public, max-age=#{CACHE_FOR_SECONDS}"  
      }
      headers.merge!('Last-Modified'  => modified_at.httpdate) unless modified_at.nil?
      [200, headers, [content]]
    end

  end
end

module Barista
  class Filter

    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      Barista.debug 'Compiling all scripts for barista' if Barista.auto_compile?
      Barista.compile_all!
      # Now, actually call the app.
      @app.call env
    end

  end
end

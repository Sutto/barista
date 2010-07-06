module Barista
  class Filter

    def self.filter(controller)
      Rails.logger.debug "[Barista] Compiling all scripts"
      Barista.compile_all!
    end

  end
end

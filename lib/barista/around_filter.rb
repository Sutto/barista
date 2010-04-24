module Barista
  class AroundFilter
    
    def self.filter(controller)
      Barista.compile_all!
      yield if block_given?
    end
  
  end
end
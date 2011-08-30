module Barista
  class Hooks
    
    def initialize
      @callbacks = Hash.new { |h,k| h[k] = [] }
    end
    
    def on(name, &blk)
      @callbacks[name.to_sym] << blk
    end
    
    def invoke(name, *args)
      @callbacks[name.to_sym].each do |callback|
        break if callback.call(*args) == false
      end
      nil
    end
    
    def has_hook?(name)
      @callbacks.has_key?(name)
    end
            
  end
end

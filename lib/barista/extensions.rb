module Barista
  module Extensions
    
    def self.included(parent)
      parent.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods
      
      def has_boolean_options(*names)
        names.each do |name|
          class_eval(<<-EOM, __FILE__, __LINE__)
            
            def #{name}!
              @#{name} = true
            end
            
            def #{name}?
              defined?(@#{name}) ? @#{name} : default_for_#{name}
            end
            
            def #{name}=(value)
              @#{name} = !!value
            end
            
            def default_for_#{name}
              false
            end
            
          EOM
        end
      end
      
      def has_hook_method(options)
        options.each_pair do |name, event|
          class_eval(<<-EOM, __FILE__, __LINE__)
            def #{name}(&blk)
              on_hook #{event.to_sym.inspect}, &blk
            end
          EOM
        end
      end
      
    end
    
    module InstanceMethods
      
      def deprecate!(object, method, other = nil)
        klass_prefix = (object.is_a?(Class) || object.is_a?(Module)) ? "#{object.name}." : "#{object.class.name}#"
        warn "#{klass_prefix}#{method} is deprecated and will be removed in 1.0. #{other}".strip
      end
      
    end
    
  end
end
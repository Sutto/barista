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
        source = []
        names.each do |name|
          source << <<-EOM
            
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
        class_eval source.join("\n"), __FILE__, __LINE__
      end
      
      def has_hook_method(options)
        source = []
        options.each_pair do |name, event|
          source << <<-EOM
            def #{name}(&blk)
              on_hook #{event.to_sym.inspect}, &blk
            end
          EOM
        end
        class_eval source.join("\n"), __FILE__, __LINE__
      end

      def has_delegate_methods(delegate, *args)
        source = []
        args.each do |method|
          source << <<-EOM

            def #{method}(*args, &blk)
              #{delegate}.send(:#{method}, *args, &blk)
            end

          EOM
        end
        class_eval source.join("\n"), __FILE__, __LINE__
      end
      
      def has_deprecated_methods(*args)
        source = []
        args.each do |method|
          source << <<-EOM

            def #{method}(*args, &blk)
              Barista.deprecate!(self, :#{method})
              nil
            end

          EOM
        end
        class_eval source.join("\n"), __FILE__, __LINE__
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
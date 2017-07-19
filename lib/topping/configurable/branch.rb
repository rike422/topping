module Topping
  # Mixin to add the ability for a plugin to define configuration.
  # @since 0.0.1
  module Configurable
    module Branch
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      # The Leaf class configuration object.
      # @return [Configuration, Config] The Leaf class configuration object.
      # @since 0.0.1
      def config
        self.class.configuration_builder.configuration
      end

      module ClassMethods
        # Initializes the configuration builder for any inheriting classes.
        def inherited(klass)
          super
          klass.extend(Topping::Configurable::Branch::ChildClassMethods)
          klass.configuration_builder = ConfigurationBuilder.new
          Topping::Configurable::HQ.mapping(klass)
        end
      end

      module ChildClassMethods
        include Topping::Configurable

        def configure(&block)
          configuration_builder.configure(&block)
        end
      end
    end
  end
end

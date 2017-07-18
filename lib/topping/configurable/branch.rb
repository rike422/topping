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
        # A block to be executed after configuration is finalized.
        # @return [#call, nil] The block.
        # @since 0.0.1
        # @api private
        attr_accessor :after_config_block

        # The plugins's {ConfigurationBuilder} object.
        # @return [ConfigurationBuilder] The configuration builder.
        # @since 0.0.1
        # @api public
        attr_accessor :configuration_builder
        # Registers a block to be executed after configuration is finalized.
        # @yieldparam config [Configuration] The handler's configuration object.
        # @return [void]
        # @since 0.0.1
        def after_config(&block)
          self.after_config_block = block
        end

        # Sets a configuration attribute on the plugin.
        # @return [void]
        # @since 0.0.1
        # @see ConfigurationBuilder#config
        def config(*args, **kwargs, &block)
          if block
            configuration_builder.config(*args, **kwargs, &block)
          else
            configuration_builder.config(*args, **kwargs)
          end
        end

        # Yields the configuration object
        # @yieldparam [Configuration] config The configuration object.
        # @since 0.0.1
        # @see ConfigurationBuilder#config
        def configure(&block)
          configuration_builder.configure(&block)
        end
      end
    end
  end
end

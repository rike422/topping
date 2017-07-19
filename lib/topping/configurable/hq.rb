module Topping
  # Mixin to add the ability for a plugin to define configuration.
  # @since 0.0.1
  module Configurable
    module HQ
      # The top-level {ConfigurationBuilder} attribute.
      # @return [Configuration] The root attribute.
      attr_accessor :root

      # The top-level {ConfigurationBuilder} attribute.
      # @api private
      attr_accessor :name_space

      # Sets a configuration attribute on the application.
      # @return [void]
      # @since 0.0.1
      # @see ConfigurationBuilder#config
      def config(*args, **kwargs, &block)
        if block
          root.config(*args, **kwargs, &block)
        else
          root.config(*args, **kwargs)
        end
      end

      # Sets a configuration attribute on the application.
      # @return [void]
      # @since 0.0.1
      def build
        root.build
      end

      # @api private
      def mapping(klass)
        keys = Topping.underscore_namespace(klass) - name_space
        klass_name = keys.pop

        parent = keys.reduce(root) do |memo, key|
          config = memo.children.find { |child| child.name == key }
          config = memo.config(key) if config.nil?
          config
        end
        parent.combine(klass_name, klass.configuration_builder)
      end

      def inherited(klass)
        klass.extend(Topping::Configurable::HQ::ChildClassMethods)
        klass.root = root
      end

      class << self
        # The top-level Configurable Class
        # @api private
        # @return [Configuration] The root attribute.
        attr_accessor :hq_class

        def mapping(klass)
          hq_class.mapping(klass)
        end

        def extended(klass)
          super
          self.hq_class = klass
          klass.name_space = Topping.underscore_namespace(klass)

          config = Topping.root.config(klass.name_space.first)
          klass.root = config
        end
      end

      module ChildClassMethods
        # The top-level {ConfigurationBuilder} attribute.
        # @return [Configuration] The root attribute.
        attr_accessor :root

        # Yields the configuration object
        # @yieldparam [Configuration] config The configuration object.
        # @since 0.0.1
        # @see ConfigurationBuilder#config
        def configure
          yield root.configuration
        end

        # User configuration store
        # @return [Configuration] The root attribute.
        # @since 0.0.1
        def config
          root.configuration
        end
      end
    end
  end
end

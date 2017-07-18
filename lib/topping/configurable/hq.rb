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

      # Yields the configuration object
      # @yieldparam [Configuration] config The configuration object.
      # @since 0.0.1
      # @see ConfigurationBuilder#config
      def configure
        yield root.configuration.send(name_space.first.to_sym)
      end

      # User configuration store
      # @return [Configuration] The root attribute.
      # @since 0.0.1
      def config
        root.configuration.send(name_space.first.to_sym)
      end

      def build
        @root.build
      end

      # @api private
      def mapping(klass)
        keys = Topping::Configurable::HQ.undersocre_namespace(klass)
        keys.delete(name_space)
        klass_name = keys.pop

        parent = keys.reduce(root) do |memo, key|
          config = memo.children.find { |child| child.name == key }
          config = memo.config(key) if config.nil?
          config
        end
        parent.combine(klass_name, klass.configuration_builder)
      end

      class << self
        # The top-level Configurable Class
        # @api private
        # @return [Configuration] The root attribute.
        attr_accessor :hq_class

        def included(klass)
          klass.extend(Topping::Configurable::HQ)
        end

        def mapping(klass)
          hq_class.mapping(klass)
        end

        def extended(klass)
          super
          self.hq_class = klass
          root_config = ConfigurationBuilder.new
          klass.root = root_config
          klass.name_space = Topping::Configurable::HQ.undersocre_namespace(klass)
        end

        def undersocre_namespace(klass)
          klass.name.split('::').map do |key|
            Topping::Configurable::HQ.underscore(key)
          end
        end

        def underscore(str)
          str.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr('-', '_').
            downcase
        end
      end
    end
  end
end

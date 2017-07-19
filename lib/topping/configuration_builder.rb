module Topping
  # An object that stores user settings
  # @since 0.0.1
  class Configuration
  end

  # Provides a DSL for building {Configuration} objects.
  # @since 0.0.1
  class ConfigurationBuilder
    # An array of any nested configuration builders.
    # @return [Array<ConfigurationBuilder>] The array of child configuration builders.
    # @api private
    attr_reader :children

    # A object that stores user settings
    # @return [Boolean] Whether or not the attribute is required.
    # @api private
    attr_reader :configuration

    # An array of valid types for the attribute.
    # @return [Array<Object>] The array of valid types.
    # @api private
    attr_reader :types

    # A block used to validate the attribute.
    # @return [Proc] The validation block.
    # @api private
    attr_reader :validator

    # The name of the configuration attribute.
    # @return [String, Symbol] The attribute's name.
    # @api private
    attr_accessor :name

    # The value of the configuration attribute.
    # @return [Object] The attribute's value.
    # @api private
    attr_accessor :value

    # A boolean indicating whether or not the attribute must be set.
    # @return [Boolean] Whether or not the attribute is required.
    # @api private
    attr_accessor :required

    alias required? required

    class << self
      # Deeply freezes a configuration object so that it can no longer be modified.
      # @param config [Configuration] The configuration object to freeze.
      # @return [void]
      # @api private
      def freeze_config(config)
        IceNine.deep_freeze!(config)
      end
    end

    def initialize
      @children = []
      @name = :root
    end

    # Merges two configuration builders by making one an attribute on the other.
    # @yield The configuration object
    def configure
      yield configuration
    end

    # Builds a {Configuration} object from the attributes defined on the builder.
    # @param object [Configuration] The empty configuration object that will be extended to
    #   create the final form.
    # @return [Configuration] The fully built configuration object.
    # @api private
    def build(object = Configuration.new)
      container = if children.empty?
                    build_leaf(object)
                  else
                    build_nested(object)
                  end

      @configuration = container.public_send(name)
    end

    # Returns a boolean indicating whether or not the attribute has any child attributes.
    # @return [Boolean] Whether or not the attribute has any child attributes.
    # @api private
    def children?
      !children.empty?
    end

    # Merges two configuration builders by making one an attribute on the other.
    # @param name [String, Symbol] The name of the new attribute.
    # @param attribute [ConfigurationBuilder] The configuration builder that should be its
    #   value.
    # @return [void]
    # @api private
    def combine(name, attribute)
      attribute.name = name

      children << attribute
    end

    # rubocop:disable Metrics1/ParameterLists
    # Declares a configuration attribute.
    # @param name [String, Symbol] The attribute's name.
    # @param types [Object, Array<Object>] Optional: One or more types that the attribute's value
    #   must be.
    # @param type [Object, Array<Object>] Optional: One or more types that the attribute's value
    #   must be.
    # @param required [Boolean] Whether or not this attribute must be set. If required
    # @param default [Object] An optional default value for the attribute.
    # @yield A block to be evaluated in the context of the new attribute. Used for
    #   defining nested configuration attributes and validators.
    # @return [void]
    def config(name, types: nil, type: nil, required: false, default: nil, &block)
      attribute = self.class.new
      attribute.name = name
      attribute.types = types || type
      attribute.required = required
      attribute.value = default
      attribute.instance_exec(&block) if block

      children << attribute
      attribute
    end

    # Sets the valid types for the configuration attribute.
    # @param types [Object, Array<Object>] One or more valid types.
    # @return [void]
    # @api private
    def types=(types)
      @types = Array(types) if types
    end

    # Declares a block to be used to validate the value of an attribute whenever it's set.
    # Validation blocks should return any object to indicate an error, or +nil+/+false+ if
    # validation passed.
    # @yield The code that performs validation.
    # @return [void]
    def validate!(&block)
      validator = block

      unless value.nil?
        error = validator.call(value)
        raise ValidationError, error if error
      end

      @validator = block
    end

    # Sets the value of the attribute, raising an error if it is not among the valid types.
    # @param value [Object] The new value of the attribute.
    # @return [void]
    # @raise [TypeError] If the new value is not among the declared valid types.
    # @api private
    def value=(value)
      ensure_valid_default_value(value)

      @value = value
    end

    private

    # Finalize a nested object.
    def build_leaf(object)
      this = self
      run_validator = method(:run_validator)
      types_validation = method(:types_validation!)

      object.instance_exec do
        define_singleton_method(this.name) { this.value }
        define_singleton_method("#{this.name}=") do |value|
          run_validator.call(value)
          types_validation.call(value)
          this.value = value
        end
      end
      object
    end

    # Finalize the root builder or any builder with children.
    def build_nested(object)
      this = self

      nested_object = Configuration.new
      children.each { |child| child.build(nested_object) }
      object.instance_exec { define_singleton_method(this.name) { nested_object } }

      object
    end

    # rubocop:disable Style/CaseEquality:
    # Check's the value's type from inside the finalized object.
    def types_validation!(value)
      raise ValidationError if types && types.none? { |type| type === value }
    end

    # Raise if value is non-nil and isn't one of the specified types.
    def ensure_valid_default_value(value)
      return unless !value.nil? && types && types.none? { |type| type === value }
      raise TypeError
    end

    # Runs the validator from inside the build configuration object.
    def run_validator(value)
      return unless validator
      error = validator.call(value)
      raise ValidationError unless error.nil?
    end
  end
end

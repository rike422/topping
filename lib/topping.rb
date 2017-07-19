require 'topping/version'
require 'topping/configuration_builder'
require 'topping/errors'

module Topping
  # Your code goes here...
  class << self
    # rubocop:disable Style/ClassVars
    @@root = ConfigurationBuilder.new

    def root
      @@root
    end

    def build
      root.build
    end

    def underscore_namespace(klass)
      klass.name.split('::').map do |key|
        Topping.underscore(key)
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

require 'topping/configurable'

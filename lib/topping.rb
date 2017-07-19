require 'topping/version'

module Topping
  # Your code goes here...
  class << self
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

require 'topping/configurable'
require 'topping/configuration_builder'
require 'topping/errors'

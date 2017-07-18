module MockApplication
  module Features
    class Net < MockApplication::Features::Base
      config :host, required: true, type: String
      config :port, required: true, type: Integer
      config :protocol, default: :https do
        validate! do |value|
          case value
          when :https, :http
          else
            'Not support'
          end
        end
      end
    end
  end
end
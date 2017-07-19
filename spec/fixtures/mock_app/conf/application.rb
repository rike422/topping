module MockApplication
  class BaseApplication
    extend Topping::Configurable::HQ
    config :store, default: :memory
    config :name, default: 'myapp'
    config :dir, type: String
  end
end

module MockApplication
  class Application < MockApplication::BaseApplication
    config.dir = 'work'
  end
end
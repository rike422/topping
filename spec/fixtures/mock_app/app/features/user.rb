module MockApplication
  module Features
    class User < MockApplication::Features::Base
      config :username, required: true, type: String
      config :password, required: true, type: String
    end
  end
end
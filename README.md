# Topping

Configuration library for like a [Lita](https://github.com/litaio/lita) style application 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'topping'
```

## Usage

```ruby

require 'topping'

module MockApplication
  class Application
    include Topping::Configurable::HQ
  end
end

module MockApplication
  module Features
    class Base
      include Topping::Configurable::Branch
    end
    
    class Net < MockApplication::Features::Base
      config :host, required: true, type: String
      config :port, required: true, type: Integer
    end
    
    class User < MockApplication::Features::Base
      config :username, required: true, type: String
      config :password, required: true, type: String
    end
  end
end

MockApplication::Application.build

MockApplication::Application.configure do |c|
	c.features.net.host = 'github.com'
	c.features.net.port = 80
	
	c.features.user.username = 'akira takahashi'
	c.features.user.password = 'password'	
end

net = MockApplication::Features::Net.new
user = MockApplication::Features::User.new

p net.config.host 
# => 'github.com'
p net.config.port 
# => 89

p user.config.username
# => 'akira takahashi'
p user.config.password
# => 'password'

```

or 

```ruby
require 'topping'

module MockApplication
  class Application
    include Topping::Configurable::HQ
  end
end

module MockApplication
  module Features
    class Base
      include Topping::Configurable::Branch
    end
    
    class Net < MockApplication::Features::Base
      config :host, required: true, type: String
      config :port, required: true, type: Integer
    end
    
    class User < MockApplication::Features::Base
      config :username, required: true, type: String
      config :password, required: true, type: String
    end
  end
end

MockApplication::Application.build

MockApplication::Features::Net.configure do |c|
	c.host = 'github.com'
	c.port = 80
end
	
MockApplication::Features::User.configure do |c|
	c.username = 'akira takahashi'
	c.password = 'password'	
end

p MockApplication::Application.config.features.net.host
# => 'github.com'
p MockApplication::Application.config.features.net.port
# => 80
p MockApplication::Application.config.features.user.username
# => 'akira takahashi'
p MockApplication::Application.config.features.user.password
# => 'password'

```

# Topping [![Gem Version](https://badge.fury.io/rb/topping.svg)](https://badge.fury.io/rb/topping) [![Build Status](https://travis-ci.org/rike422/topping.svg?branch=master)](https://travis-ci.org/rike422/topping) [![Code Climate](https://codeclimate.com/github/rike422/topping/badges/gpa.svg)](https://codeclimate.com/github/rike422/topping) [![Coverage Status](https://coveralls.io/repos/github/rike422/topping/badge.svg?branch=master)](https://coveralls.io/github/rike422/topping?branch=master)
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
  class BaseApplication
    extend Topping::Configurable::HQ
    config :store, default: :memory
    config :name, default: 'myapp'
    config :dir, type: String
  end
end

module MockApplication
  class Application < MockApplication::BaseApplication
  	config.store = :redis
  	config.name = 'topping_app'
  	config.dir = 'work'
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

Topping.build

MockApplication::Application.configure do |c|
	c.features.net.host = 'github.com'
	c.features.net.port = 80
	
	c.features.user.username = 'akira takahashi'
	c.features.user.password = 'password'	
end

net = MockApplication::Features::Net.new
user = MockApplication::Features::User.new 

p MockApplication::Application.config.name
# => 'topping_app'
p MockApplication::Application.config.store
# => :redis
p MockApplication::Application.config.dir
# => 'work'

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
  class BaseApplication
    extend Topping::Configurable::HQ
    config :store, default: :memory
    config :name, default: 'myapp'
    config :dir, type: String
  end
end

module MockApplication
  class Application < MockApplication::BaseApplication
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

Topping.build

MockApplication::Features::Net.configure do |c|
	c.host = 'github.com'
	c.port = 80
end
	
MockApplication::Features::User.configure do |c|
	c.username = 'akira takahashi'
	c.password = 'password'	
end

p MockApplication::Application.config.name
# => 'topping_app'

p MockApplication::Application.config.store
# => :redis

p MockApplication::Application.config.dir
# => 'work'

p MockApplication::Application.config.features.net.host
# => 'github.com'
p MockApplication::Application.config.features.net.port
# => 80
p MockApplication::Application.config.features.user.username
# => 'akira takahashi'
p MockApplication::Application.config.features.user.password
# => 'password'

```

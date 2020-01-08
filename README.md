# RackRouter

Simple and functional rack middleware for routing requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack_router'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rack_router

## Usage

`config.ru`
```ruby
class App
  def call(env)
    meth = env[Rack::Router::RACK_ROUTER_PATH]
    public_send(env)
  end

  def posts_index(env)
    [200, {}, ['OK']]
  end

  def posts_show(env)
    id = env[Rack::Router::RACK_ROUTER_PATH_HASH][:id]
    [200, {}, ['OK']]
  end

  def posts_create(env)
    [201, {}, ['Created']]
  end

  def posts_update(env)
    id = env[Rack::Router::RACK_ROUTER_PATH_HASH][:id]
    [200, {}, ['Updated']]
  end

  def posts_destroy(env)
    id = env[Rack::Router::RACK_ROUTER_PATH_HASH][:id]
    [204, {}, []]
  end
end

app = Rack::Builder.new do
  use Rack::Router::Middleware do
    get '/posts', 'posts_index'
    get '/posts/:id', 'posts_show'
    post '/posts', 'posts_create'
    put '/posts/:id', 'posts_update'
    delete '/posts/:id', 'posts_destroy'
  end

  run App.new
end
run app
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/senid231/rack_router. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rack_router/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RackRouter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack_router/blob/master/CODE_OF_CONDUCT.md).

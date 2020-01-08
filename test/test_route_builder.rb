require_relative 'test_helper'

class RouteBuilderTest < Minitest::Test
  attr_reader :route_builder

  def setup
    @route_builder = Rack::Router::RouteBuilder.new
  end

  def test_get
    route_builder.add(:get, '/posts/qwe', 'fail 1', {})
    route_builder.add(:get, '/qwe/posts', 'fail 2', {})
    route_builder.add(:get, '/asd', 'fail 3', {})
    route_builder.add(:get, '/post', 'fail 4', {})
    route_builder.add(:post, '/posts', 'fail 5', {})
    route_builder.add(:get, '/posts', 'success', {})

    env = {
        Rack::REQUEST_METHOD => 'GET',
        Rack::PATH_INFO => '/posts',
        'CONTENT_TYPE' => '',
        'HTTP_ACCEPT' => ''
    }
    route = route_builder.match(env)

    refute_nil route
    assert_equal 'success', route.value
  end

  def test_get_with_ext
    route_builder.add(:get, '/posts/qwe', 'fail 1', {})
    route_builder.add(:get, '/qwe/posts', 'fail 2', {})
    route_builder.add(:get, '/asd', 'fail 3', {})
    route_builder.add(:get, '/post', 'fail 4', {})
    route_builder.add(:get, '/html.posts', 'fail 5', {})
    route_builder.add(:get, '/html', 'fail 6', {})
    route_builder.add(:put, '/posts', 'fail 7', {})
    route_builder.add(:get, '/posts', 'success', {})

    env = {
        Rack::REQUEST_METHOD => 'GET',
        Rack::PATH_INFO => '/posts.html',
        'CONTENT_TYPE' => '',
        'HTTP_ACCEPT' => ''
    }
    route = route_builder.match(env)

    refute_nil route
    assert_equal 'success', route.value
  end

  def test_get_with_param
    route_builder.add(:get, '/posts', 'fail 1', {})
    route_builder.add(:get, '/qwe/posts/:id', 'fail 2', {})
    route_builder.add(:get, '/asd/:id', 'fail 3', {})
    route_builder.add(:get, '/post/:id', 'fail 4', {})
    route_builder.add(:get, '/posts/qwe', 'fail 4', {})
    route_builder.add(:get, '/posts/qwe/:id', 'fail 5', {})
    route_builder.add(:delete, '/posts/:id', 'fail 6', {})
    route_builder.add(:get, '/posts/:id', 'success', {})

    env = {
        Rack::REQUEST_METHOD => 'GET',
        Rack::PATH_INFO => '/posts/123',
        'CONTENT_TYPE' => '',
        'HTTP_ACCEPT' => ''
    }
    route = route_builder.match(env)

    refute_nil route
    assert_equal 'success', route.value
    expected_hash = { id: '123' }
    assert_equal expected_hash, route.path_hash('/posts/123')
  end

  # todo test_get_with_content_type
  # todo test_get_with_accept
  # todo test_get_with_accept_all
  # todo test_get_with_param_constraint
end

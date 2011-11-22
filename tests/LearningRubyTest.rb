require 'test/unit'
require 'net/http'

class LearningRubyTest < Test::Unit::TestCase
  def test_uri
    u = URI('http://example.org/path?query=string')
    u.host = 'example2.org'

    assert_equal('http://example2.org/path?query=string', u.to_s)
  end
end

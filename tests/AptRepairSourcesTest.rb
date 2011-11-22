$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'net/http'
require 'AptRepairSources'
require 'test/unit'

class AptRepairSourcesTest < Test::Unit::TestCase
  def test_type
    l = "deb http://archive.ubuntu.com/ubuntu/ lucid main restricted universe multiverse"

    helper = AptRepairSources.new(l)

    assert_equal("deb", helper.get_type)
  end


  def test_url
    l = "deb http://archive.ubuntu.com/ubuntu/ lucid main restricted universe multiverse"

    helper = AptRepairSources.new(l)

    u  = helper.get_url(nil)
    el = helper.get_el

    el.each do |t|
      c = u + t + helper.get_end
      assert_equal(true, helper.uri_exists(c))
    end

  end

  def test_archive
    l = "deb http://archive.ubuntu.com/ubuntu/ karmic main universe"
    e = "deb http://old-releases.ubuntu.com/ubuntu/ karmic main universe"

    helper = AptRepairSources.new(l)
    assert_equal(e, helper.fix_line)
  end

  def test_multiverse_security
    l = "deb-src http://security.ubuntu.com/ubuntu karmic-security main universe"
    e = "deb-src http://old-releases.ubuntu.com/ubuntu karmic-security main universe"

    helper = AptRepairSources.new(l)
    assert_equal(e, helper.fix_line)
  end
end

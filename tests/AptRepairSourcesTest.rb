$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'net/http'
require 'apt/repair/sources'
require 'test/unit'

class AptRepairSourcesTest < Test::Unit::TestCase
  def test_type
    l = "deb http://archive.ubuntu.com/ubuntu/ lucid main restricted universe multiverse"

    helper = Apt::Repair::Sources.new(l)

    assert_equal("deb", helper.get_type)
  end

  def test_url
    l = "deb http://archive.ubuntu.com/ubuntu/ lucid main restricted universe multiverse"

    helper = Apt::Repair::Sources.new(l)

    u  = helper.get_url(nil)
    el = helper.get_el

    el.each do |t|
      c = u + t + helper.get_end
      assert_equal(true, helper.uri_exists(c))
    end

  end

  # Karmic moved from archive to old-releases.
  def test_archive
    l = "deb http://archive.ubuntu.com/ubuntu/ karmic main universe"
    e = "deb http://old-releases.ubuntu.com/ubuntu/ karmic main universe"

    helper = Apt::Repair::Sources.new(l)
    assert_equal(e, helper.fix_line)
  end

  # Apt::Repair::Sources::get_url - parameter test
  def test_get_url
    l = "deb-src http://security.ubuntu.com/ubuntu karmic-security main universe"

    helper = Apt::Repair::Sources.new(l)
    assert_equal("http://security.ubuntu.com/ubuntu/dists/karmic-security/", helper.get_url(nil))

    assert_equal("http://old-releases.ubuntu.com/ubuntu/dists/karmic-security/", helper.get_url("http://old-releases.ubuntu.com/ubuntu"))
  end

  # Assert that old entries move according to plan.
  def test_multiverse_security
    l = "deb-src http://security.ubuntu.com/ubuntu karmic-security main universe"
    e = "deb-src http://old-releases.ubuntu.com/ubuntu karmic-security main universe"

    helper = Apt::Repair::Sources.new(l)
    assert_equal(e, helper.fix_line)
  end
end

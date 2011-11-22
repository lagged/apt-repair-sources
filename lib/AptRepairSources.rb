#!/usr/bin/env ruby
#
# Author:    Till Klampaeckel
# License:   New BSD License, http://www.opensource.org/licenses/bsd-license.php
# Copyright: 2011 Till Klampaeckel
#

# @author Till Klampaeckel
class AptRepairSources

  # @param [String] line A line from a source.list file.
  # @return [AptRepairSources]
  def initialize(line)
    @l = line
    @e = line.split(" ")
  end

  # @return [String] The architecture: amd64, i686
  def self.find_platform
    return `dpkg --print-architecture`.gsub(/\s+/, "")
  end

  # Each 'line' in a sources.list file contains various elements, this is an array
  # with them. type (deb, deb-src), url and distribution are stripped. 
  # @return [Array]
  def get_el
    el = @l.split(" ")

    el.shift
    el.shift
    el.shift

    return el
  end

  # @return [String] For the URL test!
  def get_end
    if self.get_type == 'deb'
      return "/binary-#{self.class.find_platform}/Packages.gz"
    end
    return "/source/Sources.gz"
  end

  # @return [String] The type: most likely deb or deb-src
  def get_type
    return @e[0]
  end

  # @return [String] Create the base url to test against.
  def get_url(base)
    if base.nil?
      url = @e[1]
    else
      url = base
    end
    url = @e[1]
    if url[-1,1] != "/"
      url += "/"
    end
    url += "dists/" + @e[2] + "/"
    return url
  end

  # Tries to fix a line from a sources.list file by correcting the URL or commenting
  # it out. When the URL is corrected, we attempt to test if the new URL exists. The
  # the failover is always to comment it out.
  # @return [String]
  def fix_line
    el = @l.split(" ")

    u = URI(el[1])

    disable = false

    case u.host
    when "releases.ubuntu.com"
      c      = u.host
      u.host = "archive.ubuntu.com"
      if self.uri_exists(self.get_url(u.to_s)) == false
        u.host = c
      end
    when "archive.ubuntu.com", "security.ubuntu.com"
      c      = u.host
      u.host = "old-releases.ubuntu.com"
      if self.uri_exists(self.get_url(u.to_s)) == false
        u.host = c
      end
    when "old-releases.ubuntu.com"
      raise Exception, "You're fucked."
    else
      # this is tricky, e.g. is the mirror down or did it move?
      c = u.host

      if c =~ /(.*)\.releases\.ubuntu\.com/
        u.host = "archive.ubuntu.com"
      elsif c =~ /(.*)\.archive\.ubuntu\.com/
        u.host = "old-releases.ubuntu.com"
      else
        disable = true
      end

      if disable == false
        if self.uri_exists(u.to_s) == false
          u.host = c
        end
      end

    end

    el[1] = u.to_s
    line  = el.join(" ")

    if disable == true
      line = '#' + line
    end

    return line
  end

  # Check if a URL exists by issueing a HEAD request.
  # @param [String] URL
  # @return [Boolean]
  def uri_exists(url)

    u = URI(url)

    Net::HTTP.start(u.host, u.port) do |http|
      http.open_timeout = 1
      http.read_timeout = 1
      res = http.head(u.path)

      if res.code == "200"
        return true
      end
      return false
    end
  end

end

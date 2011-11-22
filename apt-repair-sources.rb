#!/usr/bin/env ruby
#
# Author:    Till Klampaeckel
# License:   New BSD License, http://www.opensource.org/licenses/bsd-license.php
# Setup:     gem install trollop
# Copyright: 2011 Till Klampaeckel
#

work = []

if File.exist?("/etc/apt/sources.list") 
  work.push("/etc/apt/sources.list")
end

if File.directory?("/etc/apt/sources.list.d")
  work += Dir["/etc/apt/sources.list.d/*.list"]
end

if work.length == 0
  puts "Nothing to be done."
  exit
end

require 'rubygems'
require 'trollop'
require 'net/http'

opts = Trollop::options do
  version "apt-repair-sources 0.1.0 (c) 2011 Till Klampaeckel"
  banner <<-EOS
This tool helps you clean out bad entries from apt's sources.

Usage:

    sudo apt-repair-sources --dry-run|--fix-it-for-me
EOS
  opt :dry_run, "Display bad entries, this is enabled by default (no changes)", :default => false
  opt :fix_it_for_me, "Remove bad entries from the sources (changes will be made)", :default => false
end

if opts[:dry_run] == true && opts[:fix_it_for_me] == true
  puts "Cannot have both."
  exit 1
else
  if opts[:fix_it_for_me_given] && opts[:fix_it_for_me] == true
    dry_run = false
  else
    dry_run = true
  end
end

class AptRepairSources

  def initialize(line)
    @e = line.split(" ")
  end

  def self.find_platform
    return `dpkg --print-architecture`.gsub(/\s+/, "")
  end

  def get_el

    el = @e

    el.shift
    el.shift
    el.shift

    return el
  end

  def get_type
    return @e[0]
  end

  def get_url
    url = @e[1]
    if url[-1,1] != "/"
      url += "/"
    end
    url += "dists/" + @e[2] + "/"
    return url
  end

  def fix_line
    el = @e

    u = URI(el[1])

    disable = false

    case u.host
    when "archive.ubuntu.com"
      u.host = "old-releases.ubuntu.com"
    when "old-releases.ubuntu.com"
      raise Exception, "You're fucked."
    else
      # this is tricky, e.g. is the mirror down or did it move?
      if u.host[-11,11] == '.ubuntu.com'
        c      = u.host
        u.host = "archive.ubuntu.com"

        if self.uri_exists(u.to_s) == false
          u.host = c
        end

      else
        disable = true
      end
    end

    el[1] = u.to_s
    line  = el.join(" ")

    if disable == true
      line = '#' + line
    end

    return line
  end

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

p = AptRepairSources::find_platform

work.each do |f| 
  File.open(f, "r") do |infile|
    keep = []
    err  = 0
    while (l = infile.gets) 

      if l.nil? || l.empty? 
        next
      end

      unless l[0,3] == 'deb' || l[0,7] == 'deb-src'
        next
      end

      helper = AptRepairSources.new(l)
      type   = helper.get_type
      url    = helper.get_url
      el     = helper.get_el

      has_error = false

      el.each do |t|

        uri = url + t
        if type == 'deb'
          uri += "/binary-#{p}/Packages.gz"
        else
          uri += "/source/Sources.gz"
        end

        if helper.uri_exists(uri) == true
          next
        end

        has_error = true

        err += 1

        if dry_run == true
          puts "#{f}: #{uri}"
        end

      end

      if has_error == true
        keep.push(helper.fix_line)
      else
        keep.push(l)
      end

    end

    # save to be safe
    if dry_run == false && err > 0
      File.open(f, 'w') do |f|
        f.write(keep.join("\n"))
      end
    end

  end
end

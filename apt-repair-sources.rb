#!/usr/bin/env ruby

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

require 'net/http'

def find_platform
  return `dpkg --print-architecture`.gsub(/\s+/, "")
end

dry_run = true

p = find_platform

work.each do |f| 
  File.open(f, "r") do |infile|
    keep = []
    while (l = infile.gets) 

      if l.empty? 
        next
      end

      unless l[0,3] == 'deb' || l[0,7] == 'deb-src'
        next
      end

      el = l.split(" ")

      type = el[0]

      url = el[1]
      if url[-1,1] != "/"
        url += "/"
      end
      url += "dists/" + el[2] + "/"

      el.shift
      el.shift
      el.shift

      #puts el
      #next

      el.each do |t|

        uri = url + t
        if type == 'deb'
          uri += "/binary-#{p}/Packages.gz"
        else
          uri += "/source/Sources.gz"
        end

        u = URI(uri)

        Net::HTTP.start(u.host, u.port) do |http|
          http.open_timeout = 1
          http.read_timeout = 1
          res = http.head(u.path)

          if res.code == "200"
            keep.push(l)
            next
          end

          if dry_run == true
            puts "#{f}: #{uri} >> #{res.code}"
          end

          keep.push("#" + "#{l}");

        end

      end
    end

    # save to be safe
    if dry_run != true
      puts f
      puts keep
    end

  end
end

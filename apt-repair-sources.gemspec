
# -*- encoding: utf-8 -*-
$:.push('lib')
require "apt/repair/sources/version"

Gem::Specification.new do |s|
  s.name     = "apt-repair-sources"
  s.version  = Apt::Repair::Sources::VERSION.dup
  s.date     = "2011-11-23"
  s.summary  = "TODO: Summary of project"
  s.email    = "till@php.net"
  s.homepage = "github.com/lagged/apt-repair-sources"
  s.authors  = ['Till Klampaeckel']
  
  s.description = <<-EOF
A tool to clean up your sources.list
EOF
  
  dependencies = [
    [:runtime,     "trollop",  "~> 1.16.2"],
    [:development, "test-unit", "~> 2.4.1"],
  ]
  
  s.files         = Dir['**/*']
  s.test_files    = Dir['test/**/*'] + Dir['spec/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.3.6"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
  
  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end

source 'https://rubygems.org'

gem 'bootsnap', require: false

gem 'rake', '~> 10.0'
gem 'pry'
gem 'debug'

group :spec do
    gem 'rspec', '~> 3.0'
end

group :prof do

    if File.exist? '../monitor'
        gem 'scnr-monitor', path: '../monitor'
    end

    gem 'stackprof'
    gem 'ruby-prof'
    gem 'benchmark-ips'
    gem 'memory_profiler'
end

gem 'nokogiri', github: 'sparklemotion/nokogiri'
gem 'ethon',    github: 'typhoeus/ethon', branch: 'thread-safe-easy-handle-cleanup'

if File.exist? '../../../qadron/dsel'
    gem 'dsel', path: '../../../qadron/dsel'
end

if File.exist? '../../../qadron/cuboid'
    gem 'cuboid', path: '../../../qadron/cuboid'
end

if File.exist? '../application'
    gem 'scnr-application', path: '../application'
end

if File.exist? '../engine'
    gem 'scnr-engine', path: '../engine'
end

gemspec

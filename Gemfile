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

gem 'cuboid',   github: 'qadron/cuboid'
gem 'dsel',     github: 'qadron/dsel'

if File.exist? '../engine'
    gem 'scnr-engine', path: '../engine'
end

gemspec

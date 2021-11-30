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
gem 'ethon',      path: '../../../ethon'

gem 'scnr-engine', path: '../engine'
gem 'cuboid',      path: '../../../qadron/cuboid'
gem 'dsel',      path: '../../../qadron/dsel'

# gem 'ethon',       github: 'typhoeus/ethon', branch: 'thread-safe-easy-handle-cleanup'
# gem 'typhoeus',    github: 'typhoeus/typhoeus'

gemspec

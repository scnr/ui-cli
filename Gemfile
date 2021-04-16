source 'https://rubygems.org'

gem 'bootsnap', require: false

gem 'rake', '~> 10.0'
gem 'pry'

group :spec do
    gem 'rspec', '~> 3.0'
end

group :prof do

    # if File.exist? '../monitor'
    #     gem 'scnr-monitor', path: '../monitor'
    # end

    gem 'benchmark-ips'
    gem 'memory_profiler'
end

gem 'scnr-engine', path: '../engine'
# gem 'ethon',       github: 'typhoeus/ethon', branch: 'thread-safe-easy-handle-cleanup'
# gem 'typhoeus',    github: 'typhoeus/typhoeus'

gemspec

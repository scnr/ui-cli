source 'https://rubygems.org'

gem 'rake', '~> 10.0'
gem 'pry'

group :spec do
    gem 'rspec', '~> 3.0'
end

group :prof do

    if File.exist? '../monitor'
        gem 'scnr-monitor', path: '../monitor'
    end

    gem 'benchmark-ips'
    gem 'memory_profiler'
end

gem 'scnr-engine', path: '../engine'
gem 'ethon',       github: 'typhoeus/ethon'
gem 'typhoeus',    github: 'typhoeus/typhoeus'

gemspec

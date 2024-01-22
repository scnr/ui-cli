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

if File.exist? '../introspector'
    gem 'scnr-introspector', path: '../introspector'
end

if File.exist? '../application'
    gem 'scnr-application', path: '../application'
end

if File.exist? '../scnr'
    gem 'scnr', path: '../scnr'
end

if File.exist? '../engine'
    gem 'scnr-engine', path: '../engine'
end

gemspec

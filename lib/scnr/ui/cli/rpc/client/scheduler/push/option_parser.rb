=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../../remote/option_parser'

module SCNR
module UI::CLI

module RPC
module Client
module Scheduler
class Push

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < Remote::OptionParser

    attr_reader :priority

    def scheduler
        separator 'Scheduler'

        on( '--scheduler-url HOST:PORT', 'Scheduler to use.' ) do |url|
            Cuboid::Options.scheduler.url = url
        end

        on( '--scheduler-priority PRIORITY', Integer,
            'Scan priority, higher is better.',
            '(Default: 0)'
        ) do |priority|
            @priority = priority
        end
    end

    def validate
        if !Cuboid::Options.scheduler.url
            print_error "Missing '--scheduler-url'."
            exit 1
        end

        begin
            SCNR::Engine::RPC::Client::Scheduler.new(
                Cuboid::Options.scheduler.url
            ).alive?
        rescue => e
            print_error "Could not reach Scheduler at: #{Cuboid::Options.scheduler.url}"
            print_error "#{e.class}: #{e.to_s}"
            exit 1
        end

        super
    end

end

end
end
end
end
end
end

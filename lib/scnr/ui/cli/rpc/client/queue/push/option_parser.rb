=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine/rpc/client'

require_relative '../../remote/option_parser'

module SCNR
module UI::CLI

module RPC
module Client
module Queue
class Push

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < Remote::OptionParser

    attr_reader :priority

    def queue
        separator 'Queue'

        on( '--queue-url HOST:PORT', 'Queue to use.' ) do |url|
            options.queue.url = url
        end

        on( '--queue-priority PRIORITY', Integer,
            'Scan priority, higher is better.',
            '(Default: 0)'
        ) do |priority|
            @priority = priority
        end
    end

    def validate
        if !options.queue.url
            print_error "Missing '--queue-url'."
            exit 1
        end

        begin
            SCNR::Engine::RPC::Client::Queue.new(
                options.queue.url
            ).alive?
        rescue => e
            print_error "Could not reach Queue at: #{options.queue.url}"
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

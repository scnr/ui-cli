=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'clear/option_parser'

module SCNR

require 'scnr/engine/rpc/client/queue'
require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Queue

class Clear
    include Output

    def initialize
        parser = Clear::OptionParser.new
        parser.parse

        options = parser.options

        begin
            SCNR::Engine::RPC::Client::Queue.new( options.queue.url ).clear

            print_ok 'Queue cleared.'
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not clear Queue at '#{options.queue.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end
    end

end

end
end
end
end

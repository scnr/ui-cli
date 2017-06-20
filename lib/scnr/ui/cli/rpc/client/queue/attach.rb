=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'attach/option_parser'

module SCNR

require 'scnr/engine/rpc/client/queue'
require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Queue

class Attach
    include Output

    def initialize
        parser = Attach::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @queue = SCNR::Engine::RPC::Client::Queue.new( options.queue.url )

            if @queue.attach( parser.url, parser.token )
                print_ok "Attached '#{parser.url}/#{parser.token}' to '#{options.queue.url}'."
            else
                print_bad "Could not attach '#{parser.url}/#{parser.token}' to " <<
                              "'#{options.queue.url}' because it is inaccessible from the Queue host."
            end
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not attach to Queue at '#{options.queue.url}'."
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

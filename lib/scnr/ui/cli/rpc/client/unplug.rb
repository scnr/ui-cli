=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'unplug/option_parser'

module SCNR

require 'scnr/engine/rpc/client/dispatcher'

module UI::CLI
module RPC::Client

class Unplug
    include Output
    include Utilities

    def initialize
        parser = Unplug::OptionParser.new
        parser.ssl
        parser.parse

        options = parser.options

        begin
            @dispatcher = SCNR::Engine::RPC::Client::Dispatcher.new( options.dispatcher.url )
            @dispatcher.node.unplug

            print_ok "Unplugged #{options.dispatcher.url}."
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Dispatcher at '#{options.url}'."
            print_error "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

    end

end

end
end
end

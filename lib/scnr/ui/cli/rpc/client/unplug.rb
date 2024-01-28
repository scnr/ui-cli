=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'unplug/option_parser'

module SCNR

module UI::CLI
module RPC::Client

class Unplug
    include Output
    include Utilities

    def initialize
        begin
            SCNR::License.guard! :dev, :trial, :enterprise
        rescue SCNR::License::Error => e
            puts "[ERROR] #{e}"
            exit 1
        end

        parser = Unplug::OptionParser.new
        parser.ssl
        parser.parse

        options = parser.options

        begin
            @agent = SCNR::Engine::RPC::Client::Agent.new( Cuboid::Options.agent.url )
            @agent.node.unplug

            print_ok "Unplugged #{Cuboid::Options.agent.url}."
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Agent at '#{options.url}'."
            print_error "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

    end

end

end
end
end

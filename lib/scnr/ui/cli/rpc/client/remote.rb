=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'remote/option_parser'
require_relative 'instance'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client

# Provides a command-line RPC client and uses a {RPC::Server::Dispatcher} to
# provide an {RPC::Server::Instance} in order to perform a scan.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Remote
    include Output

    def initialize
        parser = Remote::OptionParser.new
        parser.authorized_by
        parser.scope
        parser.audit
        parser.input
        parser.http
        parser.checks
        parser.plugins
        parser.platforms
        parser.session
        parser.profiles
        parser.dom
        parser.device
        parser.grid
        parser.ssl
        parser.report
        parser.timeout
        parser.parse

        options = parser.options

        begin
            dispatcher = SCNR::Engine::RPC::Client::Dispatcher.new(
              Cuboid::Options.dispatcher.url
            )

            # Get a new instance and assign the url we're going to audit as the 'owner'.
            instance_info = dispatcher.dispatch( owner: options.url )

            if !instance_info
                print_info 'Dispatcher is at maximum utilization, please try again later.'
                exit 2
            end

        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Dispatcher at '#{Cuboid::Options.dispatcher.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        instance = nil
        begin
            instance = SCNR::Engine::RPC::Client::Instance.new(
                instance_info['url'],
                instance_info['token']
            )
            instance.alive?
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error 'Could not connect to Instance.'
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        # Let the Instance UI manage the Instance from now on.
        Instance.new( instance ).run
    end

end

end
end
end

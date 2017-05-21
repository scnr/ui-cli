=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'remote/option_parser'
require_relative 'instance'

module SCNR

require 'scnr/engine/rpc/client/dispatcher'
require 'scnr/engine/rpc/client/instance'
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
        parser.browser_cluster
        parser.grid
        parser.ssl
        parser.report
        parser.timeout
        parser.parse

        options = parser.options

        Arachni::Reactor.global.run_in_thread

        begin
            dispatcher = SCNR::Engine::RPC::Client::Dispatcher.new( options, options.dispatcher.url )

            # Get a new instance and assign the url we're going to audit as the 'owner'.
            instance_info = dispatcher.dispatch( options.url )

            if !instance_info
                print_info 'Dispatcher is at maximum utilization, please try again later.'
                exit 2
            end

        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Dispatcher at '#{options.dispatcher.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        instance = nil
        begin
            instance = SCNR::Engine::RPC::Client::Instance.new( options,
                                                            instance_info['url'],
                                                            instance_info['token'] )
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error 'Could not connect to Instance.'
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        # Let the Instance UI manage the Instance from now on.
        Instance.new( SCNR::Engine::Options.instance, instance, parser.get_timeout ).run
    end

end

end
end
end

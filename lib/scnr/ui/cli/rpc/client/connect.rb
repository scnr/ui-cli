=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'connect/option_parser'
require_relative 'instance'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Connect
    include Output

    def initialize
        SCNR::License.guard! :dev, :trial, :enterprise

        parser = Connect::OptionParser.new
        parser.ssl
        parser.parse

        instance = nil
        begin
            instance = SCNR::Engine::RPC::Client::Instance.new(
                parser.url,
                parser.token
            )
            instance.alive?
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error 'Could not connect to Instance.'
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        # Let the Instance UI manage the Instance from now on.
        Instance.new( instance, parser ).run
    end

end

end
end
end

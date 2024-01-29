=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'detach/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class Detach
    include Output

    def initialize
        begin
            SCNR::License.guard! :dev, :trial, :enterprise
        rescue SCNR::License::Error => e
            puts "[ERROR] #{e}"
            exit 1
        end

        parser = Detach::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            if info = @scheduler.detach( parser.id )
                print_ok "Detached '#{info['url']}/#{info['token']}' from " <<
                             "'#{Cuboid::Options.scheduler.url}'."
            else
                print_bad "Could not find '#{parser.id}' in '#{Cuboid::Options.scheduler.url}'."
            end
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not detach from Scheduler at '#{Cuboid::Options.scheduler.url}'."
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

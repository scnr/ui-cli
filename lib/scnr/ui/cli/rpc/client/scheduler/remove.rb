=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'remove/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class Remove
    include Output

    def initialize
        begin
            SCNR::License.guard! :dev, :trial, :enterprise
        rescue SCNR::License::Error => e
            puts "[ERROR] #{e}"
            exit 1
        end

        parser = Remove::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            parser.ids.each do |id|
                if @scheduler.remove( id )
                    print_ok "Removed: #{id}"
                else
                    print_bad "Scan not in scheduler: #{id}"
                end
            end

        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not remove from Scheduler at '#{Cuboid::Options.scheduler.url}'."
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

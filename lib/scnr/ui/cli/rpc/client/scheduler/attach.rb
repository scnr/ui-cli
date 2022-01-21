=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'attach/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class Attach
    include Output

    def initialize
        parser = Attach::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            id = @scheduler.attach( parser.url, parser.token )

            if id
                print_ok "Attached '#{parser.url}/#{parser.token}' to " <<
                             "'#{Cuboid::Options.scheduler.url}' as '#{id}'."
            elsif id == false
                print_bad "'#{parser.url}/#{parser.token}' is already attached to a Scheduler."
            else
                print_bad "Could not attach '#{parser.url}/#{parser.token}' to " <<
                              "'#{Cuboid::Options.scheduler.url}' because it is inaccessible from the Scheduler host."
            end
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not attach to Scheduler at '#{Cuboid::Options.scheduler.url}'."
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

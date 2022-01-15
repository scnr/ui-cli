=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'get/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class Get
    include Output

    def initialize
        parser = Get::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            parser.ids.each do |id|
                print_scan( id, @scheduler.get( id ) )
                print_line
            end

        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not get from Scheduler at '#{Cuboid::Options.scheduler.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end
    end

    def print_scan( id, info )
        if !info
            print_bad "#{id}: Scan could not be found in scheduler, it could have been popped."
            return
        end

        priority = info.delete( 'priority' )
        options  = info.delete( 'options' )

        print_status "#{id}: Priority: #{priority}"
        puts SCNR::Engine::Options.dup.reset.update( options ).to_save_data_without_defaults
    end

end

end
end
end
end

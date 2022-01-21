=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'terminal-table/import'
require_relative 'dispatcher_monitor/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client

# Provides an simplistic Dispatcher monitoring user interface.
#
# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class DispatcherMonitor
    include Output
    include Utilities

    def initialize
        parser = DispatcherMonitor::OptionParser.new
        parser.ssl
        parser.parse

        options = parser.options

        clear_screen
        move_to_home

        begin
            # start the RPC client
            @dispatcher = SCNR::Engine::RPC::Client::Dispatcher.new( Cuboid::Options.dispatcher.url )
            @dispatcher.alive?
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Dispatcher at '#{Cuboid::Options.url}'."
            print_error "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

        trap( 'HUP' ) { exit }
        trap( 'INT' ) { exit }

        run
    end

    private

    def run
        print_line

        loop do
            empty_screen
            move_to_home

            stats = @dispatcher.statistics
            running_instances = stats['running_instances']

            print_banner
            print_stats( stats )

            print_line

            print_instance_table( running_instances )

            sleep 1
        end

    end

    def print_instance_table( instances )
        headings = [ 'PID', 'URL', 'Owner', 'Birthdate (Server-side)',
            'Current time (Server-side)', 'Age']

        rows = []
        instances.each do |instance|
            rows << [
                instance['pid'], "#{instance['url']}/#{instance['token']}", instance['owner'],
                instance['birthdate'], instance['now'],
                seconds_to_hms( instance['age'] )
            ]
        end

        return if rows.empty?

        print_line table( headings, *rows )
    end

    def print_stats( stats )
        print_info "Utilization:        #{(stats['utilization'] * 100).round(1)}%"
        print_info "Running instances:  #{stats['running_instances'].size}"
        print_info "Finished instances: #{stats['finished_instances'].size}"

        print_line

        if stats['node']['neighbours'].any?
            print_info 'Neighbours:'
            stats['node']['neighbours'].each do |neighbour|
                print_info "* #{neighbour}"
            end
        end

        if stats['node']['unreachable_neighbours'].any?
            print_info 'Unreachable neighbours:'
            stats['node']['unreachable_neighbours'].each do |neighbour|
                print_info "* #{neighbour}"
            end
        end
    end

    def proc_mem( rss )
        # we assume a page size of 4096
        (rss.to_i * 4096 / 1024 / 1024).to_s + 'MB'
    end

    def proc_state( state )
        case state
            when 'S'; 'Sleeping'

            when 'D'; 'Disk Sleep'

            when 'Z'; 'Zombie'

            when 'T'; 'Traced/Stoped'

            when 'W'; 'Paging'
        end
    end

    def seconds_to_hms( secs )
        secs = secs.to_i
        [secs/3600, secs/60 % 60, secs % 60].map { |t| t.to_s.rjust( 2, '0' ) }.join(':')
    end

end

end
end
end

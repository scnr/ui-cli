=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'terminal-table/import'
require_relative 'agent_monitor/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client

# Provides an simplistic Agent monitoring user interface.
#
# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class AgentMonitor
    include Output
    include Utilities

    def initialize
        begin
            SCNR::License.guard! :dev, :trial, :enterprise
        rescue SCNR::License::Error => e
            puts "[ERROR] #{e}"
            exit 1
        end

        parser = AgentMonitor::OptionParser.new
        parser.ssl
        parser.parse

        options = parser.options

        clear_screen
        move_to_home

        begin
            # start the RPC client
            @agent = SCNR::Engine::RPC::Client::Agent.new( Cuboid::Options.agent.url )
            @agent.alive?
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not connect to Agent at '#{Cuboid::Options.url}'."
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

            stats = @agent.statistics
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

        if stats['node']['peers'].any?
            print_info 'Neighbours:'
            stats['node']['peers'].each do |peer|
                print_info "* #{peer}"
            end
        end

        if stats['node']['unreachable_peers'].any?
            print_info 'Unreachable peers:'
            stats['node']['unreachable_peers'].each do |peer|
                print_info "* #{peer}"
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

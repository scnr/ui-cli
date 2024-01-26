=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'list/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class List
    include Output

    def initialize
        parser = List::OptionParser.new
        parser.parse

        begin
            @scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            if parser.queued || parser.list_all?
                queued
            end

            if parser.running || parser.list_all?
                print_line
                running
            end

            if parser.completed || parser.list_all?
                print_line
                completed
            end

            if parser.failed || parser.list_all?
                print_line
                failed
            end

            print_line
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not list from Scheduler at '#{Cuboid::Options.scheduler.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end
    end

    def queued
        q = @scheduler.list

        print_info "Queued [#{q.values.flatten.size}]"
        print_line

        q.each do |priority, ids|
            print_line "Priority: #{priority} [#{ids.size}]"
            print_line

            ids.each.with_index do |id, i|
                print_line "[#{i+1}] #{id}"
            end

            print_line
        end
    end

    def running
        r = @scheduler.running

        print_status "Running [#{r.size}]"
        print_line

        r.each.with_index do |(id, info), i|
            print_line "[#{i+1}] #{id}: #{info['url']}/#{info['token']}"
        end
    end

    def completed
        c = @scheduler.completed

        print_ok "Completed [#{c.size}]"
        print_line

        c.each.with_index do |(id, report), i|
            print_line "[#{i+1}] #{id}: #{report}"
        end
    end

    def failed
        f = @scheduler.failed

        print_bad "Failed [#{f.size}]"
        print_line

        f.each.with_index do |(id, info), i|
            print_line "[#{i+1}] #{id}: [#{info['error']}] #{info['description']}"
        end
    end

end

end
end
end
end

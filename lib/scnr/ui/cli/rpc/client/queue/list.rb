=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'list/option_parser'

module SCNR

require 'scnr/engine/rpc/client/queue'
require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Queue

class List
    include Output

    def initialize
        parser = List::OptionParser.new
        parser.parse

        options = parser.options

        begin
            @queue = SCNR::Engine::RPC::Client::Queue.new( options.queue.url )

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
            print_error "Could not list from Queue at '#{options.queue.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end
    end

    def queued
        q = @queue.list

        print_info "Queued [#{q.values.flatten.size}]"
        print_line

        q.each do |priority, ids|
            print_line "Priority: #{priority} [#{ids.size}]"
            print_line

            ids.each do |id|
                print_line "* #{id}"
            end

            print_line
        end
    end

    def running
        r = @queue.running

        print_status "Running [#{r.size}]"
        print_line

        r.each do |id, info|
            print_line "#{id}: #{info['url']}/#{info['token']}"
        end
    end

    def completed
        c = @queue.completed

        print_ok "Completed [#{c.size}]"
        print_line

        c.each do |id, report|
            print_line "#{id}: #{report}"
        end
    end

    def failed
        f = @queue.failed

        print_bad "Failed [#{f.size}]"
        print_line

        f.each do |id, info|
            print_line "#{id}: [#{info['error']}] #{info['description']}"
        end
    end

end

end
end
end
end

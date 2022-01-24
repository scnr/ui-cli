=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../../remote/option_parser'

module SCNR
module UI::CLI

module RPC
module Client
module Scheduler
class Get

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

    attr_reader :ids

    def initialize
        super

        @ids = []
    end

    def ssl
        separator ''
        separator 'SSL'

        on( '--ssl-ca FILE',
            'Location of the CA certificate (.pem).'
        ) do |file|
            options.rpc.ssl_ca = file
        end

        on( '--ssl-private-key FILE',
            'Location of the client SSL private key (.pem).'
        ) do |file|
            options.rpc.client_ssl_private_key = file
        end

        on( '--ssl-certificate FILE',
            'Location of the client SSL certificate (.pem).'
        ) do |file|
            options.rpc.client_ssl_certificate = file
        end
    end

    def after_parse
        Cuboid::Options.scheduler.url = ARGV.shift
        @ids              = ARGV.dup.uniq
    end

    def validate
        if !Cuboid::Options.scheduler.url
            print_error "Missing 'scheduler_URL'."
            exit 1
        end

        if @ids.empty?
            print_error 'Missing scan IDs.'
            exit 1
        end

        begin
            SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url ).alive?
        rescue => e
            print_error "Could not reach Scheduler at: #{Cuboid::Options.scheduler.url}"
            print_error "#{e.class}: #{e.to_s}"
            exit 1
        end

        super
    end

    def banner
        "Usage: #{$0} [options] SCHEDULER_URL SCAN_ID1 SCAN_ID2 .."
    end

end

end
end
end
end
end
end

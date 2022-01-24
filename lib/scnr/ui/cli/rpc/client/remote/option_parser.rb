=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../../../engine/option_parser'

module SCNR
module UI::CLI

module RPC
module Client
class Remote

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::Engine::OptionParser

    def grid
        separator 'Grid'

        on( '--dispatcher-url HOST:PORT', 'Dispatcher to use.' ) do |url|
            Cuboid::Options.dispatcher.url = url
        end

        on( '--dispatcher-strategy STRATEGY', 'Default distribution strategy.',
            "(Available: #{Cuboid::OptionGroups::Dispatcher::STRATEGIES.join( ', ')})",
            "(Default: #{Cuboid::Options.dispatcher.strategy})"
        ) do |strategy|
            Cuboid::Options.dispatcher.strategy = strategy
        end
    end

    def ssl
        separator ''
        separator 'SSL'

        on( '--ssl-ca FILE',
            'Location of the CA certificate (.pem).'
        ) do |file|
            Cuboid::Options.rpc.ssl_ca = file
        end

        on( '--ssl-private-key FILE',
            'Location of the client SSL private key (.pem).'
        ) do |file|
            Cuboid::Options.rpc.client_ssl_private_key = file
        end

        on( '--ssl-certificate FILE',
            'Location of the client SSL certificate (.pem).'
        ) do |file|
            Cuboid::Options.rpc.client_ssl_certificate = file
        end
    end

    def validate
        if Cuboid::Options.dispatcher.url
            begin
                SCNR::Engine::RPC::Client::Dispatcher.new(
                  Cuboid::Options.dispatcher.url
                ).alive?
            rescue => e
                print_error "Could not reach Dispatcher at: #{Cuboid::Options.dispatcher.url}"
                print_error "#{e.class}: #{e.to_s}"
                exit 1
            end
        end

        super
    end

    def banner
        "Usage: #{$0} [options] --dispatcher-url=HOST:PORT URL"
    end

end

end
end
end
end
end

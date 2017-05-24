=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine/rpc/client'

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
            options.dispatcher.url = url
        end
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

    def validate
        if SCNR::Engine::Options.dispatcher.url
            begin
                SCNR::Engine::RPC::Client::Dispatcher.new(
                    SCNR::Engine::Options.dispatcher.url
                ).alive?
            rescue => e
                print_error "Could not reach Dispatcher at: #{SCNR::Engine::Options.dispatcher.url}"
                print_error "#{e.class}: #{e.to_s}"
                exit 1
            end
        end

        super
    end

    def banner
        "Usage: #{$0} [options] --dispatcher-url HOST:PORT URL"
    end

end

end
end
end
end
end

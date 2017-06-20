=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../remote/option_parser'

module SCNR
module UI::CLI
module RPC
module Client
class Unplug

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

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
        options.dispatcher.url = ARGV.shift
    end

    def validate
        if !options.dispatcher.url
            print_error "Missing 'DISPATCHER_URL'."
            exit 1
        end

        begin
            SCNR::Engine::RPC::Client::Dispatcher.new(
                options.dispatcher.url
            ).alive?
        rescue => e
            print_error "Could not reach Dispatcher at: #{options.dispatcher.url}"
            print_error "#{e.class}: #{e.to_s}"
            exit 1
        end

        super
    end

    def banner
        "Usage: #{$0} DISPATCHER_URL"
    end

end
end
end
end
end
end

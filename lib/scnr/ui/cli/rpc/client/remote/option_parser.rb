=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

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

    def distribution
        separator 'Distribution'

        on( '--dispatcher-url HOST:PORT', 'Dispatcher server to use.' ) do |url|
            options.dispatcher.url = url
        end

        on( '--grid', "Shorthand for '--grid-mode=balance'." ) do
            options.dispatcher.grid = true
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
        validate_dispatcher
        super
    end

    def validate_dispatcher
        # Check for missing Dispatcher
        if !options.dispatcher.url
            print_error "Missing '--dispatcher-url' option."
            exit 1
        end
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

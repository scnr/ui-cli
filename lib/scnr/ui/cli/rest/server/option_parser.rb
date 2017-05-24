=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../../output'
require_relative '../../option_parser'

module SCNR
module UI::CLI
module Rest
class Server

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

    attr_reader :cli
    attr_reader :username
    attr_reader :password

    def initialize
        super

        separator 'Server'

        on( '--address ADDRESS', 'Hostname or IP address to bind to.',
            "(Default: #{options.rpc.server_address})"
        ) do |address|
            options.rpc.server_address = address
        end

        on( '--port NUMBER', 'Port to listen to.', Integer,
            "(Default: #{options.rpc.server_port})"
        ) do |port|
            options.rpc.server_port = port
        end

        separator ''
        separator 'Grid'

        on( '--dispatcher-url HOST:PORT', 'Dispatcher to use.' ) do |url|
            options.dispatcher.url = url
        end

        separator ''
        separator 'Queue'

        on( '--queue-url HOST:PORT', 'Queue to use.' ) do |url|
            options.queue.url = url
        end

        separator ''
        separator 'Output'

        on( '--output-reroute-to-logfile',
            "Reroute scan output to log-files under: #{options.paths.logs}"
        ) do
            options.output.reroute_to_logfile = true
        end

        on( '--output-verbose', 'Show verbose output.',
            "(Only applicable when '--reroute-to-logfile' is enabled.)"
        ) do
            verbose_on
        end

        on( '--output-debug [LEVEL 1-5]', Integer, 'Show debugging information.',
            "(Only applicable when '--reroute-to-logfile' is enabled.)"
        ) do |level|
            debug_on( level || 1 )
        end

        on( '--output-only-positives', 'Only output positive results.',
            "(Only applicable when '--reroute-to-logfile' is enabled.)"
        ) do
            only_positives
        end

        separator ''
        separator 'Authentication'

        on( '--authentication-username USERNAME',
            'Username to use for HTTP authentication.'
        ) do |username|
            @username = username
        end

        on( '--authentication-password PASSWORD',
            'Password to use for HTTP authentication.'
        ) do |password|
            @password = password
        end

        # Puma SSL doesn't seem to be working on MS Windows.
        if !SCNR::Engine.windows?
            separator ''
            separator 'SSL'

            on( '--ssl-ca FILE',
                'Location of the CA certificate (.pem).',
                'If provided, peer verification will be enabled, otherwise no' +
                    ' verification will take place.'
            ) do |file|
                options.rpc.ssl_ca = file
            end

            on( '--server-ssl-private-key FILE',
                'Location of the SSL private key (.pem).'
            ) do |file|
                options.rpc.server_ssl_private_key = file
            end

            on( '--server-ssl-certificate FILE',
                'Location of the SSL certificate (.pem).'
            ) do |file|
                options.rpc.server_ssl_certificate = file
            end

            on( '--client-ssl-private-key FILE',
                'Location of the client SSL private key (.pem).'
            ) do |file|
                options.rpc.client_ssl_private_key = file
            end

            on( '--client-ssl-certificate FILE',
                'Location of the client SSL certificate (.pem).'
            ) do |file|
                options.rpc.client_ssl_certificate = file
            end
        end

        separator ''
        separator 'System'

        on( '--system-max-slots SLOTS', Integer,
            'Maximum amount of Instances to be alive at any given time.',
            'Only applicable when no Dispatcher has been provided.',
            '(Default: auto)'
        ) do |max_slots|
            options.system.max_slots = max_slots
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

        if SCNR::Engine::Options.queue.url
            begin
                SCNR::Engine::RPC::Client::Queue.new(
                    SCNR::Engine::Options.queue.url
                ).alive?
            rescue => e
                print_error "Could not reach Queue at: #{SCNR::Engine::Options.queue.url}"
                print_error "#{e.class}: #{e.to_s}"
                exit 1
            end
        end

        super
    end

end

end
end
end
end

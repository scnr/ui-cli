=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

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
            "(Default: #{Cuboid::Options.rpc.server_address})"
        ) do |address|
            Cuboid::Options.rpc.server_address = address
        end

        on( '--port NUMBER', 'Port to listen to.', Integer,
            "(Default: #{Cuboid::Options.rpc.server_port})"
        ) do |port|
            Cuboid::Options.rpc.server_port = port
        end

        separator ''
        separator 'Grid'

        on( '--agent-url HOST:PORT', 'Agent to use.' ) do |url|
            Cuboid::Options.agent.url = url
        end

        separator ''
        separator 'Scheduler'

        on( '--scheduler-url HOST:PORT', 'Scheduler to use.' ) do |url|
            Cuboid::Options.scheduler.url = url
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
                Cuboid::Options.rpc.ssl_ca = file
            end

            on( '--server-ssl-private-key FILE',
                'Location of the SSL private key (.pem).'
            ) do |file|
                Cuboid::Options.rpc.server_ssl_private_key = file
            end

            on( '--server-ssl-certificate FILE',
                'Location of the SSL certificate (.pem).'
            ) do |file|
                Cuboid::Options.rpc.server_ssl_certificate = file
            end

            on( '--client-ssl-private-key FILE',
                'Location of the client SSL private key (.pem).'
            ) do |file|
                Cuboid::Options.rpc.client_ssl_private_key = file
            end

            on( '--client-ssl-certificate FILE',
                'Location of the client SSL certificate (.pem).'
            ) do |file|
                Cuboid::Options.rpc.client_ssl_certificate = file
            end
        end

        separator ''
        separator 'System'

        on( '--system-max-slots SLOTS', Integer,
            'Maximum amount of Instances to be alive at any given time.',
            'Only applicable when no Agent has been provided.',
            '(Default: auto)'
        ) do |max_slots|
            Cuboid::Options.system.max_slots = max_slots
        end
    end

    def validate
        if Cuboid::Options.agent.url
            begin
                SCNR::Engine::RPC::Client::Agent.new(
                    Cuboid::Options.agent.url
                ).alive?
            rescue => e
                print_error "Could not reach Agent at: #{Cuboid::Options.agent.url}"
                print_error "#{e.class}: #{e.to_s}"
                exit 1
            end
        end

        if Cuboid::Options.scheduler.url
            begin
                SCNR::Engine::RPC::Client::Scheduler.new(
                    Cuboid::Options.scheduler.url
                ).alive?
            rescue => e
                print_error "Could not reach Scheduler at: #{Cuboid::Options.scheduler.url}"
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

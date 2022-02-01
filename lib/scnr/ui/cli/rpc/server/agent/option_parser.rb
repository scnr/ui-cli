=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../../../output'
require_relative '../../../option_parser'

module SCNR
module UI::CLI
module RPC
module Server
class Agent

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

    attr_reader :cli

    def initialize
        super

        separator 'Server'

        on( '--name NAME', 'Name for this Agent.' ) do |name|
            Cuboid::Options.agent.name = name
        end

        on( '--address ADDRESS', 'Hostname or IP address to bind to.',
               "(Default: #{Cuboid::Options.rpc.server_address})"
        ) do |address|
            Cuboid::Options.rpc.server_address = address
        end

        on( '--external-address ADDRESS', 'Hostname or IP address to advertise.',
               "(Default: #{Cuboid::Options.rpc.server_address})"
        ) do |address|
            Cuboid::Options.rpc.server_external_address = address
        end

        on( '--port NUMBER', 'Port to listen to.', Integer,
               "(Default: #{Cuboid::Options.rpc.server_port})"
        ) do |port|
            Cuboid::Options.rpc.server_port = port
        end

        on( '--port-range BEGINNING-END',
               'Specify port range for the spawned RPC instances.',
               "(Default: #{Cuboid::Options.agent.instance_port_range.join( '-' )})"
        ) do |range|
            Cuboid::Options.agent.instance_port_range = range.split( '-' ).map(&:to_i)
        end

        separator ''
        separator 'Grid'

        on( '--peer URL', 'URL of a peering Agent.' ) do |url|
            Cuboid::Options.agent.peer = url
        end

        on( '--strategy STRATEGY', 'Default distribution strategy.',
            "(Available: #{Cuboid::OptionGroups::Agent::STRATEGIES.to_a.join( ', ')})",
            "(Default: #{Cuboid::Options.agent.strategy})"
        ) do |name|
            Cuboid::Options.agent.strategy = strategy
        end

        separator ''
        separator 'Output'

        on( '--output-reroute-to-logfile',
               "Reroute all output to log-files under: #{options.paths.logs}"
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
        separator 'SSL'

        on( '--ssl-ca FILE',
               'Location of the CA certificate (.pem).'
        ) do |file|
            Cuboid::Options.rpc.ssl_ca = file
        end

        on( '--server-ssl-private-key FILE',
               'Location of the server SSL private key (.pem).'
        ) do |file|
            Cuboid::Options.rpc.server_ssl_private_key = file
        end

        on( '--server-ssl-certificate FILE',
               'Location of the server SSL certificate (.pem).'
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

        separator ''
        separator 'Snapshot'

        on( '--snapshot-save-path DIRECTORY', String,
            'Directory under which to store snapshots of suspended scans.',
            "(Default: #{Cuboid::Options.paths.snapshots})"
        ) do |path|
            Cuboid::Options.snapshot.path = path
        end

        separator ''
        separator 'System'

        on( '--system-max-slots SLOTS', Integer,
            'Maximum amount of Instances to be alive at any given time.',
            '(Default: auto)'
        ) do |max_slots|
            Cuboid::Options.system.max_slots = max_slots
        end
    end

    def validate
        if Cuboid::Options.agent.peer
            begin
                SCNR::Engine::RPC::Client::Agent.new(
                  Cuboid::Options.agent.peer
                ).alive?
            rescue => e
                print_error "Could not reach peer at: #{Cuboid::Options.agent.peer}"
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
end

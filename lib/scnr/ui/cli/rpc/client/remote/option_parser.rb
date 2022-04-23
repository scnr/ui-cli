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

    attr_reader :multi_processes

    def grid
        separator 'Grid'

        on( '--agent-url HOST:PORT', 'Agent to use.' ) do |url|
            Cuboid::Options.agent.url = url
        end

        on( '--agent-strategy STRATEGY', 'Default distribution strategy.',
            "(Available: #{Cuboid::OptionGroups::Agent::STRATEGIES.to_a.join( ', ')})",
            "(Default: #{Cuboid::Options.agent.strategy})"
        ) do |strategy|
            Cuboid::Options.agent.strategy = strategy
        end
    end

    def multi
        separator 'Multi-process'

        on( '--multi-processes PROCESSES', Integer, 'How many processes to use.' ) do |processes|
            @multi_processes = processes
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

        super
    end

    def banner
        "Usage: #{$0} [options] --agent-url=HOST:PORT URL"
    end

end

end
end
end
end
end

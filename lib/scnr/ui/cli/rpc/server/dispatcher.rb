=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'dispatcher/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC
module Server

# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class Dispatcher

    def initialize
        OptionParser.new.parse

        SCNR::Application.spawn(
            :dispatcher,

            name:               Cuboid::Options.dispatcher.name,
            strategy:           Cuboid::Options.dispatcher.strategy,
            neighbour:          Cuboid::Options.dispatcher.neighbour,

            port:               Cuboid::Options.rpc.server_port,
            address:            Cuboid::Options.rpc.server_address,
            external_address:   Cuboid::Options.rpc.server_external_address,

            ssl:                {
                ca:       Cuboid::Options.rpc.ssl_ca,
                server:   {
                    private_key:    Cuboid::Options.rpc.server_ssl_private_key,
                    certificate:    Cuboid::Options.rpc.server_ssl_certificate
                },
                client:   {
                    private_key:    Cuboid::Options.rpc.client_ssl_private_key,
                    certificate:    Cuboid::Options.rpc.client_ssl_certificate
                }
            }
        )
    end

end
end
end
end
end

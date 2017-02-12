=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'server/option_parser'

module SCNR

require 'scnr/engine/rest/server'
require_relative '../utilities'

module UI::CLI
module Rest

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Server

    def initialize
        parser = OptionParser.new
        parser.parse

        Engine::Rest::Server.run!(
            port:            Engine::Options.rpc.server_port,
            bind:            Engine::Options.rpc.server_address,

            username:        parser.username,
            password:        parser.password,

            ssl_ca:          Engine::Options.rpc.ssl_ca,
            ssl_key:         Engine::Options.rpc.server_ssl_private_key,
            ssl_certificate: Engine::Options.rpc.server_ssl_certificate
        )
    end

end

end
end
end

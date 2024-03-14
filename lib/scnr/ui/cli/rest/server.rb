=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'server/option_parser'

module SCNR

require_relative '../utilities'

module UI::CLI
module Rest

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Server

    def initialize
        SCNR::License.guard! :dev, :trial, :sdlc, :enterprise

        parser = OptionParser.new
        parser.parse

        SCNR::Application.spawn(
          :rest,

          username: parser.username,
          password: parser.password,

          ssl:  {
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

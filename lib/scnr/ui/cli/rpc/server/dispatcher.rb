=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'terminal-table/import'
require_relative 'dispatcher/option_parser'

module SCNR

require 'scnr/engine/rpc/server/dispatcher'
require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC
module Server

# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class Dispatcher

    def initialize
        OptionParser.new.parse

        Arachni::Reactor.global.run do
            Engine::RPC::Server::Dispatcher.new
        end
    end

end
end
end
end
end

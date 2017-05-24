=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'queue/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC
module Server

# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class Queue

    def initialize
        OptionParser.new.parse

        require 'scnr/engine/rpc/server/queue'

        Arachni::Reactor.global.run_in_thread if !Arachni::Reactor.global.running?
        Arachni::Reactor.global.schedule do
            Engine::RPC::Server::Queue.new
        end
        Arachni::Reactor.global.wait
    end

end

end
end
end
end

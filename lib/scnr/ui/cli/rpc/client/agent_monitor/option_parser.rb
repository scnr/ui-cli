=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../remote/option_parser'

module SCNR
module UI::CLI
module RPC
module Client
class AgentMonitor

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < Client::Remote::OptionParser

    def after_parse
        Cuboid::Options.agent.url = ARGV.shift
    end

    def validate
        # Check for missing Agent
        return if Cuboid::Options.agent.url

        print_error 'Missing DISPATCHER_URL option.'
        exit 1
    end

    def banner
        "Usage: #{$0} [options] DISPATCHER_URL"
    end

end
end
end
end
end
end

=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../remote/option_parser'

module SCNR
module UI::CLI
module RPC
module Client
class DispatcherMonitor

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < Client::Remote::OptionParser

    def after_parse
        Cuboid::Options.dispatcher.url = ARGV.shift
    end

    def validate
        # Check for missing Dispatcher
        return if Cuboid::Options.dispatcher.url

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

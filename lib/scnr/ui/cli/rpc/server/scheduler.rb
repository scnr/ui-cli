=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'scheduler/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC
module Server

# @author Tasos "Zapotek" Laskos<tasos.laskos@gmail.com>
class Scheduler

    def initialize
        OptionParser.new.parse

        SCNR::Application.spawn( :scheduler )
    end

end

end
end
end
end

=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

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
        parser = OptionParser.new
        parser.parse

        SCNR::Application.spawn( :rest )
    end

end

end
end
end

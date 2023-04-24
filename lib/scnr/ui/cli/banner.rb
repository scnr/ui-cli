=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'rubygems'
require 'bundler/setup'

module SCNR
module UI
module CLI

    WEBSITE = 'https://ecsypno.com'

    BANNER =<<EOBANNER
SCNR::UI::CLI v#{CLI::VERSION} - SCNR::Engine v#{Engine::VERSION}
    by Ecsypno Single Member P.C. (Copyright 2023)
             #{WEBSITE}
EOBANNER

end
end
end

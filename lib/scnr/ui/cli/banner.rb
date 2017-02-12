=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'rubygems'
require 'bundler/setup'

module SCNR
module UI
module CLI

    WEBSITE = 'http://sarosys.com'

    BANNER =<<EOBANNER
SCNR::UI::CLI v#{CLI::VERSION} - SCNR::Engine v#{Engine::VERSION}
   by Sarosys LLC <#{WEBSITE}>
EOBANNER

end
end
end

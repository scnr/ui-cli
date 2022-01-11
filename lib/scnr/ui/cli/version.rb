=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

module SCNR
module UI
module CLI

    VERSION = IO.read( File.dirname( __FILE__ ) + '/version' ).strip

end
end
end

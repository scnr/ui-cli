=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

# Setup an output interface for the Engine before including it, otherwise it's
# going to use its default which is basically a black hole.
require_relative 'cli/output'
require 'scnr/application'

require_relative 'cli/version'
require_relative 'cli/banner'

module SCNR
module UI
module CLI

end
end
end

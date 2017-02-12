=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/ui/cli/output'
require 'scnr/engine'

require 'scnr/ui/cli/version'
require 'scnr/ui/cli/banner'

module SCNR
module UI
module CLI

    Output.initialize( SCNR::Engine )

    class <<self

        # @return   [Bool]
        #   `true` if the `SCNR_ENGINE_PROFILE` env variable is set, `false` otherwise.
        def profile?
            !!ENV['SCNR_ENGINE_PROFILE']
        end

    end


end
end
end

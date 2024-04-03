#!/usr/bin/env ruby
=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/ui/cli'

SCNR::License.guard! :dev, :trial, :basic, :pro, :enterprise

include SCNR::Engine
include UI::Output

if ARGV.empty?
    puts <<EOHELP
            Codename SCNR v#{SCNR::VERSION}
   by Ecsypno Single Member P.C. <#{WEBSITE}>

Usage: #{__FILE__} SCRIPT

Pre-loads the SCNR::Engine libraries and loads and runs the given Ruby script.

(Run 'mute/unmute' to change system output.)
EOHELP
    exit
end

load ARGV.shift

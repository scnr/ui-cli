#!/usr/bin/env ruby
=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/ui/cli'
require 'scnr/ui/cli/rpc/client/scheduler/detach'

if SCNR::Engine.windows?
    SCNR::UI::CLI::Output.print_error 'This interface is not available on MS Windows.'
    exit
end

SCNR::UI::CLI::RPC::Client::Scheduler::Detach.new

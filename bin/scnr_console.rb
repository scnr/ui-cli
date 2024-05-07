#!/usr/bin/env ruby
=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/ui/cli'
require 'irb'
require 'irb/completion'

SCNR::License.guard! :dev, :trial, :basic, :pro, :enterprise

include SCNR::Engine
include UI::Output

puts <<EOHELP
            Codename SCNR v#{SCNR::VERSION}
   by Ecsypno Single Member P.C. <#{WEBSITE}>
EOHELP
puts
puts "(Run 'mute/unmute' to change system output.)"

IRB.setup nil
IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context

HISTFILE = '~/.irb_history'
MAXHISTSIZE = 300

begin
    histfile = File.expand_path( HISTFILE )
    if File.exists?( histfile )
        lines = IO.readlines( histfile ).map { |line| line.chomp }
        Reline::HISTORY.push( *lines )
    end
    Kernel.at_exit do
        lines = Reline::HISTORY.to_a.reverse.uniq.reverse
        lines = lines[-MAXHISTSIZE, MAXHISTSIZE] if lines.size > MAXHISTSIZE
        File.open( histfile, 'a' ) { |f| f.write( lines.join( "\n" ) ) }
    end
rescue => e
    puts "Error when configuring permanent history: #{e}"
end

require 'irb/ext/multi-irb'
IRB.irb nil, SCNR::Engine

=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'reporter/option_parser'
require_relative 'utilities'

module SCNR
module UI::CLI

# Provides a command line interface to the {Engine::Report::Manager}.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Reporter
    include Output
    include Utilities

    def initialize
        @reporters = SCNR::Engine::Reporter::Manager.new
        run
    end

    private

    def run
        parser = OptionParser.new
        parser.reporter
        parser.parse

        reporters = parser.reporters
        reporters = { 'stdout' => {} } if reporters.empty?

        errors = false
        begin

            report = begin
                Engine::Report.load( SCNR::Engine::Options.report.path )
            rescue
                Cuboid::Report.load( SCNR::Engine::Options.report.path ).data
            end

            reporters.each do |name, options|
                @reporters.run( name, report, options, true )
            end
        rescue => e
            errors = true
            print_exception e
        end

        exit( errors ? 1 : 0 )
    end

end
end
end

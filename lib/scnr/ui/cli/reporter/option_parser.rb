=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../option_parser'

module SCNR
module UI::CLI

class Reporter

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

    attr_reader :framework

    attr_reader :report

    # @return   [Hash{<String, Symbol> => Hash{String => String}}]
    #   Reports to load, by name, as keys and their options as values.
    #
    # @see Reporters
    # @see Reporter::Base
    # @see Reporter::Manager
    attr_accessor :reporters

    def initialize(*)
        super

        @framework = SCNR::Engine::Framework.unsafe
        @reporters = {}
    end

    def reporter
        separator ''
        separator 'Reporters'

        on( '--reporters-list [GLOB]',
            'List available reporters based on the provided glob.',
            '(If no glob is provided all will be listed.)'
        ) do |pattern|
            list_reporters( framework.list_reporters( pattern ) )
            exit
        end

        on( "--reporter 'REPORTER:OPTION=VALUE,OPTION2=VALUE2'",
            "REPORTER is the name of the reporter as displayed by '--reporters-list'.",
            "(Reporters are referenced by their filename without the '.rb' " +
                "extension, use '--reporters-list' to list all.)",
            '(Default: stdout)',
            '(Can be used multiple times.)'
        ) do |reporter|
            prepare_component_options( reporters, reporter )
        end
    end

    def after_parse
        @report = ARGV.shift
    end

    def validate
        if !@report
            print_error 'No report file provided.'
            exit 1
        end

        if reporters.any?
            begin
                framework.reporters.load( reporters.keys )
            rescue SCNR::Engine::Component::Error::NotFound => e
                print_error e
                print_info 'Available reporters are:'
                print_info framework.reporters.available.join( ', ' )
                print_line
                print_info 'Use the \'--reporters-list\' parameter to see a' <<
                               ' detailed list of all available reports.'
                exit 1
            ensure
                framework.reporters.clear
            end
        end
    end

    def banner
        "Usage: #{$0} REPORT"
    end

end
end
end
end

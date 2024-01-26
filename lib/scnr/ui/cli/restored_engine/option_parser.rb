=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative '../option_parser'

module SCNR
module UI::CLI

class RestoredEngine

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser < UI::CLI::OptionParser

    attr_accessor :snapshot_path

    def timeout
        separator ''
        separator 'Timeout'

        on( '--timeout HOURS:MINUTES:SECONDS',
            'Stop the scan after the given duration is exceeded.'
        ) do |time|
            @timeout = SCNR::Engine::Utilities.hms_to_seconds( time )
        end
    end

    def system
        separator ''
        separator 'System'

        on( '--system-slots-override',
            'Override automated slot calculation and run the scan.'
        ) do
            options.system.max_slots = 1
        end
    end

    def timeout_suspend
        on( '--timeout-suspend',
            'Suspend after the timeout.',
            'You can use the generated file to resume the scan with the \'scnr_engine_restore\' executable.'
        ) do
            @timeout_suspend = true
        end
    end

    def timeout_suspend?
        !!@timeout_suspend
    end

    def get_timeout
        @timeout
    end

    def snapshot
        separator ''
        separator 'Snapshot'

        on( '--snapshot-print-metadata',
            'Show the metadata associated with the specified snapshot.' ) do
            @print_metadata = true
        end

        on( '--snapshot-save-path PATH', String,
            'Directory or file path where to store the scan snapshot.',
            'You can use the generated file to resume the scan at a later time ' +
                "with the 'scnr_engine_restore' executable."
        ) do |path|
            options.snapshot.path = path
        end
    end

    def report
        separator ''
        separator 'Report'

        on( '--report-save-path PATH', String,
            'Directory or file path where to store the scan report.',
            "You can use the generated file to create reports in several " +
                "formats with the 'scnr_engine_report' executable."
        ) do |path|
            options.report.path = path
        end
    end


    def print_metadata?
        !!@print_metadata
    end

    def after_parse
        options.snapshot.path = ARGV.shift
    end

    def validate
        validate_timeout
        validate_snapshot_path
    end

    def validate_timeout
        return if !@timeout || @timeout > 0

        print_bad 'Invalid timeout value.'
        exit 1
    end

    def validate_snapshot_path
        if !options.snapshot.path
            print_error 'No snapshot file provided.'
            exit 1
        end

        begin
            SCNR::Engine::Snapshot.read_metadata options.snapshot.path
        rescue SCNR::Engine::Snapshot::Error::InvalidFile => e
            print_error e.to_s
            exit 1
        end
    end

    def banner
        "Usage: #{$0} SNAPSHOT"
    end

end
end
end
end

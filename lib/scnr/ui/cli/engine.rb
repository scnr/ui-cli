=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine/api'
require_relative 'system_info'
require_relative 'engine/option_parser'
require_relative 'utilities'

module SCNR
module UI::CLI

# Provides a command line interface for the {SCNR::Engine::Framework}.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Engine
    include Output
    include Utilities

    # @return [Engine]
    attr_reader :framework

    # Initializes the command line interface and the {Framework}.
    def initialize
        @scan = SCNR::Engine::API.new.scan

        parse_options
        ensure_available_slots

        # Reset the engine's HTTP interface so that options will take effect.
        SCNR::Engine::HTTP::Client.reset

        @show_command_screen = nil
        @cleanup_handler     = nil

        # Step into a pry session for debugging.
        if Signal.list.include?( 'USR1' )
            trap( 'USR1' ) do
                next if @usr1
                @usr1 = true

                if @get_user_command_thread
                    @get_user_command_thread.kill
                    @get_user_command_thread = nil
                end

                mute
                clear_screen

                Thread.new do
                    require 'pry'
                    require 'debug'

                    pry

                    clear_screen
                    unmute
                    get_user_command

                    @usr1 = nil
                end
            end
        end

        # Print out exactly what's going on on Ruby's side.
        if Signal.list.include?( 'USR2' )
            trap( 'USR2' ) do
                if @get_user_command_thread
                    @get_user_command_thread.kill
                    @get_user_command_thread = nil
                end

                if @usr2
                    @usr2 = nil

                    set_trace_func( nil )

                    clear_screen
                    unmute
                    get_user_command
                    next
                end

                @usr2 = true

                mute
                clear_screen

                set_trace_func proc { |event, file, line, id, binding, classname|
                    printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
                }
            end
        end

        trap( 'INT' ) do
            @get_user_command_thread.kill
            @get_user_command_thread = nil

            hide_command_screen
            clear_screen
            shutdown
        end

        # Kick the tires and light the fires.
        run
    end

    def ensure_available_slots
        return if !Cuboid::System.max_utilization?

        print_bad 'Cannot perform the scan, the system has no available slots.'
        print_line
        SystemInfo.new.slot_info
        print_line
        print_info "Set '--system-slots-override' to override this safeguard."

        exit 1
    end

    private

    def run
        print_status 'Initializing...'

        # Won't work properly on MS Windows or when running in background.
        get_user_command

        begin
            # We may need to kill the audit so put it in a thread.
            @scan_thread = Thread.new do
                @scan.run do
                    hide_command_screen
                    restore_output_options
                    clear_screen
                end
            end
            @scan_thread.join

            # If the user requested to abort the scan, wait for the thread
            # that takes care of the clean-up to finish.
            if @cleanup_handler
                @cleanup_handler.join
            else
                generate_reports
            end

            if has_error_log?
                print_info "The scan has logged errors: #{error_logfile}"
            end

            if @snapshot_path
                filesize = (File.size( @snapshot_path ).to_f / 2**20).round(2)
                print_info "Snapshot saved at: #{@snapshot_path} [#{filesize}MB]"
            end

            print_statistics
        rescue SCNR::Engine::Component::Options::Error::Invalid => e
            print_error e
            print_line
            exit 1
        rescue SCNR::Engine::Error => e
            print_error e
            print_info "Run scnr_engine with the '-h' parameter for help."
            print_line
            exit 1
        rescue Exception => e
            print_exception e
            exit 1
        end
    end

    def print_statistics( unmute = false )
        statistics = @scan.statistics

        http            = statistics[:http]
        browser_cluster = statistics[:browser_pool]

        refresh_line nil, unmute
        refresh_info( "Audited #{statistics[:audited_pages]} page snapshots.", unmute )

        if SCNR::Engine::Options.scope.page_limit
            refresh_info( 'Audit limited to a max of ' <<
                "#{SCNR::Engine::Options.scope.page_limit} pages.", unmute )
        end

        refresh_line nil, unmute

        refresh_info( "Duration: #{seconds_to_hms( statistics[:runtime] )}", unmute )

        res_req = "#{statistics[:http][:response_count]}/#{statistics[:http][:request_count]}"
        refresh_info( "Processed #{res_req} HTTP requests -- timed-out: #{http[:time_out_count]}", unmute )

        avg = "-- #{http[:total_responses_per_second].round(3)} requests/second."
        refresh_info( avg, unmute )

        jobs = "#{browser_cluster[:completed_job_count]}/#{browser_cluster[:queued_job_count]}"
        refresh_info( "Processed #{jobs} browser jobs -- timed-out: #{browser_cluster[:time_out_count]}", unmute )

        jobsps = "-- #{browser_cluster[:seconds_per_job].round(3)} second/job."
        refresh_info( jobsps, unmute )

        refresh_line nil, unmute
        if !statistics[:current_page].to_s.empty?
            refresh_info( "Currently auditing          #{statistics[:current_page]}", unmute )
        end

        refresh_info( "Burst response time sum     #{http[:burst_response_time_sum].round(3)} seconds", unmute )
        refresh_info( "Burst response count        #{http[:burst_response_count]}", unmute )
        refresh_info( "Burst average response time #{http[:burst_average_response_time].round(3)} seconds", unmute )
        refresh_info( "Burst average               #{http[:burst_responses_per_second].round(3)} requests/second", unmute )
        refresh_info( "Original max concurrency    #{options.http.request_concurrency}", unmute )
        refresh_info( "Throttled max concurrency   #{http[:max_concurrency]}", unmute )

        refresh_line nil, unmute
    end

    def print_issues( unmute = false )
        super( SCNR::Engine::Data.issues.all, unmute )
    end

    # Handles Ctrl+C signals.
    def show_command_screen
        return if command_screen_shown?

        @show_command_screen = Thread.new do
            clear_screen
            get_user_command
            mute

            loop do
                empty_screen

                refresh_info 'Results thus far:'

                begin
                    print_issues( true )
                    print_statistics( true )
                rescue Exception => e
                    exception_jail{ raise e }
                    raise e
                end

                refresh_info "Status: #{@scan.status.to_s.capitalize}"
                @scan.status_messages.each do |message|
                    refresh_info "  #{message}"
                end

                if !@scan.suspending?
                    refresh_info
                    refresh_info 'Hit:'

                    {
                        'Enter' => 'go back to status messages',
                        'p'     => 'pause the scan',
                        'r'     => 'resume the scan',
                        'a'     => 'abort the scan',
                        's'     => 'suspend the scan to disk',
                        'g'     => 'generate a report',
                        'v'     => "#{verbose? ? 'dis' : 'en'}able verbose messages",
                        'd'     => "#{debug? ? 'dis' : 'en'}able debugging messages.\n" <<
                            "#{' ' * 11}(You can set it to the desired level by sending d[1-4]," <<
                            " current level is #{debug_level})"
                    }.each do |key, action|
                        next if %w(Enter s p).include?( key ) && !@scan.scanning?
                        next if key == 'r' && !(@scan.paused? || @scan.pausing?)

                        refresh_info "  '#{key}' to #{action}."
                    end
                end

                flush
                mute
                sleep 1
            end
        end
    end

    def command_screen_shown?
        @show_command_screen && @show_command_screen.alive?
    end

    def refresh_line( string = nil, unmute = true )
        print_line( string.to_s, unmute )
    end

    def refresh_info( string = nil, unmute = true )
        print_info( string.to_s, unmute )
    end

    def get_user_command
        return if SCNR::Engine.windows? || @daemon_friendly

        @get_user_command_thread ||= Thread.new do
            command = gets.strip
            @get_user_command_thread = nil

            get_user_command

            # Only accept the empty/toggle-screen command when the command
            # screen is not shown.
            next if !command_screen_shown? && !command.empty?

            case command

                # Abort
                when 'a'
                    shutdown

                # Pause
                when 'p'
                    return if !@scan.scanning?

                    @scan.pause!

                # Resume
                when 'r'
                    return if !@scan.pausing? || !@scan.paused?
                    @scan.resume!

                # Suspend
                when 's'
                    return if !@scan.scanning?
                    suspend

                # Generate reports.
                when 'g'
                    hide_command_screen
                    generate_reports
                    restore_output_options

                # Toggle verbosity.
                when 'v'
                    hide_command_screen
                    verbose? ? verbose_off : verbose_on

                # Toggle debugging messages.
                when /d(\d?)/
                    hide_command_screen

                    if (level = Regexp.last_match[1]).empty?
                        debug? ? debug_off : debug_on
                    else
                        debug_on( level.to_i )
                    end

                # Toggle between status messages and command screens.
                when ''
                    if @show_command_screen
                        hide_command_screen
                    else
                        capture_output_options
                        show_command_screen
                    end

                    empty_screen
            end
        end
    end

    def reset_command_screen
        hide_command_screen
        show_command_screen
    end

    def hide_command_screen
        @show_command_screen.kill if @show_command_screen
        @show_command_screen = nil
        restore_output_options
    end

    def capture_output_options
        @only_positives_opt = only_positives?
        disable_only_positives
    end

    def restore_output_options
        only_positives if @only_positives_opt
        unmute
    end

    def suspend
        @cleanup_handler = Thread.new do
            exception_jail do
                @snapshot_path = @scan.suspend!

                hide_command_screen
                clear_screen

                capture_output_options

                generate_reports
            end
        end
    end

    def shutdown
        capture_output_options

        print_status 'Aborting...'
        print_info 'Please wait while the system cleans up.'

        killed = Queue.new
        @cleanup_handler = Thread.new do
            exception_jail do
                killed.pop

                @scan.abort!

                hide_command_screen
                restore_output_options
                clear_screen

                generate_reports
            end
        end

        @scan_thread.kill
        killed << true
    end

    def generate_reports
        capture_output_options

        report = @scan.generate_report

        SCNR::Engine::Reporter::Manager.new.run :stdout, report

        filepath = report.save( options.report.path )
        filesize = (File.size( filepath ).to_f / 2**20).round(2)

        print_line
        print_info "Report saved at: #{filepath} [#{filesize}MB]"
    end

    # It parses and processes CLI options.
    #
    # Loads checks, reports, saves/loads profiles etc.
    # It basically prepares the engine before calling {Engine::Framework#run}.
    def parse_options
        parser = OptionParser.new

        parser.daemon_friendly
        parser.authorized_by
        parser.output
        parser.scope
        parser.audit
        parser.input
        parser.http
        parser.checks
        parser.plugins
        parser.platforms
        parser.session
        parser.profiles
        parser.dom
        parser.device
        parser.report
        parser.snapshot
        parser.timeout
        parser.system
        parser.parse

        @daemon_friendly = parser.daemon_friendly?

        if options.checks.any?
        #     begin
        #         @scan.checks.load( options.checks )
        #     rescue SCNR::Engine::Component::Error::NotFound => e
        #         print_error e
        #         print_info 'Available checks are:'
        #         print_info @scan.checks.available.join( ', ' )
        #         print_line
        #         print_info 'Use the \'--checks-list\' parameter to see a ' <<
        #                        'detailed list of all available checks.'
        #         exit 1
        #     end
        else
            print_info 'No checks were specified, loading all.'
            options.checks = ['*']
        end

        # @scan.plugins.load_defaults
        # if options.plugins.any?
        #     begin
        #         @scan.plugins.load( options.plugins.keys )
        #     rescue SCNR::Engine::Component::Error::NotFound => e
        #         print_error e
        #         print_info 'Available plugins are:'
        #         print_info @scan.plugins.available.join( ', ' )
        #         print_line
        #         print_info 'Use the \'--plugins-list\' parameter to see a ' <<
        #                        'detailed list of all available plugins.'
        #         exit 1
        #     end
        # end
        #
        # if options.platforms.any?
        #     begin
        #         SCNR::Engine::Platform::Manager.new( options.platforms )
        #     rescue SCNR::Engine::Platform::Error::Invalid => e
        #         options.platforms.clear
        #         print_error e
        #         print_info 'Available platforms are:'
        #         print_info Platform::Manager.new.valid.to_a.join( ', ' )
        #         print_line
        #         print_info 'Use the \'--platforms-list\' parameter to see a' <<
        #                        ' detailed list of all available platforms.'
        #         exit 1
        #     end
        # end

        if !options.audit.links? && !options.audit.forms? &&
            !options.audit.cookies? && !options.audit.headers? &&
            !options.audit.link_templates? && !options.audit.jsons? &&
            !options.audit.xmls? && !options.audit.ui_inputs? &&
            !options.audit.ui_forms?

            print_info 'No element audit options were specified, will audit ' <<
                           'links, forms, cookies, UI inputs, UI forms, JSONs and XMLs.'
            print_line

            options.audit.elements :links, :forms, :cookies, :ui_inputs,
                                   :ui_forms, :jsons, :xmls
        end
    end

    def options
        SCNR::Engine::Options
    end

end
end
end

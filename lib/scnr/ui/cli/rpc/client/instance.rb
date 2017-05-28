=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

module SCNR

require 'scnr/engine/rpc/client/instance'
require 'scnr/ui/cli/mixins/terminal'
require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC
module Client

# Provides a command-line RPC client/interface for an {RPC::Server::Instance}.
#
# This interface should be your first stop when looking into using/creating your
# own RPC client.
#
# Of course, you don't need to have access to the engine or any other Engine
# class for your own client, this is used here just to provide some other info
# to the user.
#
# However, in contrast with everywhere else in the system (where RPC operations
# are asynchronous), this interface operates in blocking mode as its simplicity
# does not warrant the extra complexity of asynchronous calls.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Instance
    include Output
    include Utilities

    attr_reader :error_log_file
    attr_reader :framework

    # @param    [RPC::Client::Instance]     instance
    #   Instance to control.
    # @param    [Integer]  timeout
    def initialize( instance, timeout = nil )
        @options  = SCNR::Engine::Options.instance
        @instance = instance
        @timeout  = timeout

        clear_screen
        move_to_home

        # We don't need the engine for much, in this case only for report
        # generation, version number etc.
        @framework = SCNR::Engine::Framework.new( @options )
        @issues    = []

        @progress_mutex = Mutex.new
    end

    def run
        timeout_time = Time.now + @timeout.to_i
        timed_out    = false

        get_user_command

        begin

            # We may be re-attaching, don't call scan again.
            if @instance.status == :ready
                # Start the show!
                @instance.scan prepare_rpc_options
            end

            while busy?
                if @timeout && Time.now >= timeout_time
                    timed_out = true
                    break
                end

                print_progress
                sleep 5
                refresh_progress
            end
        rescue Interrupt
            print_info "Detached from: #{@instance.url}/#{@instance.token}"
            return
        rescue => e
            print_exception e
        end

        report_and_shutdown

        return if !timed_out
        print_error 'Timeout was reached.'
    end

    private

    def print_progress
        empty_screen

        print_banner

        print_line
        print_info "Attached to: #{@instance.url}/#{@instance.token}"
        print_line

        print_issues
        print_line

        print_statistics
        print_line

        if has_errors?
            print_bad "This scan has encountered errors, see: #{error_log_file}"
            print_line
        end

        if !suspending? && !aborting?
            print_info
            print_info 'Hit:'

            {
                'Enter' => 'force refresh',
                'p'     => 'pause the scan',
                'r'     => 'resume the scan',
                'a'     => 'abort the scan',
                's'     => 'suspend the scan to disk',
                'g'     => 'generate a report'
            }.each do |key, action|
                next if %w(Enter s p).include?( key ) && !scanning?
                next if key == 'r' && !(paused? || pausing?)

                print_info "  '#{key}' to #{action}."
            end

            print_line
            print_info "('Ctrl+C' detaches from the Instance.)"
            print_line

            if @report_filepath
                print_info "Report saved at:   #{@report_filepath} [#{@report_filesize}MB]"
                print_line
            end

        end

        flush
    end

    %w(paused pausing suspended suspending scanning aborting).each do |s|
        define_method "#{s}?" do
            status == s.to_sym
        end
    end

    def get_user_command
        Thread.new do
            command = gets.strip

            get_user_command

            case command

                # Abort
                when 'a'
                    @abort = true

                # Pause
                when 'p'
                    return if !scanning?

                    @pause_id = @instance.pause

                # Resume
                when 'r'
                    return if !paused?
                    @instance.resume

                # Suspend
                when 's'
                    return if !scanning?
                    @instance.suspend

                # Generate reports.
                when 'g'
                    generate_reports

                when ''
                    get_user_command
            end

            refresh_progress
            print_progress
        end
    end

    def has_errors?
        !!error_log_file
    end

    def progress
        @progress or refresh_progress
    end

    def refresh_progress
        @progress_mutex.synchronize do
            @error_messages_cnt ||= 0
            @issue_digests      ||= []

            progress = @instance.native_progress(
                with:    [ :instances, :issues, errors: @error_messages_cnt ],
                without: [ issues: @issue_digests ]
            )

            return if !progress

            @progress = progress
            @issues  |= @progress[:issues]

            @issues = @issues.sort_by(&:digest).sort_by(&:severity).reverse

            # Keep issue digests and error messages in order to ask not to retrieve
            # them on subsequent progress calls in order to save bandwidth.
            @issue_digests  |= @progress[:issues].map( &:digest )

            if @progress[:errors].any?
                error_log_file = @instance.url.gsub( ':', '_' )
                @error_log_file = "#{error_log_file}.error.log"

                File.open( @error_log_file, 'a' ) { |f| f.write @progress[:errors].join( "\n" ) }

                @error_messages_cnt += @progress[:errors].size
            end

            @progress
        end
    end

    def busy?
        !aborting? && !!progress[:busy]
    end

    # Laconically output the discovered issues.
    #
    # This method is used during a pause.
    def print_issues
        super @issues
    end

    def prepare_rpc_options
        # No checks have been specified, set the mods to '*' (all).
        if @options.checks.empty?
            @options.checks = ['*']
        end

        if !@options.audit.links? && !@options.audit.forms? &&
            !@options.audit.cookies? && !@options.audit.headers? &&
            !@options.audit.link_templates? && !@options.audit.jsons? &&
            !@options.audit.xmls? && !@options.audit.ui_forms? &&
            !@options.audit.ui_inputs?

            print_info 'No element audit options were specified, will audit ' <<
                           'links, forms, cookies, UI forms, UI inputs, JSONs and XMLs.'
            print_line

            @options.audit.elements :links, :forms, :cookies, :jsons, :xmls,
                                    :ui_forms, :ui_inputs
        end

        if @options.http.cookie_jar_filepath
            @options.http.cookies =
                parse_cookie_jar( @options.http.cookie_jar_filepath )
        end

        opts = @options.to_rpc_data.deep_clone

        @framework.plugins.default.each do |plugin|
            opts['plugins'][plugin.to_s] ||= {}
        end

        opts
    end

    # Grabs the report from the RPC server and runs the selected Engine report.
    def report_and_shutdown
        print_status 'Shutting down and retrieving the report, please wait...'

        generate_reports( true )

        print_line
        print_info "Report saved at:   #{@report_filepath} [#{@report_filesize}MB]"

        if @instance.status == :suspended
            print_info "Snapshot saved at: #{@instance.snapshot_path}"
        end

        shutdown

        print_line
        print_statistics
        print_line
    end

    def generate_reports( abort = false )
        if abort
            report = @instance.native_abort_and_report
            @framework.reporters.run :stdout, report
        else
            report = @instance.native_report
        end

        @report_filepath = report.save( @options.report.path )
        @report_filesize = (File.size( @report_filepath ).to_f / 2**20).round(2)
    end

    def shutdown
        @instance.shutdown
    end

    def statistics
        progress[:statistics]
    end

    def status
        return :aborting if @abort
        progress[:status]
    end

    def print_statistics
        print_info "Status: #{status.to_s.capitalize}"

        print_info "Discovered #{statistics[:found_pages]} pages thus far."
        print_line

        http = statistics[:http]
        print_info "Sent #{http[:request_count]} requests."
        print_info "Received and analyzed #{http[:response_count]} responses."
        print_info( "In #{seconds_to_hms( statistics[:runtime] )}" )
        print_info "Average: #{http[:total_responses_per_second]} requests/second."

        print_line
        if statistics[:current_pages]
            print_info 'Currently auditing:'

            statistics[:current_pages].each.with_index do |url, i|
                cnt = "[#{i + 1}]".rjust( statistics[:current_pages].size.to_s.size + 4 )

                if url.to_s.empty?
                    print_info "#{cnt} Idle"
                else
                    print_info "#{cnt} #{url}"
                end
            end

            print_line
        else
            print_info "Currently auditing           #{statistics[:current_page]}"
        end

        print_info "Burst response time sum      #{http[:burst_response_time_sum]} seconds"
        print_info "Burst response count total   #{http[:burst_response_count]}"
        print_info "Burst average response time  #{http[:burst_average_response_time]} seconds"
        print_info "Burst average                #{http[:burst_responses_per_second]} requests/second"
        print_info "Timed-out requests           #{http[:time_out_count]}"
        print_info "Original max concurrency     #{@options.http.request_concurrency}"
        print_info "Throttled max concurrency    #{http[:max_concurrency]}"
    end

    def parse_cookie_jar( jar )
        # make sure that the provided cookie-jar file exists
        if !File.exist?( jar )
            fail Engine::Exceptions::NoCookieJar, "Cookie-jar '#{jar}' doesn't exist."
        end

        Engine::Element::Cookie.from_file( @options.url, jar ).inject({}) do |h, e|
            h.merge!( e.simple ); h
        end
    end

end

end
end
end
end

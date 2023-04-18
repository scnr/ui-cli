=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

module SCNR

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
    def initialize( instance, cli_options )
        @options     = SCNR::Engine::Options.instance
        @cli_options = cli_options
        @instance    = instance

        clear_screen
        move_to_home

        # We don't need the engine for much, in this case only for report
        # generation, version number etc.
        @framework = SCNR::Engine::Framework.unsafe
        @issues    = []

        @progress_mutex = Mutex.new
    end

    def run
        get_user_command

        begin

            # We may be re-attaching, don't call scan again.
            if @instance.status == :ready
                # Start the show!
                @instance.run prepare_rpc_options.merge(
                  multi: { instances: @cli_options.multi_instances }
                )
            end

            while busy?
                print_progress
                sleep 5
                refresh_progress
            end

            if !scheduler_url
                report_and_shutdown
            end
        rescue Interrupt
            print_line
            print_status "Disconnected from: #{@instance.url}/#{@instance.token}"
            return
        rescue => e
            print_exception e
        end
    end

    private

    def print_progress
        empty_screen

        print_banner

        print_line
        print_status "#{@instance.url}/#{@instance.token}"

        if scheduler_url
            print_info "Scheduler:      #{scheduler_url}"
        end

        if agent_url
            print_info "Agent: #{agent_url}"
        end

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
                next if %w(a s).include?( key ) && scheduler_url
                next if key == 'r' && !(paused? || pausing?)

                print_info "  '#{key}' to #{action}."
            end

            print_line
            print_info "('Ctrl+C' disconnects from the Instance.)"
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
            status == s
        end
    end

    def scheduler_url
        @progress[:scheduler_url]
    end

    def agent_url
        @progress[:agent_url]
    end

    def get_user_command
        Thread.report_on_exception = true

        Thread.new do
            command = gets.strip

            get_user_command

            case command

                # Abort
                when 'a'
                    return if scheduler_url
                    @instance.abort!

                # Pause
                when 'p'
                    @instance.pause!

                # Resume
                when 'r'
                    next if !paused?
                    @instance.resume!

                # Suspend
                when 's'
                    next if !scanning? || scheduler_url
                    @instance.suspend!

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

            progress = @instance.scan.progress(
                with:    [ :instances, :issues, errors: @error_messages_cnt ],
                without: [ issues: @issue_digests ]
            )

            return if !progress

            @progress = progress.my_symbolize_keys
            issues    = @progress[:issues].map { |i| SCNR::Engine::Issue.from_rpc_data i }
            @issues  |= issues

            @issues = @issues.sort_by(&:digest).sort_by(&:severity).reverse

            # Keep issue digests and error messages in order to ask not to retrieve
            # them on subsequent progress calls in order to save bandwidth.
            @issue_digests  |= issues.map( &:digest )

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
        progress[:running] || progress[:status] == 'ready'
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

        generate_reports

        print_line
        print_info "Report saved at:   #{@report_filepath} [#{@report_filesize}MB]"

        if @instance.status == :suspended
            print_info "Snapshot saved at: #{@instance.snapshot_path}"
        end

        print_line
        print_statistics
        print_line
    rescue => e
        ap e
    ensure
        shutdown
    end

    def generate_reports
        report = @instance.generate_report.data

        @framework.reporters.run :stdout, report

        @report_filepath = report.save( @options.report.path )
        @report_filesize = (File.size( @report_filepath ).to_f / 2**20).round(2)

    rescue => e
        print_error "Could not generate report: #{e}"
        print_error_backtrace e
    end

    def shutdown
        @instance.shutdown
    end

    def statistics
        progress[:statistics]
    end

    def status
        progress[:status]
    end

    def print_statistics
        http            = statistics[:http]
        browser_cluster = statistics[:browser_pool]

        print_info "Status: #{status.to_s.capitalize}"
        print_line
        print_info "Audited #{statistics[:audited_pages]} page snapshots."
        print_info "Duration: #{seconds_to_hms( statistics[:runtime] )}"
        print_line
        res_req = "#{http[:response_count]}/#{http[:request_count]}"
        print_info "Processed #{res_req} HTTP requests -- failed: #{http[:failed_count]}"
        print_info "-- #{http[:total_responses_per_second].round(3)} requests/second."

        jobs = "#{browser_cluster[:completed_job_count]}/#{browser_cluster[:queued_job_count]}"
        print_info "Processed #{jobs} browser jobs -- failed: #{browser_cluster[:failed_count]}"
        print_info "-- #{browser_cluster[:seconds_per_job].round(3)} second/job."

        print_line
        if @progress[:multi]
            print_info 'Currently auditing:'

            @progress[:multi][:auditors].values.each.with_index do |auditor_p, i|
                cnt = "[#{i + 1}]".rjust( @progress[:multi].size.to_s.size + 4 )
                url = auditor_p[:statistics][:current_page]

                if url.to_s.empty?
                    print_info "#{cnt} Idle"

                    if auditor_p[:messages].any?
                        print_info "    #{auditor_p[:messages].join( ', ' )}"
                    end

                else
                    print_info "#{cnt} #{url}"
                end
            end
        else
            print_info "Currently auditing           #{statistics[:current_page]}"
        end

        print_line
        print_info "Burst avg application time   #{http[:burst_average_app_time].round(3)} seconds"
        print_info "Burst average response time  #{http[:burst_average_response_time].round(2)} seconds"
        print_info "Burst average responses/s    #{http[:burst_responses_per_second].round(2)} requests/second"
        print_line
        print_info "Average application time    #{http[:total_average_app_time].round(3)} seconds"
        print_info "Download speed              #{(http[:download_bps] / 1000 * 8).round(3)} KBps"
        print_info "Upload speed                #{(http[:upload_bps] / 1000 * 8).round(3)} KBps"
        print_info "Concurrency                 #{http[:max_concurrency]}/#{@options.http.request_concurrency} connections"
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

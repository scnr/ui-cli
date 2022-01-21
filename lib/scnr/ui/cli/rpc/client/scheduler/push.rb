=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require_relative 'push/option_parser'

module SCNR

require 'scnr/ui/cli/utilities'

module UI::CLI
module RPC::Client
module Scheduler

class Push
    include Output

    def initialize
        @options   = SCNR::Engine::Options.instance
        @framework = SCNR::Engine::Framework.unsafe

        parser = Push::OptionParser.new
        parser.authorized_by
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
        parser.scheduler
        parser.ssl
        parser.parse

        options = parser.options

        begin
            scheduler = SCNR::Engine::RPC::Client::Scheduler.new( Cuboid::Options.scheduler.url )

            id = scheduler.push( prepare_rpc_options, priority: parser.priority )

            print_info "Pushed scan with ID: #{id}"
        rescue Arachni::RPC::Exceptions::ConnectionError => e
            print_error "Could not push to Scheduler at '#{Cuboid::Options.scheduler.url}'."
            print_debug "Error: #{e.to_s}."
            print_debug_backtrace e
            exit 1
        end

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

end

end
end
end
end

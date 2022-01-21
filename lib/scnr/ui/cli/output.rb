=begin
    Copyright 2020-2022 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine/ui/output_interface'

module SCNR
module UI
module CLI

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
module Output
    include SCNR::Engine::UI::OutputInterface

    def self.initialize
        @@mute            = false
        @@only_positives  = false
    end
    initialize

    # Prints and logs an error message.
    #
    # @param    [String]    str
    def print_error( str = '' )
        cl = caller_location
        print_color( "[-] #{cl}", 31, str, $stderr )
        log_error( "#{cl} #{str}" )
    end

    # Used to draw attention to a bad situation which isn't an error.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute
    def print_bad( str = '', unmute = false )
        return if muted? && !unmute
        print_color( '[-]', 31, str, $stdout, unmute )
    end

    # Prints a status message.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute    override mute
    def print_status( str = '', unmute = false )
        return if only_positives?
        print_color( '[*]', 34, str, $stdout, unmute )
    end

    # Prints an info message.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute
    def print_info( str = '', unmute = false )
        return if only_positives?
        print_color( '[~]', 30, str, $stdout, unmute )
    end

    # Prints a good message, something that went very very right, like the
    # discovery of an issue.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute
    def print_ok( str = '', unmute = false )
        print_color( '[+]', 32, str, $stdout, unmute )
    end

    # Prints a debugging message.
    #
    # @param    [String]    str
    #
    # @see #debug?
    def print_debug( str = '', level = 1 )
        return if !debug?( level )

        # Let's keep track of how much time went by from the last debug call
        # of the same level.
        @level_time ||= {}
        diff = @level_time[level] ? Time.now - @level_time[level] : 0.0
        diff = diff.round(1)
        @level_time[level] = Time.now

        print_color( "[#{@level_time[level]} - #{diff}] [#{'!' * level}] #{caller_location}", 36, str, $stderr )
    end

    # Prints a verbose message.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute
    #
    # @see #verbose?
    # @see #verbose!
    def print_verbose( str = '', unmute = false )
        return if !verbose?
        print_color( '[v]', 37, str, $stdout, unmute )
    end

    # Prints an unclassified message.
    #
    # @param    [String]    str
    # @param    [Bool]    unmute
    def print_line( str = '', unmute = false )
        return if only_positives?
        return if muted? && !unmute

        # We may get IO errors...freaky stuff...
        begin
            puts str
        rescue
        end
    end

    # Mutes everything but {#print_ok} messages.
    def only_positives
        @@only_positives = true
    end

    # Undoes {#only_positives}.
    def disable_only_positives
        @@only_positives = false
    end

    # @return    [Bool]
    def only_positives?
        @@only_positives
    end

    # Mutes all output messages, unless they explicitly override the mute status.
    def mute
        @@mute = true
    end

    # Unmutes output messages.
    def unmute
        @@mute = false
    end

    # @return   [Bool]
    def muted?
        @@mute
    end

    def output_provider_file
        __FILE__
    end

    private

    def output_root
        @output_root ||=
            File.expand_path( File.dirname( __FILE__ ) + '/../../../' ) + '/'
    end

    # Prints a message prefixed with a colored sign.
    #
    # @param    [String]    sign
    # @param    [Integer]   color     shell color number
    # @param    [String]    string    the string to output
    # @param    [IO]        out        output stream
    # @param    [Bool]      unmute    override mute
    def print_color( sign, color, string, out = $stdout, unmute = false )
        return if muted? && !unmute

        str = personalize_output( string )
        str = add_resource_usage_statistics( str ) if profile?

        # We may get IO errors...freaky stuff...
        begin
            if out.tty?
                out.print "\033[1;#{color.to_s}m #{sign}\033[1;00m #{str}\n"
            else
                out.print "#{sign} #{str}\n"
            end

            out.flush
        rescue
        end
    end

    def print_with_statistics( message = nil )
        print_info add_resource_usage_statistics( message )
    end

    def add_resource_usage_statistics( message )
        require 'sys/proctable'

        if !@rss
            @rss  = ::Sys::ProcTable.ps( Process.pid )[:rss]
            @lrss = @rss
            @time = Time.now
        end

        if Time.now - @time >= 2
            @rss  = ::Sys::ProcTable.ps( Process.pid )[:rss]
            @time = Time.now
        end

        sprintf(
            '%7.1f | %8.1f | ',
            rss_to_mb( @rss - @lrss ),
            rss_to_mb( @rss )
        ) + message.to_s
    ensure
        @lrss = @rss
    end

    def rss_to_mb( rss )
        ( rss * 4096.0 / 1024.0 / 1024.0 ).round( 1 )
    end

    # @return   [Bool]
    #   `true` if the `SCNR_ENGINE_PROFILE` env variable is set, `false` otherwise.
    def profile?
        !!ENV['SCNR_ENGINE_PROFILE']
    end

    extend self

end

end
end

module Engine
    module UI
        Output = SCNR::UI::CLI::Output
    end
end
end

module Cuboid
    module UI
        Output = SCNR::UI::CLI::Output
    end
end

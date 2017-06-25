=begin
    Copyright 2020 Tasos Laskos <tasos.laskos@gmail.com>

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine'

module SCNR
module UI::CLI

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class SystemInfo
    include Output

    def run
        print_line UI::CLI::BANNER
        print_line

        system_info
        print_line
        slot_info
    end

    def system_info
        print_status "Ruby:     #{RUBY_VERSION} p#{RUBY_PATCHLEVEL}"
        print_status "Platform: #{RUBY_PLATFORM}"
    end

    def slot_info
        system = SCNR::Engine::System
        slots  = system.slots

        print_status 'Available slots in:'
        print_line

        show_hint = false
        if (s = slots.available_in_memory) > 0
            print_ok "RAM:   #{s}"
        else
            print_bad "RAM:   #{s}"
            show_hint = true
        end
        print_info "  Required: #{bytes_to_gb( slots.memory_size )} GB"
        print_info "  Free:     #{bytes_to_gb( system.memory_free )} GB"

        if show_hint
            ps         = options.browser_cluster.pool_size
            valid_size = 0

            ps.downto(0).each do |size|
                options.browser_cluster.pool_size = size
                next if slots.available_in_memory == 0

                valid_size = size
                break
            end

            if valid_size > 0
                print_info "  Hint:     Try: --browser-cluster-pool-size=#{valid_size}"
            end
        end

        show_hint = false
        if (s = slots.available_in_disk) > 0
            print_ok "Disk:  #{s}"
        else
            print_bad "Disk:  #{s}"
            show_hint = true
        end
        print_info "  Location: #{system.disk_directory}"
        print_info "  Required: #{bytes_to_gb( slots.disk_space )} GB"
        print_info "  Free:     #{bytes_to_gb( system.disk_space_free )} GB"

        if show_hint
            print_info "  Hint:     Try changing the 'tmpdir' location in: #{options.paths.class.paths_config_file}"
        end
    end

    def options
        SCNR::Engine::Options
    end

    private

    def bytes_to_gb( bytes )
        (Float( bytes ) / 1024 / 1024 / 1024).round(2)
    end

end
end
end

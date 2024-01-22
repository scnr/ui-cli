# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )
require 'scnr/ui/cli/version'

Gem::Specification.new do |s|
    s.name          = 'scnr-ui-cli'
    s.version       = SCNR::UI::CLI::VERSION
    s.authors       = ['Tasos Laskos']
    s.email         = ['tasos.laskos@ecsypno.com']

    s.summary       = %q{Command line interface for SCNR::Engine.}
    s.homepage      = 'http://ecsypno.com'

    # Disable pushes to public servers.
    if s.respond_to?(:metadata)
        s.metadata['allowed_push_host'] = 'http://localhost/'
    else
        raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
    end

    s.files        += Dir.glob( 'lib/**/**' )
    s.test_files    = Dir.glob( 'spec/**/**' )

    s.executables   = Dir.glob( 'bin/*' ).map { |e| File.basename e }
    s.require_paths = ['lib']

    # For the Engine console (scnr_engine_console).
    s.add_dependency 'rb-readline',    '0.5.1'

    # Outputting data in table format (scnr_engine_rpcd_monitor).
    s.add_dependency 'terminal-table', '1.4.5'

    s.add_dependency 'scnr-application', '0.1'
end

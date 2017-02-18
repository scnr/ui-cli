desc 'Remove reporter and log files.'
task :clean do
    files = %w(error.log *.afr *.afs *.yaml *.json *.marshal *.gem pkg/*.gem
        snapshots/*.afs logs/*.log spec/support/logs/*.log).map { |file| Dir.glob( file ) }.flatten

    next if files.empty?

    puts 'Removing:'
    files.each { |file| puts "  * #{file}" }
    FileUtils.rm files
end

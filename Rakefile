desc 'Remove reporter and log files.'
task :clean do
    files = %w(*.error.log error.log *.ser *.ses *.yaml *.json *.marshal *.gem pkg/*.gem
        snapshots/*.afs logs/*.log).map { |file| Dir.glob( file ) }.flatten

    next if files.empty?

    puts 'Removing:'
    files.each { |file| puts "  * #{file}" }
    FileUtils.rm files
end

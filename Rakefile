desc 'Remove reporter and log files.'
task :clean do
    files = %w(*.error.log error.log *.ser *.ses *.yaml *.json *.marshal *.gem pkg/*.gem
        snapshots/*.afs logs/*.log).map { |file| Dir.glob( file ) }.flatten

    next if files.empty?

    puts 'Removing:'
    files.each { |file| puts "  * #{file}" }
    FileUtils.rm files
end

namespace :processes  do
    list = 'ps -o pgid,ppid,pid,pcpu,rss,cmd -f | numfmt --header --field 5 --padding 7 | cut -c 1-250'

    task :list do
        puts `#{list}`
    end

    task :kill do
        puts `killall -9 ruby; killall geckodriver; killall chromedriver; killall chrome`
    end
end

#!/usr/bin/env ruby

require 'open3'

log_files = {}

#automatic or manual modes
if(ARGV[0] == "-a")
    #open file of inputs & save all lines to dictionary
    File.open(ARGV[1], "r") do |file|
        lines = file.readlines
        lines.each do |line|
            split = line.chomp.split(' ')
            log_files[split[0]] = split[1]
        end 
    end
else
    log_files[ARGV[0]] = ARGV[0]
end
puts "#{log_files}"

log_files.each do |input, dir|
    if(File.exist?(input))
        #generate simplified log file
        file_name = File.basename(input, ".log")
        output_file = "#{dir}#{file_name}flow.txt"
        puts "#{output_file}"
        File.write(
            output_file,
            File.foreach(input)
                .grep(/\[SM (Entering|Exiting)\]/)
                .map { _1.sub(/^.*?(?=\[SM)/, "") }
                .join
        )

        #generage dot file
        stdout, stderr, status = 
            Open3.capture3("ruby logflow.rb #{dir}#{file_name}flow.txt #{dir}#{file_name}.dot")
        if (status.exitstatus != 0)
            puts "ERROR: dot file #{dir}#{file_name}.dot could not be constructed"
            return
        end    

        #generate svg file
        stdout, stderr, status = 
            Open3.capture3("dot #{dir}#{file_name}.dot -Tsvg > #{dir}#{file_name}.svg")
        if (status.exitstatus != 0)
            puts "ERROR: dot file #{dir}#{file_name}.svg could not be constructed"
        end

    else
        puts "ERROR: Log file does not exist: #{input}"
    end    

end
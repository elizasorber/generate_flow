#!/usr/bin/env ruby

require 'optparse'
require 'open3'
require_relative 'logflow'
require 'pathname'

#Using optparse for command line arguments
LOG_FILES = {}
Options = Struct.new(:mode, :input, :output)
class Parser
  def self.parse(options)
    args = Options.new(:manual, nil, nil)

    opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: generate_flow [options] input output"

        opts.on("-a FILE", "--automatic FILE", "Automatic mode: ./generate_flow -a log_inputs.txt") do |logs|
            args.mode = :automatic
            args.input = logs
            File.readlines(logs).each do |line|
                split = line.chomp.split(' ')
                dirname = split[1]
                dirname = Pathname.new(dirname).cleanpath.to_s
                dirname << "/"
                LOG_FILES[split[0]] = dirname
            end
        end

        opts.on("-m", "--manual", "Manual mode: ./generate_flow inputlogfile.log results_dir/") do
            args.mode = :manual
        end

        opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
        end
    end

    opt_parser.parse!(options)
    #default to manual mode
    if (args.mode == :manual && args.input.nil?)
        args.input  = options[0]
        dirname = options[1]
        dirname = Pathname.new(dirname).cleanpath.to_s
        dirname << "/"
        args.output = dirname
        LOG_FILES[args.input] = dirname
    end
    return args
  end
end



Parser.parse(ARGV)
log_files = LOG_FILES
#debug !! remove !!
puts "#{log_files}"

log_files.each do |input, dir|
    if(File.exist?(input))
        #generate simplified log file
        file_name = File.basename(input, ".log")
        output_file = "#{dir}#{file_name}flow.txt"
        #DEBUG !! REMOVE !!
        puts "generated : #{output_file}"
        File.write(
            output_file,
            File.foreach(input)
                .grep(/\[SM (Entering|Exiting)\]/)
                .map { _1.sub(/^.*?(?=\[SM)/, "") }
                .join
        )

        #generate dot file
        puts "generating dot file..."
        status = logflow("#{dir}#{file_name}flow.txt", "#{dir}#{file_name}.dot")
        if (status != 0)
            puts "ERROR: dot file #{dir}#{file_name}.dot could not be constructed"
            return
        end    

        puts "generating svg... "
        #generate svg file
        pipe_string = "dot #{dir}#{file_name}.dot -Tsvg > #{dir}#{file_name}.svg"
        #puts dir
        #puts file_name
        #input_name = "client/client.dot"
        #output_name = "client/client.svg"
        #pipe_string = "dot #{input_name} -Tsvg > #{output_name}"
        #pipe_string = "dot server0/server0.dot -Tsvg > server0/server0.svg"
        #pipe_string = "dot server1/server1.dot -Tsvg > server1/server1.svg"
        #pipe_string = "dot server2/server2.dot -Tsvg > server2/server2.svg"
        puts pipe_string
        stdout, stderr, status = Open3.capture3(pipe_string)
        if (status.exitstatus != 0)
            puts "ERROR: flow chart #{dir}#{file_name}.svg could not be constructed"
        end 
        puts stdout
        puts stderr
        #stdout, stderr, status = Open3.capture3("dot client/client.dot -Tsvg > test.svg")
        #stdout, stderr, status = Open3.capture3("dot server0/server0.dot -Tsvg > test.svg")

        
        
    else
        puts "ERROR: Log file does not exist: #{input}"
    end    

end
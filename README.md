# generate_flow
This repository contains scripts to generate flow charts for PVFS log files using dot. 

INSTALLATION INSTRUCTIONS:
graphviz:
https://graphviz.org/download/

ruby:
!! FIXME !! insert instructions on installing ruby on the remote instance once you figure out how to

HOW TO USE:
generate_flow.rb:
    This is a ruby script that will take in a PVFS log file and generate a flow chart for that log file. It is an executable ruby script, so user must run chmod before being able to run in the following way. There are two different modes to run the script as follows:
        manual (default) - ./generate_flow.rb inputlogfile.log results_dir/
        automatic (-a) - ./generate_flow.rb log_inputs.txt

    Manual mode takes in one log file and creates the simplified log file (a log file that only contains the Entering & Exiting sm lines), a dot file for the state machine flow, and the svg file of the completed flow chart and places them in the results directory. The simplified log file will always be named <inputfilename>flow.txt. The dot file will be named <inputfilename>.dot and the svg will be named <inputfilename>.svg. 

    Automatic mode takes in a text file that is formated like the following:

    inputfile.log results_dir/
    /home/eliza/tdir-nexteliza/client.log client/
    /home/eliza/tdir-nexteliza/storage0/server.log server0/
    /home/eliza/tdir-nexteliza/storage1/server.log server1/
    /home/eliza/tdir-nexteliza/storage2/server.log server2/
    
    and does the same thing as manual for every entry in the text file. This exists for cases where the user wants to create flow charts for multiple log files at once. 

logflow.rb:
    This is a ruby script that takes in a simplified log file and generates a dot file for that log file. This script is called by generate_flow.rb, but can be run manually:
        ruby logflow.rb results_dir/inputfilenameflow.txt results_dir/inputfilename.dot

    This file is where the bulk of the program logic occurs. Occasionally, an PVFS log file is too complex and has too much looping for dot to construct a graph for it. There should be an error message handled in generate_flow.rb, but if logflow.rb is run alone, no error handling is done. 

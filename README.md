# generate_flow

This repository contains scripts to generate flow charts for PVFS log files using Graphviz (`dot`).

## Overview

The main script, `generate_flow`, parses PVFS log files and produces:

- a simplified log file
- a Graphviz `.dot` file
- an SVG flow chart

This can be run for:

- a single log file (**Manual mode**)
- multiple log files at once (**Automatic mode**)

---

## Installation Instructions

### Graphviz

Install Graphviz:

https://graphviz.org/download/

Verify installation:

```bash
dot -V
```

### Ruby

Install Ruby:

https://www.ruby-lang.org/en/documentation/installation/

Verify installation:

```bash
ruby -v
```

## Usage Instructions
1. clone git repo -
	```bash
    git clone \<repo-url\>
    cd \<repo-name\>
    ```
3. make script executable -
    ```bash
	chmod +x generate_flow
    ```
4. basic usage -
    ```bash
	./generate_flow [options] [args]
    ```


### generate_flow:
This is a ruby script that will take in a PVFS log file and generate a flow chart for that log file. It is an executable ruby script, so user must run chmod before being able to run in the following way. There are two different modes to run the script as follows:

manual (-m) (default) - `./generate_flow inputlogfile.log results_dir/`
`./generate_flow -m inputlogfile.log results_dir`
automatic (-a) - `./generate_flow -a log_inputs.txt`

  
Manual mode takes in one log file and creates the simplified log file (a log file that only contains the Entering & Exiting sm lines), a dot file for the state machine flow, and the svg file of the completed flow chart and places them in the results directory. The simplified log file will always be named <inputfilename>flow.txt. The dot file will be named <inputfilename>.dot and the svg will be named <inputfilename>.svg.

  
Generated files for `./generate_flow logs/client.log client/`:
-  clientflow.txt # simplified log
-  client.dot # Graphviz source
-  client.svg # generated flow chart

  
Automatic mode takes in a text file that is formated like the following:
	
	/home/eliza/tdir-nexteliza/client.log client/
	/home/eliza/tdir-nexteliza/storage0/server.log server0/
	/home/eliza/tdir-nexteliza/storage1/server.log server1/
	/home/eliza/tdir-nexteliza/storage2/server.log server2/

and does the same thing as manual for every entry in the text file. This exists for cases where the user wants to create flow charts for multiple log files at once.

  
generate_flow uses a ruby logger that creates a file called generate_flow.log. Debug statements, warnings, and errors are logged in this file.


### logflow.rb:

This is a ruby script that takes in a simplified log file and generates a dot file for that log file. This script is called by generate_flow.rb.

This file is where the bulk of the program logic occurs. Occasionally, an PVFS log file is too complex and has too much looping for dot to construct a flow chart for it. There should be an error message handled in generate_flow.rb.

## Troubleshooting:

	dot: command not found
Graphviz is not installed or not in PATH.

	ruby: command not found
Ruby is not installed or not in PATH.


> Written with [StackEdit](https://stackedit.io/).
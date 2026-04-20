#parses line in simplified log file
def parse_line(line)
    parsed = {}
    split_spaces = line.chomp.split(' ')
    split_state = split_spaces[3].split(':')
    parsed[:action] = split_spaces[1]
    parsed[:sm] = split_state[0]
    parsed[:state] = split_state[1]
    return parsed
end

#takes in a simplified log file and writes corresponding dot file
def logflow (input_file, output_file)
    #set up data structures
    state_machines = {}
    edges = []
    states = {}

    File.open(input_file, "r") do |file|
        #handle first line
        parsed = parse_line(file.readline)
        edge_index = 1
        state_machines[parsed[:sm]] = [parsed[:state]]
        states[parsed[:state]] = [parsed[:sm]]
        edges.push({:head => "start", :tail =>parsed[:state], :cross_boundary => true, :label => edge_index})
        prev_line = parsed

        #read the rest 
        lines = file.readlines
        lines.each do |line|
            cur_line = parse_line(line)
            cross_boundary = false
            #add state to sm or create new sm entry
            if state_machines.has_key?(cur_line[:sm])
                state_machines[cur_line[:sm]].push(cur_line[:state])
            else
                state_machines[cur_line[:sm]] = [cur_line[:state]]
            end
            #check if it is an edge, then if it crosses boundary
            if !(prev_line[:action] == "Entering]" && cur_line[:action] == "Exiting]")
                edge_index = edge_index + 1 
                #store states for duplicates 
                if(states.has_key?(cur_line[:state]))
                    if(!states[cur_line[:state]].include?(cur_line[:sm]))
                        states[cur_line[:state]].push(cur_line[:sm])
                    end
                else
                    states[cur_line[:state]] = [cur_line[:sm]]
                end
                #check for sm jump
                if(prev_line[:sm] != cur_line[:sm])
                    cross_boundary = true
                end
                #Get duplicate name for head node
                head_state_name = prev_line[:state]
                if(states.has_key?(prev_line[:state]))
                    index = states[prev_line[:state]].index(prev_line[:sm])
                    if(index != 0)
                        head_state_name = "\"#{prev_line[:state]}(#{index})\""
                    end
                end
                #get duplicate name for tail node
                tail_state_name = cur_line[:state]
                if(states.has_key?(cur_line[:state]))
                    index = states[cur_line[:state]].index(cur_line[:sm])
                    if(index != 0)
                        tail_state_name = "\"#{cur_line[:state]}(#{index})\""
                    end
                end
                #push edge
                edges.push({:head=> head_state_name, :tail => tail_state_name, :cross_boundary => cross_boundary, :label => edge_index})
            end
            prev_line = cur_line
        end
    end

    #open output file
    output = File.open(output_file, "w")
    output.write("digraph {\n")
    output.write("\tcompound = true\n")

    #iterate and print all subgraphs & nodes
    state_machines.each_key do |key|
        updated_state_names = state_machines[key]
        output.write("\tsubgraph cluster_#{key}{\n")
        output.write("\t\tlabel = \"#{key}\"\n")
        #check for duplicates, print correct name
        state_machines[key].each do |state|
            index = states[state].index(key)
            if(index != 0)
                updated_state_names = updated_state_names.map { |x| x == state ? "\"#{state}(#{index})\"" : x }
            end
        end
        joined_states = updated_state_names.uniq.join(";")
        output.write("\t\t#{joined_states}\n")
        output.write("\t}\n")
    end    
    output.write("\n")

    #iterate and print all edges
    grouped = edges.group_by { |e| [e[:head], e[:tail]] }

    cross_boundary = false
    grouped.each do |(head, tail), group|
        #consolidate duplicate edges
        label = []
        group.each do |edge| 
            label.push edge[:label]
            cross_boundary = edge[:cross_boundary]
        end
    
        #print edge
        output.write("\t#{head} -> #{tail}")

        #find consecutive labels & print
        cons_labels = label.chunk_while { |prev, curr| curr == prev + 1 }
        final_label = cons_labels.map {|cons| cons.length < 3 ? cons : "#{cons.first}-#{cons.last}" }
        label_full = final_label.join(";")
        output.write(" [label = \"#{label_full}\"]")

        #update color if sm jump
        if(cross_boundary == true)
            output.write(" [color = \"red\"]")
        end
        output.write("\n")
    end

    output.write("}")
    return 0
end
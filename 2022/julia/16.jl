using Combinatorics, DataStructures, BenchmarkTools

mutable struct ValveGraph
    v::Array{Int8}  # list of vertices
    e  # list of vertices for each vertex implying an edge
    dist::Matrix{Int8}  # distance along each edge
    flow_rate::Array{Int8} # flow rate for each vertex
end

function construct_graph()
    # first loop through and convert labels into integers
    label_to_ind = Dict()
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            label_to_ind[line[7:8]] = i
            i += 1
        end
    end

    # next create a large graph with every valve and tunnel connection
    n = length(label_to_ind)
    g = ValveGraph(range(1, n), [Set{Int8}() for i in 1:n], zeros(Int8, n, n), zeros(Int8, n))
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            g.flow_rate[i] = parse(Int, match(r"(?<=\=)\d+(?=;)", line).match)
            connections = match(r"(?<=(\bvalve \b)|(\bvalves )\b)[A-Z, ]*", line).match
            for connection in split(connections, ", ")
                push!(g.e[i], label_to_ind[connection])
                g.dist[i, label_to_ind[connection]] = 1
            end
            i += 1
        end
    end

    # now we can reduce this graph by deleting edges for broken valves and re-weighting the distances
    delete_these = []
    for i in 1:n
        if g.flow_rate[i] == 0 && label_to_ind["AA"] !== i
            push!(delete_these, i)
            for pair in combinations(collect(g.e[i]), 2)
                push!(g.e[pair[1]], pair[2])
                push!(g.e[pair[2]], pair[1])
                g.dist[pair[1], pair[2]] = g.dist[pair[1], i] + g.dist[pair[2], i]
                g.dist[pair[2], pair[1]] = g.dist[pair[1], pair[2]]
                
                delete!(g.e[i], pair[1])
                delete!(g.e[i], pair[2])
                delete!(g.e[pair[1]], i)
                delete!(g.e[pair[2]], i)
                g.dist[i, pair[1]] = 0
                g.dist[i, pair[2]] = 0
                g.dist[pair[1], i] = 0
                g.dist[pair[2], i] = 0
            end
        end
    end

    # this still leaves you with a big graph, so now convert to a smaller one (our case is 15 nodes + start)
    n = sum(g.flow_rate .> 0) + 1

    # create a convertor from old inds to new ones
    start_ind = label_to_ind["AA"]
    convertor = Dict(start_ind => 1)
    old_inds = findall(x->x>0, g.flow_rate)
    for i in 2:n
        convertor[old_inds[i - 1]] = i
    end

    # start a new smaller graph
    small_g = ValveGraph(range(1, n), [Set{Int8}() for i in 1:n], zeros(Int8, n, n), zeros(Int8, n))
    new_start_ind = Int8(-1)

    # transfer over the old graph
    i = Int8(1)
    for v in g.v
        if g.flow_rate[v] > 0 || v == start_ind
            small_g.flow_rate[i] = g.flow_rate[v]
            small_g.e[i] = Set([convertor[x] for x in g.e[v]])
            for e in g.e[v]
                small_g.dist[i, convertor[e]] = g.dist[v, e]
            end

            if v == start_ind
                new_start_ind = i
            end
            i += 1
        end
    end

    return small_g, new_start_ind
end

function part_one(g::ValveGraph, start_ind::Int8)
    """This performs an interactive cached search of the graph, searching for best order in which to open
    valves and pre-calculates how much pressure to release"""

    # start off an initial visited bool array
    initial_visited = falses(length(g.v))
    initial_visited[start_ind] = true

    # start a queue of volcano states
    volcano_states = [(30, start_ind, 0, initial_visited)]

    # keep a tracker on the pressure released by each state (this is the cache)
    state_tracker = DefaultDict(-1)
    maximum_pressure = 0

    # iterate over the queue
    while length(volcano_states) > 0
        # pop off the top of the queue
        time_left, location, pressure, visited = pop!(volcano_states)

        # if we've been here before and it wasn't as good then skip it
        if state_tracker[(time_left, location, visited)] >= pressure
            continue
        # otherwise update the state tracker with this pressure
        else
            state_tracker[(time_left, location, visited)] = pressure
        end

        # if this state has run out of time then (potentially) update the maximum pressure and move on
        if time_left < 0
            maximum_pressure = max(maximum_pressure, pressure)
            continue
        end

        # first option: open the valve!
        if !visited[location]
            new_visited = copy(visited)
            new_visited[location] = true
            push!(volcano_states, (time_left - 1, location,
                                   pressure + ((time_left - 1) * g.flow_rate[location]),
                                   new_visited))
        end

        # otherwise, try moving to each valve in the vicinity (adjust time by distance)
        for connection in collect(g.e[location])
            push!(volcano_states, (time_left - g.dist[location, connection], connection,
                                   pressure, visited))
        end
    end
    return maximum_pressure
end

function part_two(g::ValveGraph, start_ind::Int8)
    initial_visited = falses(length(g.v))
    initial_visited[start_ind] = true

    volcano_states = [(26, start_ind, start_ind, 0, copy(initial_visited))]
    state_tracker = DefaultDict(-1)

    maximum_pressure = 0

    while length(volcano_states) > 0
        time_left, location, elephant, pressure, visited = pop!(volcano_states)
        
        if state_tracker[(time_left, location, elephant, visited)] >= pressure
            continue
        end
        state_tracker[(time_left, location, elephant, visited)] = pressure

        if time_left < 0 || all(visited .== true)
            maximum_pressure = max(maximum_pressure, pressure)
            continue
        end

        if !visited[location]
            visited[location] = true
            push!(volcano_states, (time_left - 1, location,
                                   pressure + ((time_left - 1) * g.flow_rate[location]),
                                   copy(visited)))

            if !visited[elephant]
                visited[elephant] = true
                push!(volcano_states, (time_left - 1, location, elephant,
                                       pressure + ((time_left - 1) * g.flow_rate[location]) + ((time_left - 1) * g.flow_rate[elephant]),
                                       copy(visited)))
                visited[location] = false
            end

            for connection in collect(g.e[location])
                push!(volcano_states, (time_left - g.dist[location, connection], connection,
                                       pressure + ((time_left - 1) * g.flow_rate[location]), copy(visited)))
            end

            visited[location] = false
        end

        for connection in collect(g.e[location])
            push!(volcano_states, (time_left - g.dist[location, connection], connection,
                                   pressure, copy(visited)))
        end
    end
    return maximum_pressure
end


function main()
    g, start_ind = construct_graph()
    println("PART ONE: ", part_one(g, Int8(start_ind)))
    # println("PART TWO: ", part_two(g, Int8(start_ind)))
end

main()
using Combinatorics, DataStructures

mutable struct ValveGraph
    v::Array{Int8}  # list of vertices
    e  # list of vertices for each vertex implying an edge
    dist::Matrix{Int8}  # distance along each edge
    flow_rate::Array{Int8} # flow rate for each vertex
end

function construct_graph(unweighted)
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

    start_ind = label_to_ind["AA"]
    if unweighted
        return g, start_ind
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

    # start off an initial opened bool array
    initial_opened = falses(length(g.v))
    initial_opened[start_ind] = 1

    # start a queue of volcano states
    volcano_states = [(30, start_ind, 0, initial_opened)]

    # keep a tracker on the pressure released by each state (this is the cache)
    state_tracker = DefaultDict(-1)
    maximum_pressure = 0

    # iterate over the queue
    while length(volcano_states) > 0
        # pop off the top of the queue
        time_left, location, pressure, opened = pop!(volcano_states)

        # if we've been here before and it wasn't as good then skip it
        if state_tracker[(time_left, location, opened)] >= pressure
            continue
        # otherwise update the state tracker with this pressure
        else
            state_tracker[(time_left, location, opened)] = pressure
        end

        # SHORTCUT! Magic numbers here, but if this state is looking "bad" then drop it
        if time_left < 20 && pressure < maximum_pressure ÷ 2
            continue
        end

        # if this state has run out of time then (potentially) update the maximum pressure and move on
        if time_left <= 0
            maximum_pressure = max(maximum_pressure, pressure)
            continue
        end

        # first option: open the valve!
        if !opened[location] && g.flow_rate[location] > 0
            new_opened = copy(opened)
            new_opened[location] = 1
            push!(volcano_states, (time_left - 1, location,
                                   pressure + ((time_left - 1) * g.flow_rate[location]),
                                   new_opened))
        end

        # otherwise, try moving to each valve in the vicinity (adjust time by distance)
        for connection in collect(g.e[location])
            push!(volcano_states, (time_left - g.dist[location, connection], connection,
                                   pressure, opened))
        end
    end
    return maximum_pressure
end

function part_two(g::ValveGraph, start_ind::Int8)
    """Now this performs an interactive cached search of the graph, searching for best order in which to open
    valves when you've got two people/elephants moving and pre-calculates how much pressure to release"""

    # start off an initial opened bool array
    initial_opened = falses(length(g.v))
    initial_opened[start_ind] = 1

    # start a queue of volcano states
    volcano_states = [(26, start_ind, start_ind, 0, initial_opened)]

    # keep a tracker on the pressure released by each state (this is the cache)
    state_tracker = DefaultDict(-1)
    maximum_pressure = 0
    best_opened = nothing

    # iterate over the queue
    while length(volcano_states) > 0
        # pop off the top of the queue
        time_left, you, elephant, pressure, opened = pop!(volcano_states)

        # if we've been here before and it wasn't as good then skip it
        if state_tracker[(time_left, you, elephant, opened)] >= pressure
            continue
        # otherwise update the state tracker with this pressure
        else
            state_tracker[(time_left, you, elephant, opened)] = pressure
        end

        # if this state has run out of time then (potentially) update the maximum pressure and move on
        if time_left <= 0 || all((opened .== true) .| (g.flow_rate .== 0))
            if pressure > maximum_pressure
                maximum_pressure = pressure
                best_opened = opened
            end
            continue
        end

        # SHORTCUT! Magic numbers here, but if this state is looking "bad" then drop it
        if time_left < 22 && pressure < maximum_pressure ÷ 2
            continue
        end

        # first option: you open the valve!
        if !opened[you] && g.flow_rate[you] > 0
            you_opened = copy(opened)
            you_opened[you] = 1

            # elephant also opens the valve
            if !you_opened[elephant] && g.flow_rate[elephant] > 0
                both_opened = copy(you_opened)
                both_opened[elephant] = 1
                push!(volcano_states, (time_left - 1, you, elephant, 
                                       pressure + ((time_left - 1) * g.flow_rate[you]) + ((time_left - 1) * g.flow_rate[elephant]),
                                       both_opened))
            end

            # OR elephant moves to a neighbour
            for connection in collect(g.e[elephant])
                push!(volcano_states, (time_left - 1, you, connection,
                                       pressure + ((time_left - 1) * g.flow_rate[you]), you_opened))

            end
        end

        # otherwise, try moving to each valve in the vicinity (adjust time by distance)
        for connection in collect(g.e[you])

            # while the elephant opens its node
            if !opened[elephant] && g.flow_rate[elephant] > 0
                el_opened = copy(opened)
                el_opened[elephant] = 1
                push!(volcano_states, (time_left - 1, connection, elephant, 
                                       pressure + ((time_left - 1) * g.flow_rate[elephant]),
                                       el_opened))
            end

            # OR the elephant also moves to its neighbour
            for el_connection in collect(g.e[elephant])
                push!(volcano_states, (time_left - 1, connection, el_connection, pressure, opened))
            end
        end
    end
    return maximum_pressure
end

function main()
    g, start_ind = construct_graph(true)
    println("PART ONE: ", part_one(g, Int8(start_ind)))
    
    g, start_ind = construct_graph(true)
    @time x = part_two(g, Int8(start_ind))
    println("PART TWO: ", x)
end

main()
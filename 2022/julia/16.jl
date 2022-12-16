using Combinatorics, Memoize, DataStructures

mutable struct ValveGraph
    v::Array{Int64}  # list of vertices
    e  # list of vertices for each vertex implying an edge
    dist::Matrix{Int64}  # distance along each edge
    flow_rate::Array{Int64} # flow rate for each vertex
    # visited::Array{Bool}  # whether this valve has been visited
end

function construct_graph()
    label_to_ind = Dict()
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            label_to_ind[line[7:8]] = i
            i += 1
        end
    end

    n = length(label_to_ind)
    g = ValveGraph(range(1, n), [Set() for i in 1:n], zeros(Int64, n, n), zeros(Int64, n))
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

    deleteat!(g.v, delete_these)
    return label_to_ind, g
end


@memoize function timed_dfs(g, valve, time_left, visited)
    if time_left <= 0
        return 0
    end

    pressure_released = 0
    for connection in collect(g.e[valve])
        @show connection
        pressure_released = max(pressure_released, timed_dfs(g, connection,
                                                             time_left - g.dist[valve, connection],
                                                             visited))
    end
    if !visited[valve]
        visited[valve] = true
        pressure_released = max(pressure_released, timed_dfs(g, valve, time_left - 1, visited) + g.flow_rate[valve] * (time_left - 1))
    end
    return pressure_released
end

function iterative_timed_dfs(g, label_to_ind)
    initial_visited = falses(length(label_to_ind))
    initial_visited[label_to_ind["AA"]] = true

    volcano_states = [(30, label_to_ind["AA"], 0, copy(initial_visited))]
    state_tracker = DefaultDict(-1)

    maximum_pressure = 0

    while length(volcano_states) > 0
        time_left, location, pressure, visited = pop!(volcano_states)
        # @show time_left, location, pressure, visited
        
        if state_tracker[(time_left, location)] >= pressure
            continue
        end
        state_tracker[(time_left, location)] = pressure

        if time_left < 0
            maximum_pressure = max(maximum_pressure, pressure)
            continue
        end

        if !visited[location]
            visited[location] = true
            push!(volcano_states, (time_left - 1, location,
                                   pressure + ((time_left - 1) * g.flow_rate[location]),
                                   copy(visited)))
            visited[location] = false
        end

        for connection in collect(g.e[location])
            # @show g.dist[location, connection]
            push!(volcano_states, (time_left - g.dist[location, connection], connection,
                                   pressure, copy(visited)))
        end
    end
    return maximum_pressure
end


function part_one()
    label_to_ind, g = construct_graph()
    @show label_to_ind, g
    return iterative_timed_dfs(g, label_to_ind)

    return nothing
end

function part_two()
    return nothing
end

println("PART ONE: ", part_one())
@time part_one()
# println("PART TWO: ", part_two())
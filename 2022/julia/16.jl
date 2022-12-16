using Combinatorics

mutable struct ValveGraph
    v::Array{Int64}  # list of vertices
    e  # list of vertices for each vertex implying an edge
    dist::Matrix{Int64}  # distance along each edge
    flow_rate::Array{Int64} # flow rate for each vertex
    visited::Array{Bool}  # whether this valve has been visited
end

function construct_graph()
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            label_to_ind[line[7:8]] = i
            i += 1
        end
    end
    
end


function part_one()
    label_to_ind = Dict()
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            label_to_ind[line[7:8]] = i
            i += 1
        end
    end

    n = length(label_to_ind)
    g = ValveGraph(range(1, n), [Set() for i in 1:n], zeros(Int64, n, n), zeros(Int64, n), falses(n))
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            g.flow_rate[i] = parse(Int, match(r"(?<=\=)\d+(?=;)", line).match)
            connections = match(r"(?<=(\bvalve \b)|(\bvalves )\b)[A-Z, ]*", line).match
            for connection in split(connections, ", ")
                push!(g.e[i], label_to_ind[connection])
                push!(g.e[label_to_ind[connection]], i)
                g.dist[i, label_to_ind[connection]] = 1
                g.dist[label_to_ind[connection], i] = 1
            end
            i += 1
        end
    end

    @show g

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

    @show g

    # time_left = 30
    # curr_valve = label_to_ind["AA"]
    # total_pressure = 0

    # distances = floyd_warshall_shortest_paths(g)
    # @show distances.dists[1, :]

    # while time_left > 0
    #     distances = dijkstra_shortest_paths(g, curr_valve).dists
    #     @show distances
    #     break
    #     time_left_on_arrival = time_left .- distances .- 1
    #     pressure_released = flow_rates .* time_left_on_arrival
    #     # @show distances

    #     # @show distances, time_left_on_arrival, pressure_released
    #     time_left -= 1
    # end

    return nothing
end

function part_two()
    return nothing
end

println("PART ONE: ", part_one())
# println("PART TWO: ", part_two())
using Graphs

# mutable struct ValveGraph
#     v::Array{Int64}
#     e::Matrix{Int64}
#     w::Array{Int64}
#     flow_rate::Array{Int64}
    
# end

# function construct_graph


function part_one()
    label_to_ind = Dict()
    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            label_to_ind[line[7:8]] = i
            i += 1
        end
    end
    g = SimpleWeightedGraph(length(label_to_ind))
    flow_rates = zeros(Int64, length(label_to_ind))

    open("../inputs/16.txt", "r") do input
        i = 1
        for line in eachline(input)
            flow_rates[i] = parse(Int, match(r"(?<=\=)\d+(?=;)", line).match)
            connections = match(r"(?<=(\bvalve \b)|(\bvalves )\b)[A-Z, ]*", line).match
            for connection in split(connections, ", ")
                add_edge!(g, i, label_to_ind[connection])
            end
            i += 1
        end
    end

    @show edges(g)

    time_left = 30
    curr_valve = label_to_ind["AA"]
    total_pressure = 0

    distances = floyd_warshall_shortest_paths(g)
    @show distances.dists[1, :]

    while time_left > 0
        distances = dijkstra_shortest_paths(g, curr_valve).dists
        @show distances
        break
        time_left_on_arrival = time_left .- distances .- 1
        pressure_released = flow_rates .* time_left_on_arrival
        # @show distances

        # @show distances, time_left_on_arrival, pressure_released
        time_left -= 1
    end

    return nothing
end

function part_two()
    return nothing
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
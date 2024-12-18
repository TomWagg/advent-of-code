using DataStructures

const example = true
const BIG_DIST = 1000000
const ROW_COL_MAX = example ? 7 : 71
const FILE = example ? "inputs/18.example.txt" : "inputs/18.txt"
const P1_LIM = example ? 12 : 1024

function construct_graph(bytes::Vector{Vector{Int}}, dim::Int)
    # construct a dictionary of every potential edge between nodes
    edges = DefaultDict{Vector{Int}, Vector{Vector{Int}}}(Vector{Vector{Int}})

    # loop over all positions & directions
    for row in 1:dim
        for col in 1:dim
            # check every direction from this node
            for (dr, dc) in zip([-1, 0, 1, 0], [0, 1, 0, -1])
                in_bounds = row + dr > 0 && row + dr <= dim && col + dc > 0 && col + dc <= dim
                if [row, col] ∉ bytes && [row + dr, col + dc] ∉ bytes && in_bounds
                    push!(edges[[row, col]], [row + dr, col + dc])
                end
            end
        end
    end
    return edges
end

function dijkstra(edges::DefaultDict{Vector{Int}, Vector{Vector{Int}}},
                  start::Vector{Int}, finish::Vector{Int}, dim::Int)
    """Dijkstra's algorithm basically"""
    # track the current best guess of a minimum distance to each unvisited node
    unvisited_dists = PriorityQueue{Vector{Int}, Int}()
    [enqueue!(unvisited_dists, [x, y], BIG_DIST) for x in 1:dim for y in 1:dim]
    unvisited_dists[start] = 0

    # store the final distances
    distances = Dict()

    # loop until there are no unvisited nodes
    while length(unvisited_dists) > 0
        # grab the next closest node
        node, dist = peek(unvisited_dists)
        delete!(unvisited_dists, node)
        distances[node] = dist

        # once we a node is unreachable or we hit the finish we're done
        if dist == BIG_DIST || node == finish
            break
        end

        # check each neighbour of the node
        for neighbour in edges[node]
            # if we've not visited it yet
            if haskey(unvisited_dists, neighbour)
                # if we've found a shorter path change its distance estimate
                if unvisited_dists[neighbour] > dist + 1
                    unvisited_dists[neighbour] = dist + 1
                end
            end
        end
    end
    return distances
end

function main()
    # get the grid, construct edges, identify the start and end node
    bytes = [parse.(Int, split(line, ",")) .+ 1 for line in eachline(FILE)]
    edges = construct_graph(bytes[1:P1_LIM], ROW_COL_MAX)
    start = [1, 1]
    finish = [ROW_COL_MAX, ROW_COL_MAX]

    # find the distances to each node and their parents
    distances = dijkstra(edges, start, finish, ROW_COL_MAX)
    p1 = distances[finish]

    i = 0
    while finish ∈ keys(distances) && distances[finish] < BIG_DIST
        # remove edges of this byte
        byte_to_remove = bytes[P1_LIM + i]
        for node in edges[byte_to_remove]
            deleteat!(edges[node], findfirst(x->x==byte_to_remove, edges[node]))
        end
        delete!(edges, byte_to_remove)

        # edges = construct_graph(bytes[1:P1_LIM + i], ROW_COL_MAX)
        distances = dijkstra(edges, start, finish, ROW_COL_MAX)
        i += 1
    end
    # save the last byte that got removed, subtract 1 because I offset them for Julia brain
    p2 = bytes[i + P1_LIM - 1] .- 1
    return p1, p2
end

println("BOTH PARTS: ", main())
@time main()
using DataStructures

function get_grid()
    grid = mapreduce(permutedims, vcat, split.(split(read("../inputs/23.txt", String), '\n'), ""))
    padded_grid = fill("#", (size(grid, 1) + 2, size(grid, 1) + 2))
    padded_grid[2:end-1, 2:end-1] .= grid
    return padded_grid
end

function construct_graph(grid::Matrix{String}, ignore_steep_slopes=false)
    # construct a dictionary of every potential edge between nodes
    edges = DefaultDict(Vector)

    # loop over all positions, directions and number of steps taken
    for row in 2:size(grid, 1) - 1
        for col in 2:size(grid, 2) - 1
            # check every direction from this node
            for (dr, dc, not_this) in zip([-1, 1, 0, 0], [0, 0, -1, 1], ["v", "^", ">", "<"])
                # skip over anything going from # or to #, and if not ignoring steep slopes, don't go up them
                if (grid[row, col] != "#" && grid[row + dr, col + dc] != "#"
                    && (ignore_steep_slopes || grid[row, col] != not_this))
                    push!(edges[(row, col)], (row + dr, col + dc))
                end
            end
        end
    end
    return edges
end

function prune_graph(edges, weights)
    success = true
    for (key, val) in edges
        if length(val) == 2
            new_weight = weights[val[1], key] + weights[key, val[2]]
            push!(edges[val[1]], val[2])
            push!(edges[val[2]], val[1])
            weights[val[1], val[2]] = new_weight
            weights[val[2], val[1]] = new_weight
            filter!(e->e!=key, edges[val[1]])
            filter!(e->e!=key, edges[val[2]])
            delete!(edges, key)
            success = false
        end
    end
    return success ? (edges, weights) : prune_graph(edges, weights)
end

function DFS(current::Tuple{Int, Int}, edges::DefaultDict,
             weights::DefaultDict, path::Set, path_length::Int,
             endpoint::Tuple{Int, Int}, longest_path::Int)
    if current == endpoint
        return max(longest_path, path_length)
    end

    for edge in edges[current]
        if edge ∉ path
            push!(path, edge)
            longest_path = DFS(edge, edges, weights, path,
                               path_length + weights[current, edge],
                               endpoint, longest_path)
            delete!(path, edge)
        end
    end
    return longest_path
end

grid = get_grid()
edges, weights = prune_graph(construct_graph(grid), DefaultDict(1))
endpoint = (size(grid, 1) - 1, size(grid, 2) - 2)
println("PART ONE: ", DFS((2, 3), edges, weights, Set(), 0, endpoint, 0))

edges, weights = prune_graph(construct_graph(grid, true), DefaultDict(1))
println("PART TWO: ", DFS((2, 3), edges, weights, Set(), 0, endpoint, 0))
@time DFS((2, 3), edges, weights, Set(), 0, endpoint, 0)

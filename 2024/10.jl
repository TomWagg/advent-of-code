using DataStructures

function get_grid()
    # read in the grid
    grid = parse.(Int, replace(mapreduce(permutedims, vcat, split.(split(read("inputs/10.txt", String), '\n'), "")), "."=>"-1"))
    # create a padded grid with -1s so I don't have to check bounds later
    padded_grid = fill(-1, (size(grid, 1) + 2, size(grid, 1) + 2))
    padded_grid[2:end-1, 2:end-1] .= grid
    return grid, padded_grid
end

function construct_graph(grid::Matrix{Int})
    # construct a dictionary of every potential edge between nodes
    edges = DefaultDict{CartesianIndex{2}, Vector{CartesianIndex{2}}}(Vector{CartesianIndex{2}})

    # loop over all positions & directions
    for row in 2:size(grid, 1) - 1
        for col in 2:size(grid, 2) - 1
            # check every direction from this node
            for (dr, dc) in zip([-1, 1, 0, 0], [0, 0, -1, 1])
                # ignore -1s, only construct an edge if the difference in height is exactly 1
                if (grid[row, col] != -1 && grid[row + dr, col + dc] - grid[row, col] == 1)
                    # offset indices by -1 to get rid of padding
                    push!(edges[CartesianIndex(row - 1, col - 1)], CartesianIndex(row - 1 + dr, col - 1 + dc))
                end
            end
        end
    end
    return edges
end

function all_paths_from_trailhead(grid::Matrix{Int},
                                  edges::DefaultDict{CartesianIndex{2}, Vector{CartesianIndex{2}}},
                                  trailhead::CartesianIndex{2})
    # set of reachable 9s and total number of routes
    reachable, total = Set{CartesianIndex{2}}(), 0
    total = 0
    stack = [trailhead]
    visited = falses(size(grid))
    while length(stack) > 0
        node = pop!(stack)
        visited[node] = true
        # if we've reached an end, track it!
        if grid[node] == 9
            push!(reachable, node)
            total += 1
        end
        # keep walking along the path
        for edge in edges[node]
            push!(stack, edge)
        end
    end
    return length(reachable), total
end

function sol()
    grid, padded_grid = get_grid()
    edges = construct_graph(padded_grid)

    score, rating = 0, 0
    for trailhead in findall(x->x==0, grid)
        nines, paths = all_paths_from_trailhead(grid, edges, trailhead)
        score += nines
        rating += paths
    end

    return score, rating
end

function main()
    println("BOTH PARTS: ", sol())
    @time sol()
end

main()
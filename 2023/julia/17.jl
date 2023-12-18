using DataStructures
const dir_to_string = Dict(1 => "right", 2 => "down", 3 => "left", 4 => "up")
const string_to_dir = Dict(value => key for (key, value) in dir_to_string)

function construct_graph(grid::Matrix{Int}, min_straight::Int, max_straight::Int)
    # construct a huge dictionary of every potential edge between nodes
    # where each node is (row, col, direction approached, number of steps taken in this direction)
    edges = DefaultDict{Tuple{Int, Int, Int, Int}, Vector{Tuple{Int, Int, Int, Int}}}(Vector{Tuple{Int, Int, Int, Int}})

    # create a priority queue of the distances to the unvisited nodes: this is essential for runtime purposes
    unvisited_distances = PriorityQueue{Tuple{Int, Int, Int, Int}, Int}()

    # loop over all positions, directions and number of steps taken
    for row in axes(grid, 1)
        for col in axes(grid, 2)
            for dir in keys(dir_to_string)
                for n_straight in 1:max_straight
                    # add this node to the queue
                    unvisited_distances[(row, col, dir, n_straight)] = typemax(Int)

                    # loop over the four potential new directions
                    # only add new edges if (a) within bounds (b) not going backwards (c) number of steps in
                    # same direction is within the bounds specified
                    for (in_bounds, new_dir, backwards, dr, dc) in zip([row > 1, row < size(grid, 1),
                                                                        col > 1, col < size(grid, 2)],
                                                                       ["up", "down", "left", "right"],
                                                                       ["down", "up", "right", "left"],
                                                                       [-1, 1, 0, 0],
                                                                       [0, 0, -1, 1])
                        if in_bounds
                            # moving the same direction
                            if dir_to_string[dir] == new_dir
                                # not gone too far in a straight line
                                if n_straight < max_straight
                                    push!(edges[(row, col, dir, n_straight)], (row + dr, col + dc, dir,
                                                                               n_straight + 1))
                                end
                            # don't go backwards (or turn too early for ultra crucibles)
                            elseif dir_to_string[dir] != backwards && n_straight >= min_straight
                                push!(edges[(row, col, dir, n_straight)], (row + dr, col + dc,
                                                                           string_to_dir[new_dir], 1))
                            end
                        end
                    end
                end
            end
        end
    end
    # add some extra edges for the initial corner with has n_straight = 0
    append!(edges[(1, 1, string_to_dir["right"], 0)], [(1, 2, string_to_dir["right"], 1),
                                                       (2, 1, string_to_dir["down"], 1)])
    return edges, unvisited_distances
end

function shortest_crucible_path(grid::Matrix{Int}, min_straight::Int, max_straight::Int)
    # get the edges and priority queue of distances
    edges, unvisited_distances = construct_graph(grid, min_straight, max_straight)

    # also track the distances to every point and whether you've visited
    distances = DefaultDict{Tuple{Int, Int, Int, Int}, Int}(typemax(Int))

    current = (1, 1, string_to_dir["right"], 0)
    distances[current] = 0

    # define the potential endpoints of the path
    # i.e. any point in the lower right corner, with dir=down/right and n_straight in valid range
    endpoints = Set()
    for dir in ["down", "right"]
        for n_straight in max(1, min_straight):max_straight
            push!(endpoints, (size(grid, 1), size(grid, 2), string_to_dir[dir], n_straight))
        end
    end
    # create a copy for tracking how many have been found
    endpoint_tracker = copy(endpoints)

    # loop until you've hit every endpoint
    while length(endpoint_tracker) > 0
        # check every edge of the current node
        for edge in edges[current]
            # if the node is unvisited
            if edge ∈ keys(unvisited_distances)
                # update distances if it's lower than the current
                distances[edge] = min(distances[edge], distances[current] + grid[edge[1], edge[2]])
                unvisited_distances[edge] = distances[edge]
            end
        end

        # done visiting this node, grab the next closest unvisited node
        current = dequeue!(unvisited_distances)
        delete!(endpoint_tracker, current)
    end

    return minimum(distances[key] for key in endpoints)
end

grid = mapreduce(x->parse.(Int, permutedims(x)), vcat, split.(split(read("../inputs/17.txt", String), '\n'), ""))
println("PART ONE: ", shortest_crucible_path(grid, 0, 3))
@time shortest_crucible_path(grid, 0, 3)                    # ~0.6s
println("PART TWO: ", shortest_crucible_path(grid, 4, 10))
@time shortest_crucible_path(grid, 4, 10)                   # ~2.5s
using DataStructures

const BIG_DIST = 1000000

function get_grid()
    # read in the grid
    grid = mapreduce(permutedims, vcat, collect.(split(read("inputs/16.txt", String), '\n')))
    return grid
end

function construct_graph(grid::Matrix{Char})
    # construct a dictionary of every potential edge between nodes
    edges = DefaultDict{Tuple{Int, Int, Int}, Vector{Tuple{Int, Int, Int, Int}}}(Vector)

    # loop over all positions & directions
    for row in 1:size(grid, 1)
        for col in 1:size(grid, 2)
            # add edges for rotations 90 degrees either way
            for d in 1:4
                push!(edges[(row, col, d)], (row, col, d - 1 < 1 ? 4 : d - 1, 1000))
                push!(edges[(row, col, d)], (row, col, d + 1 > 4 ? 1 : d + 1, 1000))
            end
            # check every direction from this node
            for (dr, dc, d) in zip([-1, 0, 1, 0], [0, 1, 0, -1], [1, 2, 3, 4])
                # ignore -1s, only construct an edge if the difference in height is exactly 1
                if (grid[row, col] != '#' && grid[row + dr, col + dc] != '#')
                    # offset indices by -1 to get rid of padding
                    push!(edges[(row, col, d)], (row + dr, col + dc, d, 1))
                end
            end
        end
    end
    return edges
end

function get_distances_and_parents(grid::Matrix{Char},
                                   edges::DefaultDict{Tuple{Int, Int, Int}, Vector{Tuple{Int, Int, Int, Int}}},
                                   start::CartesianIndex{2})
    """Dijkstra's algorithm with parent storage for shortest paths"""
    # track the current best guess of a minimum distance to each unvisited node
    unvisited_dists = PriorityQueue{Tuple{Int, Int, Int}, Int}()
    [enqueue!(unvisited_dists, (x, y, d), BIG_DIST) for x in axes(grid, 1) for y in axes(grid, 2) for d in 1:4]
    unvisited_dists[(start[1], start[2], 2)] = 0

    # store the final distances and parents of each node
    distances = Dict()
    parents = Dict((start[1], start[2], 2) => [])

    # loop until there are no unvisited nodes
    while length(unvisited_dists) > 0
        # grab the next closest node
        node, dist = peek(unvisited_dists)
        delete!(unvisited_dists, node)
        distances[node] = dist

        # once we a node is unreachable we're done
        if dist == BIG_DIST
            break
        end

        # check each neighbour of the node
        for e in edges[node]
            neighbour, weight = (e[1], e[2], e[3]), e[4]
            # if we've not visited it yet
            if haskey(unvisited_dists, neighbour)
                # if we've found a shorter path
                if unvisited_dists[neighbour] > dist + weight
                    # change its distance estimate and reset its parents
                    unvisited_dists[neighbour] = dist + weight
                    parents[neighbour] = [node]
                # if we've found an equally short path then add to its parents
                elseif unvisited_dists[neighbour] == dist + weight
                    push!(parents[neighbour], node)
                end
            end
        end
    end
    return distances, parents
end

function main()
    # get the grid, construct edges, identify the start and end node
    grid = get_grid()
    edges = construct_graph(grid)
    start = findfirst(grid .== 'S')
    finish = findfirst(grid .== 'E')

    # find the distances to each node and their parents
    distances, parents = get_distances_and_parents(grid, edges, start)

    # get the distance to the end node for each direction
    end_dists = [distances[(finish[1], finish[2], d)] for d in 1:4]
    min_dist = minimum(end_dists)

    # track which nodes are touched along the shortest paths
    shortest_path_nodes = Set{Tuple{Int, Int}}([(finish[1], finish[2])])
    for d in 1:4
        # if the direction to the end node is a minimum then search along the parents
        if end_dists[d] == min_dist
            stack = [parents[(finish[1], finish[2], d)]...]
            while length(stack) > 0
                node = pop!(stack)
                push!(shortest_path_nodes, (node[1], node[2]))
                for parent in parents[node]
                    push!(stack, parent)
                end
            end
        end
    end
    return min_dist, length(shortest_path_nodes)
end

println("BOTH PARTS: ", main())
@time main()
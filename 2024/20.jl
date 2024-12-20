using DataStructures
const BIG_DIST = 1000000

# find all neighbours within a manhattan distance r of (x, y) and their distance
const manhattan_neighbours(x::Int, y::Int, r::Int) = ((CartesianIndex(x + dx, y + dy), abs(dx) + abs(dy)) for dx in -r:r for dy in -(r - abs(dx)):(r - abs(dx)))

# check whether a coordinate (x, y) is in bounds for the grid
const in_bounds(xy, dims) = xy[1] > 0 && xy[1] <= dims[1] && xy[2] > 0 && xy[2] <= dims[2]

function dijkstra(grid::Matrix{Char}, start::CartesianIndex{2}, finish::CartesianIndex{2})
    """Dijkstra algorithm to get the distances and parents"""
    # track the current best guess of a minimum distance to each unvisited node
    unvisited_dists = PriorityQueue{CartesianIndex{2}, Int}()
    [enqueue!(unvisited_dists, CartesianIndex(x, y), BIG_DIST) for x in axes(grid, 1) for y in axes(grid, 2)]
    unvisited_dists[start] = 0

    parents = Dict(CartesianIndex(start[1], start[2]) => [])
    distances = zeros(Int, size(grid))

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
        for offset in [CartesianIndex(-1, 0), CartesianIndex(1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1)]
            neighbour = node + offset
            if (in_bounds(neighbour, size(grid)) && grid[node] != '#' && grid[neighbour] != '#' && neighbour ∈ keys(unvisited_dists))
                if unvisited_dists[neighbour] > dist + 1
                    unvisited_dists[neighbour] = dist + 1
                    parents[neighbour] = [node]
                else
                    unvisited_dists[neighbour] == dist + 1
                    push!(parents[neighbour], node)
                end
            end
        end
    end
    return distances, parents
end

function retrace_shortest_path(parents::Dict, finish::CartesianIndex{2})
    """Retrace your steps for the shortest path from the parents dict"""
    shortest_path_nodes = [finish]
    stack = [parents[finish]...]
    while length(stack) > 0
        node = pop!(stack)
        push!(shortest_path_nodes, node)
        for parent in parents[node]
            push!(stack, parent)
        end
    end
    return shortest_path_nodes
end

function n_unique_cheats(cheat_starts::Vector{CartesianIndex{2}}, distances::Matrix{Int}, max_cheat_length::Int)
    """Find the number of unique cheats from a list of starts up to a given length"""
    cheats = Set([])
    for cheat_start in cheat_starts
        # find every possible cheat jump position from this location
        for (cheat_end, cheat_length) in manhattan_neighbours(cheat_start[1], cheat_start[2], max_cheat_length)
            # if it's in bounds and saves more than 100 picoseconds we have a cheat
            if in_bounds(cheat_end, size(distances)) && distances[cheat_end] - (distances[cheat_start] + cheat_length) >= 100
                push!(cheats, (cheat_start, cheat_end))
            end
        end
    end
    # return count of unique cheats
    return length(cheats)
end

function sol()
    grid = mapreduce(permutedims, vcat, collect.(split(read("inputs/20.txt", String), '\n')))
    finish = findfirst(grid .== 'E')
    distances, parents = dijkstra(grid, findfirst(grid .== 'S'), finish)
    shortest_path = retrace_shortest_path(parents, finish)
    return n_unique_cheats(shortest_path, distances, 2), n_unique_cheats(shortest_path, distances, 20)
end

function main()
    println("BOTH PARTS: ", sol())
    @time sol()
end

main()
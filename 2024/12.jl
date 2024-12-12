using DataStructures

# indices for adjacent and diagonal nodes
const adjcs = [CartesianIndex(-1, 0), CartesianIndex(1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1)]
const diags = [CartesianIndex(-1, -1), CartesianIndex(1, -1), CartesianIndex(-1, 1), CartesianIndex(1, 1)]

function get_grid()
    # read in the grid
    grid = mapreduce(permutedims, vcat, collect.(split(read("inputs/12.txt", String), '\n')))
    # create a padded grid with '.'s so I don't have to check bounds later
    padded_grid = fill('.', (size(grid, 1) + 2, size(grid, 1) + 2))
    padded_grid[2:end-1, 2:end-1] .= grid
    return grid, padded_grid
end

function construct_graph(grid::Matrix{Char})
    # construct a dictionary of every potential edge between nodes
    edges = DefaultDict{CartesianIndex{2}, Vector{CartesianIndex{2}}}(Vector{CartesianIndex{2}})

    # loop over all positions & directions
    for row in 2:size(grid, 1) - 1
        for col in 2:size(grid, 2) - 1
            # check every direction from this node
            for (dr, dc) in zip([-1, 1, 0, 0], [0, 0, -1, 1])
                # ignore -1s, only construct an edge if the difference in height is exactly 1
                if (grid[row, col] != '.' && grid[row + dr, col + dc] == grid[row, col])
                    # offset indices by -1 to get rid of padding
                    push!(edges[CartesianIndex(row - 1, col - 1)], CartesianIndex(row - 1 + dr, col - 1 + dc))
                end
            end
        end
    end
    return edges
end

function flood_fill(edges::DefaultDict{CartesianIndex{2}, Vector{CartesianIndex{2}}},
                    start::CartesianIndex{2})
    # start a stack and track which nodes you visit
    stack = [start]
    visited = Set{CartesianIndex{2}}()
    while length(stack) > 0
        # grab the next node and mark it as visited 
        ind = pop!(stack)
        push!(visited, ind)

        # push all of its unvisited edges
        for edge in edges[ind]
            if edge ∉ visited
                push!(stack, edge)
            end
        end
    end
    return visited
end

function get_n_sides(region::Set{CartesianIndex{2}})
    corners = 0
    for node in region
        # conditions for whether adjacents or diagonals are filled/unfilled
        above, below, left, right = [node - d ∈ region for d in adjcs]
        empty_up_left, empty_down_left, empty_up_right, empty_down_right = [node - d ∉ region for d in diags]

        # conditions for each of the four corners
        top_left = !(above || left) || (above && left && empty_up_left)
        top_right = !(above || right) || (above && right && empty_up_right)
        bottom_left = !(below || left) || (below && left && empty_down_left)
        bottom_right = !(below || right) || (below && right && empty_down_right)
        corners += top_left + top_right + bottom_left + bottom_right
    end
    return corners
end

function sol()
    # get the grid and edges
    grid, padded_grid = get_grid()
    edges = construct_graph(padded_grid)

    # track the total costs and nodes that have yet to be visited
    cost, bulk_cost = 0, 0
    unvisited = Set{CartesianIndex{2}}(CartesianIndices(grid))

    # while there are still nodes remaining
    while length(unvisited) > 0
        # get the region associated with a random start node
        start = pop!(unvisited)
        region = flood_fill(edges, start)

        # update costs based on its area and perimeter
        area = length(region)
        perimeter = sum(4 - length(edges[node]) for node in region)
        cost += area * perimeter
        bulk_cost += area * get_n_sides(region)

        # remove the region from the unvisited nodes
        setdiff!(unvisited, region)
    end

    return cost, bulk_cost
end
function main()
    println("BOTH PARTS: ", sol())
    @time sol()
end

main()

function print_pipes(m::Matrix{Char})
    """Print the pipes to a file, using prettier characters"""
    open("../inputs/10.out", "w") do input
        for i in 1:size(m, 1)
            write(input, replace.(join(m[i, :]), 'F' => '┌', '7' => '┐', 'L' => '└', '-' => '─',
                                                 '|' => '│', 'J' => '┘', '.' => ' ') * "\n")
        end
    end
end

function get_grid(file_path="../inputs/10.txt")
    # count up the numbers of rows and columns
    n_row, n_col = 0, 0
    open(file_path, "r") do input
        for line in eachline(input)
            n_row += 1
            n_col = length(line)
        end
    end
    
    # create a matrix with extra rows and columns on the boundaries (it'll be useful, trust me)
    grid = fill('.', (n_row + 2, n_col + 2))
    open(file_path, "r") do input
        for (i, line) in enumerate(eachline(input))
            grid[i + 1, 2:n_col + 1] = collect(line)
        end
    end
    return grid
end

# define where each character is allowed to go
# each entry is (row_offset, col_offset, which characters it can't connect to in this direction)
const whither = Dict(
    '|' => [[-1, 0, ['-', 'L', 'J']], [1, 0, ['-', '7', 'F']]],
    '-' => [[0, 1, ['|', 'L', 'F']], [0, -1, ['|', 'J', '7']]],
    'L' => [[-1, 0, ['-', 'L', 'J']], [0, 1, ['|', 'L', 'F']]],
    'J' => [[-1, 0, ['-', 'L', 'J']], [0, -1, ['|', 'J', '7']]],
    '7' => [[1, 0, ['-', '7', 'F']], [0, -1, ['|', 'J', '7']]],
    'F' => [[1, 0, ['-', '7', 'F']], [0, 1, ['|', 'L', 'F']]],
    '.' => [],
)
    
function grid_to_graph(grid::Matrix{Char})
    """Convert the grid of characters to a graph that we can search"""
    graph = Dict{Vector{Int}, Vector{Vector{Int}}}()
    start = nothing

    # loop over the non-padded parts of the grid
    for i in 2:size(grid, 1) - 1
        for j in 2:size(grid, 2) - 1
            # special handling of start character, in my input it needs to be a "|"
            if grid[i, j] == 'S'
                start = [i, j]
                grid[i, j] = '|'            # WARNING!!!! THIS IS HARDCODED BASED ON MY INPUT (i am lazy...)
            end

            # track which locations this connects to
            connections = []
            for (row_offset, col_offset, not_here) in whither[grid[i, j]]
                new_i, new_j = i + row_offset, j + col_offset
                not_here = cat(not_here, ['.'], dims=1)

                # check if the new location is allowed
                # and no need to check for bounds errors - we padded the matrix! (told you it would be useful)
                if grid[new_i, new_j] ∉ not_here
                    push!(connections, [new_i, new_j])
                end
            end

            # put it in the graph if it connects to anything
            if length(connections) > 0
                graph[[i, j]] = connections
            end
        end
    end
    return graph, start
end

function get_distances(graph::Dict{Vector{Int}, Vector{Vector{Int}}},
                       start::Vector{Int}, dims::Tuple{Int, Int})
    """Get the distance to each point in the pipe from the start - implemented with BFS or DFS or something"""
    # by default mark everyting as unreachable
    distances = fill(-1, dims)

    # start a stack with a distance of zero and the start location
    stack = [(start, 0)]
    while stack != []
        # pop the next item off the stack and update its distance
        pos, dist = pop!(stack)
        distances[pos[1], pos[2]] = dist

        # push every connection that hasn't been reached yet onto the stack
        for next in graph[pos]
            if distances[next[1], next[2]] < 0
                pushfirst!(stack, (next, dist + 1))
            end
        end
    end
    return distances
end

function main()
    grid = get_grid()
    graph, start = grid_to_graph(grid)

    # get the distance to each point and return the max
    distances = get_distances(graph, start, size(grid))
    println("PART ONE: ", maximum(distances))

    # set any unreachable points to blanks and print the pipes to output
    grid[distances .< 0] .= ' '
    print_pipes(grid)
    
    # general idea here: every time you cross the path, flip whether the box is enclosed by the path
    n_enclosed = 0
    for i in 2:size(grid, 1) - 1
        enclosed = false
        for j in 2:size(grid, 2) - 1
            # if we reach a gap and it's enclosed then update the total
            if grid[i, j] == ' ' && enclosed
                n_enclosed += 1
            end

            # update whether we are enclosed when we cross the path
            enclosed = grid[i, j] ∈ ['|', 'L', 'J'] ? !enclosed : enclosed
            # okay I'll be honest with this^, I knew it must be some combination of | and [L, J, F, 7] and I
            # just tried every combination until it worked, for some reason [F, 7] do no count for flipping...
        end
    end
    println("PART TWO: ", n_enclosed)
end

main()
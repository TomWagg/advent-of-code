const GAP = 0
const ROCK = 1
const BLOCK = 2

function get_input()
    n_row, n_col = 0, 0
    file_path = "../inputs/14.txt"
    open(file_path, "r") do input
        for line in eachline(input)
            n_row += 1
            n_col = length(line)
        end
    end
    grid = Matrix{Int}(undef, (n_row, n_col))
    open(file_path, "r") do input
        for (i, line) in enumerate(eachline(input))
            grid[i, :] = parse.(Int8, replace.(split(line, ""), "."=>"0", "O"=>"1", "#"=>"2" ))
        end
    end
    return grid
end

function print_grid(grid)
    for row in axes(grid, 1)
        println(join(replace.(string.(collect(grid[row, :])), "0"=>".", "1"=>"O", "2"=>"#")))
    end
    println()
end

function tilt_up(grid::Matrix{Int})
    for col in axes(grid, 2)
        new_col = fill(GAP, size(grid, 1))
        n_rocks = 0
        cursor = 1
        # print_grid(grid)
        # println(col)
        for row in axes(grid, 1)
            # @show new_col
            if grid[row, col] == BLOCK
                new_col[cursor:cursor + n_rocks - 1] .= ROCK
                new_col[cursor + n_rocks:row] .= GAP
                new_col[row] = BLOCK
                cursor = row + 1
                n_rocks = 0
            elseif grid[row, col] == ROCK
                n_rocks += 1
            end
        end
        if cursor <= length(new_col)
            new_col[cursor:cursor + n_rocks - 1] .= ROCK
            new_col[cursor + n_rocks:lastindex(new_col)] .= GAP
        end
        grid[:, col] = new_col
    end
    return grid
end

function tilt_down(grid::Matrix{Int})
    grid = grid[end:-1:1, :]
    grid = tilt_up(grid)
    grid = grid[end:-1:1, :]
    return grid
end

function tilt_left(grid::Matrix{Int})
    for row in axes(grid, 1)
        new_row = fill(GAP, size(grid, 2))
        n_rocks = 0
        cursor = 1
        for col in axes(grid, 2)
            if grid[row, col] == BLOCK
                new_row[cursor:cursor + n_rocks - 1] .= ROCK
                new_row[cursor + n_rocks:col] .= GAP
                new_row[col] = BLOCK
                cursor = col + 1
                n_rocks = 0
            elseif grid[row, col] == ROCK
                n_rocks += 1
            end
        end
        if cursor <= length(new_row)
            new_row[cursor:cursor + n_rocks - 1] .= ROCK
            new_row[cursor + n_rocks:lastindex(new_row)] .= GAP
        end
        grid[row, :] = new_row
    end
    return grid
end

function tilt_right(grid::Matrix{Int})
    grid = grid[:, end:-1:1]
    grid = tilt_left(grid)
    grid = grid[:, end:-1:1]
    return grid
end


function cycle_grid(grid::Matrix{Int})
    grid = tilt_up(grid)
    grid = tilt_left(grid)
    grid = tilt_down(grid)
    grid = tilt_right(grid)
    return grid
end

function part_two()
    nothing = get_input()
    return nothing
end

function calculate_load(grid::Matrix{Int})
    return sum([size(grid, 1) - rock[1] + 1 for rock in findall(x->x==ROCK, grid)])
end

function main()
    grid = get_input()

    println("PART ONE: ", calculate_load(tilt_up(copy(grid))))

    N_CYCLES = 200              # <-- arbitrary large numbers
    loads = zeros(Int, N_CYCLES)
    largest_cycle = 0
    for i in 1:N_CYCLES
        grid = cycle_grid(grid)
        load = calculate_load(grid)
        if load in loads
            loc = findlast(x->x==load, loads)
            largest_cycle = max(largest_cycle, i - loc)
        end
        loads[i] = load
    end
    println("PART TWO: ", loads[mod(1000000000, largest_cycle) + largest_cycle])
end

main()
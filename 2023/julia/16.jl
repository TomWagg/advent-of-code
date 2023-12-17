using BenchmarkTools

function get_input()
    n_row, n_col = 0, 0
    file_path = "../inputs/16.txt"
    open(file_path, "r") do input
        for line in eachline(input)
            n_row += 1
            n_col = length(line)
        end
    end
    grid = Matrix{Char}(undef, (n_row, n_col))
    open(file_path, "r") do input
        for (i, line) in enumerate(eachline(input))
            grid[i, :] = only.(split(line, ""))
        end
    end
    return grid
end

function test_grid_energy(grid::Matrix{Char}, start=(1, 1, 0, 1))
    # track which grid points have been energised
    energised = falses(size(grid))

    # track which you've reached before *in the same direction* (avoid loops)
    touched = Set{Tuple{Int, Int, Int, Int}}()

    # keep looping until no more beams are left
    beams = [start]
    while length(beams) > 0
        i, j, di, dj = popfirst!(beams)

        # skip if we've gone past the edge of the grid, or if you've been here before
        if i > size(grid, 1) || i < 1 || j < 1 || j > size(grid, 2) || (i, j, di, dj) in touched
            continue
        end

        # energise this grid cell and track that we've been here
        energised[i, j] = true
        push!(touched, (i, j, di, dj))

        # keep going in the same direction
        if grid[i, j] == '.'
            push!(beams, (i + di, j + dj, di, dj))
        # reflect negatively
        elseif grid[i, j] == '/'
            push!(beams, (i - dj, j - di, -dj, -di))
        # reflect positively
        elseif grid[i, j] == '\\'
            push!(beams, (i + dj, j + di, dj, di))
        # duplicate vertically if approached from the side
        elseif grid[i, j] == '|'
            if dj == 0
                push!(beams, (i + di, j + dj, di, dj))
            else
                push!(beams, (i + 1, j, 1, 0))
                push!(beams, (i - 1, j, -1, 0))
            end
        # duplicate horizontally if approached from above/below
        elseif grid[i, j] == '-'
            if di == 0
                push!(beams, (i + di, j + dj, di, dj))
            else
                push!(beams, (i, j + 1, 0, 1))
                push!(beams, (i, j - 1, 0, -1))
            end
        end
    end
    # count up the energy and return
    return sum(energised)
end

function part_two(grid::Matrix{Char})
    """Try every possible entry point to the grid for the maximum energy"""
    best_energy = 0
    for i in axes(grid, 1)
        best_energy = max(best_energy, test_grid_energy(grid, (i, 1, 0, 1)))
        best_energy = max(best_energy, test_grid_energy(grid, (i, size(grid, 2), 0, -1)))
    end
    for j in axes(grid, 2)
        best_energy = max(best_energy, test_grid_energy(grid, (1, j, 1, 0)))
        best_energy = max(best_energy, test_grid_energy(grid, (size(grid, 1), j, -1, 0)))
    end
    return best_energy
end

grid = get_input()
println("PART ONE: ", test_grid_energy(grid))
@btime test_grid_energy(grid)                       # ~0.7ms

println("PART TWO: ", part_two(grid))
@btime part_two(grid)                               # ~240ms
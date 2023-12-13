# using BenchmarkTools

function get_input()
    n_rows = Vector{Int}(undef, 0)
    n_cols = Vector{Int}(undef, 0)
    open("../inputs/13.txt", "r") do input
        rows = 0
        cols = 0
        for line in eachline(input)
            if line != ""
                rows += 1
                cols = length(line)
            else
                push!(n_rows, rows)
                push!(n_cols, cols)
                rows = 0
            end
        end
        push!(n_rows, rows)
        push!(n_cols, cols)
    end

    grids = Vector{Matrix{Int}}(undef, 0)
    open("../inputs/13.txt", "r") do input
        i, j = 1, 1
        grid = fill(0, (n_rows[i], n_cols[i]))
        for line in eachline(input)
            if line != ""
                grid[j, :] = parse.(Int, collect(replace(line, '#'=>1, '.'=>0)))
                j += 1
            else
                push!(grids, grid)
                j = 1
                i += 1
                grid = fill(0, (n_rows[i], n_cols[i]))
            end
        end
        push!(grids, grid)
    end
    return grids
end

function check_vertical_reflection(grid::Matrix{Int}, col::Int, smudges=0::Int)
    offset = 0
    for offset in 0:min(col - 1, size(grid, 2) - col - 1)
        diffs = sum(grid[:, col - offset] .!= grid[:, col + 1 + offset])
        smudges -= diffs
        if diffs > smudges
            return false
        elseif diffs <= smudges
            smudges -= diffs
        end
    end
    return smudges == 0
end

function check_horizontal_reflection(grid::Matrix{Int}, row::Int, smudges=0::Int)
    offset = 0
    for offset in 0:min(row - 1, size(grid, 1) - row - 1)
        diffs = sum(grid[row - offset, :] .!= grid[row + 1 + offset, :])
        if diffs > smudges
            return false
        elseif diffs <= smudges
            smudges -= diffs
        end
    end
    return smudges == 0
end

function summarise_mirrors(grids::Vector{Matrix{Int}}, smudges=0)
    total = 0
    for grid in grids
        for col in 1:size(grid, 2) - 1
            if check_vertical_reflection(grid, col, smudges)
                total += col
                break
            end
        end
        for row in 1:size(grid, 1) - 1
            if check_horizontal_reflection(grid, row, smudges)
                total += 100 * row
                break
            end
        end
    end
    return total
end

function main()
    grids = get_input()
    println("PART ONE: ", summarise_mirrors(grids, 0))
    @time summarise_mirrors(grids, 0)                       # ~0.5ms
    println("PART TWO: ", summarise_mirrors(grids, 1))
    @time summarise_mirrors(grids, 1)                       # ~0.5ms
end

main()
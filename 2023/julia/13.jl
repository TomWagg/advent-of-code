# using DelimitedFiles
# using BenchmarkTools

function get_input()
    n_rows = []
    n_cols = []
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

    @show sum(n_rows .* n_cols)

    grids = []
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

function check_vertical_reflection(grid, col)
    offset = 0
    for offset in 0:min(col - 1, size(grid, 2) - col - 1)
        if !all(grid[:, col - offset] .== grid[:, col + 1 + offset])
            return false
        end
    end
    return true
end

function check_horizontal_reflection(grid, row)
    offset = 0
    for offset in 0:min(row - 1, size(grid, 1) - row - 1)
        if !all(grid[row - offset, :] .== grid[row + 1 + offset, :])
            return false
        end
    end
    return true
end

function part_one()
    grids = get_input()
    totals = []
    for grid in grids
        for col in 1:size(grid, 2) - 1
            if check_vertical_reflection(grid, col)
                push!(totals, col)
                break
            end
        end
        for row in 1:size(grid, 1) - 1
            if check_horizontal_reflection(grid, row)
                push!(totals, 100 * row)
                break
            end
        end
    end
    return grids, totals
end

function part_two(grids, totals)
    total = 0
    for (grid_id, grid) in enumerate(grids)
        found_the_smudge = false
        inds = [(i, j) for i in axes(grid, 1) for j in axes(grid, 2)]
        for (i, j) in inds
            if found_the_smudge
                break
            end
            grid[i, j] = 1 - grid[i, j]
            for row in 1:size(grid, 1) - 1
                if row * 100 != totals[grid_id] && check_horizontal_reflection(grid, row)
                    total += 100 * row
                    found_the_smudge = true
                    # @show grid, i, j, "hor", row
                    break
                end
            end
            if found_the_smudge
                break
            end
            for col in 1:size(grid, 2) - 1
                if col != totals[grid_id] && check_vertical_reflection(grid, col)
                    total += col
                    found_the_smudge = true
                    # @show grid, i, j, "vert", col
                    break
                end
            end
            grid[i, j] = 1 - grid[i, j]
        end
    end
    return total
end

function main()
    grids, totals = part_one()
    println("PART ONE: ", sum(totals))
    # @time part_one()
    println("PART TWO: ", part_two(grids, totals))
    # @time part_two()
end

main()
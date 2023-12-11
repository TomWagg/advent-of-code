function get_input()
    """Read the file of galaxies and space into a grid, using '1's for galaxies"""
    n_row, n_col = 0, 0
    file_path = "../inputs/11.txt"
    open(file_path, "r") do input
        for line in eachline(input)
            n_row += 1
            n_col = length(line)
        end
    end
    grid = Matrix{Int}(undef, (n_row, n_col))
    open(file_path, "r") do input
        for (i, line) in enumerate(eachline(input))
            grid[i, :] = parse.(Int, split(replace(line, '.'=>'0', '#'=>1), ""))
        end
    end
    return grid
end

function get_distances(galaxies::Vector{CartesianIndex{2}},
                       empty_rows::Vector{Int}, empty_cols::Vector{Int}, expansion=2::Int)
    """Get the total shortest distances between distinct pairs of galaxies"""
    total_distances = 0
    for i in eachindex(galaxies)
        for j in i + 1:length(galaxies)
            total_distances += get_shortest_distance(galaxies[i], galaxies[j],
                                                     empty_rows, empty_cols, expansion)
        end
    end
    return total_distances
end

function get_shortest_distance(loc_a::CartesianIndex, loc_b::CartesianIndex,
                               empty_rows::Vector{Int}, empty_cols::Vector{Int}, expansion=2::Int)
    """Calculate the shortest distance between a pair of galaxies (Manhattan), replacing any empty rows and
    columns with `expansion` replacements"""
    min_row, max_row = min(loc_a[1], loc_b[1]), max(loc_a[1], loc_b[1])
    min_col, max_col = min(loc_a[2], loc_b[2]), max(loc_a[2], loc_b[2])

    row_dist = max_row - min_row + length(empty_rows[min_row .< empty_rows .< max_row]) * (expansion - 1)
    col_dist = max_col - min_col + length(empty_cols[min_col .< empty_cols .< max_col]) * (expansion - 1)
    return row_dist + col_dist
end

function main()
    grid = get_input()
    empty_rows = filter(row->sum(grid[row, :]) == 0, axes(grid, 1))
    empty_cols = filter(col->sum(grid[:, col]) == 0, axes(grid, 2))

    galaxies = findall(x->x==1, grid)
    println("PART ONE: ", get_distances(galaxies, empty_rows, empty_cols, 2))
    println("PART TWO: ", get_distances(galaxies, empty_rows, empty_cols, 1000000))
end

main()
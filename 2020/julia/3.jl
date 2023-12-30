function count_trees(grid, right=3, down=1)
    row, col = 1, 1
    trees = 0
    while row < size(grid, 1)
        row += down
        col += right
        if col > size(grid, 2)
            col -= size(grid, 2)
        end
        trees += Int(grid[row, col] == "#")
    end
    return trees
end
grid = mapreduce(permutedims, vcat, split.(split(read("../inputs/3.txt", String), '\n'), ""))
results = [count_trees(grid, r, d) for (r, d) in [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]]
println("PART ONE: ", results[2])
println("PART TWO: ", prod(results))
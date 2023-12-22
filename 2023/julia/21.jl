using DataStructures

function get_grid(repeats=0)
    grid_lines = split.(split(read("../inputs/21.txt", String), '\n'), "")
    n_row, n_col = length(grid_lines), length(grid_lines[1])


    # grid = fill("#", (n_row * (2 * repeats + 1) + 2, n_col * (2 * repeats + 1) + 2))
    # grid[1, :] .= "#"
    # for (i, line) in enumerate(grid_lines)
    #     for j in 1:(2 * repeats + 1)
    #         grid[i + 1 + (j - 1) * n_row, :] = vcat(["#"], repeat(line, (2 * repeats + 1)), ["#"])
    #     end
    # end
    # grid[end, :] .= "#"

    grid = fill("#", (n_row * (2 * repeats + 1), n_col * (2 * repeats + 1)))
    for (i, line) in enumerate(grid_lines)
        for j in 1:(2 * repeats + 1)
            grid[i + (j - 1) * n_row, :] = repeat(line, (2 * repeats + 1))
        end
    end
    # write("mine.out", join([join(grid[i, :]) * "\n" for i in axes(grid, 1)]))

    return grid
end

function print_grid(grid)
    for row in axes(grid, 1)
        println(join(replace.(string.(collect(grid[row, :])), "0"=>".", "1"=>"O", "2"=>"#")))
    end
    println()
end

function get_edges(grid)
    edges = DefaultDict(Vector)
    for i in axes(grid, 1)
        for j in axes(grid, 2)
            if grid[i, j] == "#"
                continue
            end
    
            for neighbour in [[i - 1, j], [i + 1, j], [i, j - 1], [i, j + 1]]
                if 0 < neighbour[1] <= size(grid, 1) && 0 < neighbour[2] <= size(grid, 2) && grid[neighbour[1], neighbour[2]] == "."
                    push!(edges[[i, j]], neighbour)
                end
            end
        end
    end
    return edges
end

grid = get_grid(5)

starts = findall(grid .== "S")
start = length(starts) > 1 ? starts[length(starts) ÷ 2] : starts[1]
grid[start] = "."



function BFS(edges, start, step_max=64)
    distances = DefaultDict(0)
    visited = DefaultDict(false)

    stack = [start]
    distances[start] = 0
    visited[start] = true
    
    while length(stack) > 0
        pos = popfirst!(stack)
        for edge in edges[pos]
            if !visited[edge]
                visited[edge] = true
                distances[edge] = distances[pos] + 1
                push!(stack, edge)
                if distances[edge] > step_max
                    return distances
                end
            end
        end
    end
    return distances
end

function how_many_with_exactly(num, edges, start, op=.==)
    distances = BFS(edges, [start[1], start[2]], num)
    return sum(op(values(distances) .% 2, num % 2))
end

edges = get_edges(grid)

function f(n)
    a0 = how_many_with_exactly(65, edges, start)
    a1 = how_many_with_exactly(65 + 131, edges, start)
    a2 = how_many_with_exactly(65 + 131 * 2, edges, start)

    @show a0, a1, a2

    b0 = a0
    b1 = a1-a0
    b2 = a2-a1
    return b0 + b1*n + (n*(n-1) ÷ 2)*(b2-b1)
end
println(f(202300))


# @show how_many_grids
# @show basic_grid, flip_grid
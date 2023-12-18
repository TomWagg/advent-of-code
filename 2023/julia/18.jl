const int_to_offset = Dict('0'=>[0, 1], '1'=>[-1, 0], '2'=>[0, -1], '3'=>[1, 0])
const dir_to_offset = Dict("U"=>[1, 0], "D"=>[-1, 0], "L"=>[0, -1], "R"=>[0, 1])

shoelace(v) = sum(v[:, 1] .* circshift(v, -1)[:, 2] .- v[:, 2] .* circshift(v, -1)[:, 1]) ÷ 2
function lagoon_size(dirs, sizes)
    vertices = mapreduce(permutedims, vcat, accumulate(.+, pushfirst!(dirs .* sizes, [1, 1])))
    return sum(sizes) + shoelace(vertices) + 1 - sum(sizes) ÷ 2
end

split_input = split(read("../inputs/18.txt", String), '\n')
dirs, sizes = map(x->dir_to_offset[split(x)[1]], split_input), map(x->parse(Int, split(x)[2]), split_input)
println("PART ONE: ", lagoon_size(dirs, sizes))

colours = map(x->replace(split(x)[3], "("=>"", ")"=>""), split_input)
dirs, sizes = map(x->int_to_offset[x[7]], colours), map(x->parse(Int, x[2:6], base=16), colours)
println("PART TWO: ", lagoon_size(dirs, sizes))


















function flood_fill_failed_me(directions)
    """old solution to part one, they really got me with those colours"""
    min_x = typemax(Int)
    max_x = -typemax(Int)
    min_y = typemax(Int)
    max_y = -typemax(Int)

    pos = [1, 1]

    for (dir, step) in directions
        pos += dir_to_offset[dir] .* parse(Int, step)
        min_x = min(pos[1], min_x)
        max_x = max(pos[1], max_x)
        min_y = min(pos[2], min_y)
        max_y = max(pos[2], max_y)
    end
    grid = falses((max_x - min_x + 3, max_y - min_y + 3))
    lims = (min_x, max_x, min_y, max_y)

    pos = [1 - (lims[1] - 1) + 1, 1 - (lims[3] - 1) + 1]
    for (dir, step) in directions
        new_pos = pos + dir_to_offset[dir] .* parse(Int, step)
        grid[min(pos[1], new_pos[1]):max(pos[1], new_pos[1]),
             min(pos[2], new_pos[2]):max(pos[2], new_pos[2])] .= true
        pos = new_pos
    end

    touched = falses(size(grid))
    stack = [[1, 1]]
    while length(stack) > 0
        pos = pop!(stack)
        touched[pos[1], pos[2]] = true
        for offset in values(dir_to_offset)
            new_pos = pos .+ offset
            if new_pos[1] > 0 && new_pos[2] > 0 && new_pos[1] <= size(grid, 1) && new_pos[2] <= size(grid, 2) && !grid[new_pos[1], new_pos[2]] && !touched[new_pos[1], new_pos[2]]
                push!(stack, new_pos)
            end
        end
    end

    # print_grid(.!touched)
    return sum(.!touched)
end
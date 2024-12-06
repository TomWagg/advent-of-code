function get_input()
    lines = readlines("inputs/6.txt")
    block_map = falses(length(lines), length(lines[1]))
    dude = nothing
    for i in axes(lines, 1)
        chars = collect(lines[i])
        for j in eachindex(chars)
            if chars[j] == '#'
                block_map[i, j] = true
            elseif chars[j] == '^'
                dude = [i, j]
            end
        end
    end
    return block_map, dude
end

function part_one()
    block_map, dude = get_input()
    visited = falses(size(block_map))
    dir = [-1, 0]
    while true
        new_loc = dude .+ dir
        # if we just stepped out of bounds
        if new_loc[1] <= 0 || new_loc[1] > size(block_map, 1) || new_loc[2] <= 0 || new_loc[2] > size(block_map, 2)
            break
        elseif block_map[new_loc[1], new_loc[2]]
            # we just hit a block, 90 degree turn
            dir .= [dir[2], -dir[1]]
        else
            dude .= new_loc
            visited[new_loc[1], new_loc[2]] = true
        end
    end
    return sum(visited)
end

function creates_loop(block_map::BitMatrix, dude::Vector{Int})
    visited = falses(size(block_map))
    statemap = Set{Tuple{Int, Int, Int, Int}}()
    dir = [-1, 0]
    while true
        new_loc = dude .+ dir

        # check if we're already been in this location moving in this direction before
        if (new_loc[1], new_loc[2], dir[1], dir[2]) in statemap
            return true
        end
        # if we just stepped out of bounds
        if new_loc[1] <= 0 || new_loc[1] > size(block_map, 1) || new_loc[2] <= 0 || new_loc[2] > size(block_map, 2)
            return false
        elseif block_map[new_loc[1], new_loc[2]]
            # we just hit a block, 90 degree turn
            dir .= [dir[2], -dir[1]]
        else
            dude .= new_loc
            visited[new_loc[1], new_loc[2]] = true
            # save this location+direction in the set
            push!(statemap, (new_loc[1], new_loc[2], dir[1], dir[2]))
        end
    end
end

function part_two()
    block_map, dude = get_input()
    
    positions = 0
    for i in axes(block_map, 1)
        for j in axes(block_map, 2)
            if !block_map[i, j] && !(i == dude[1] && j == dude[2])
                new_map = copy(block_map)
                new_map[i, j] = true
                if creates_loop(new_map, copy(dude))
                    positions += 1
                end
            end
        end
    end
    return positions
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
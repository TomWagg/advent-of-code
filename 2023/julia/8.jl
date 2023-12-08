using BenchmarkTools

function get_input()
    directions = Array{String}(undef, 0)
    maps = Dict{String, String}()

    open("../inputs/8.txt", "r") do input
        for (i, line) in enumerate(eachline(input))
            if i == 1
                # save the directions
                directions = collect(line)
            elseif i > 2
                # save the map to a dictionary, with an entry for each direction
                split_line = split(line, " = ")
                split_ends = replace.(split(split_line[2], ", "), "(" => "", ")" => "")
                maps[split_line[1] * "L"] = split_ends[1]
                maps[split_line[1] * "R"] = split_ends[2]
            end
        end
    end
    return directions, maps
end

function part_one()
    directions, maps = get_input()

    # start at AAA and follow the directions until we reach ZZZ
    pos, steps, dir_cur = "AAA", 0, 1
    while pos != "ZZZ"
        # update the position and number of steps
        pos = maps[pos * directions[dir_cur]]
        steps += 1

        # change to next direction, wrapping as necessary
        dir_cur = dir_cur == length(directions) ? 1 : dir_cur + 1
    end
    return steps
end

function part_two()
    directions, maps = get_input()

    # find all the starting positions
    positions = Array{String}(undef, 0)
    for key in keys(maps)
        if key[3] == 'A' && key[1:3] ∉ positions
            push!(positions, key[1:3])
        end
    end

    # track the number of steps taken to first reach an end for every starting position
    steps, dir_cur = 0, 1
    t_first_end = zeros(Int, length(positions))

    # follow the directions until all starting positions have reached an end once
    while any(t_first_end .== 0)
        # shift every position and track if they reach an end
        for i in eachindex(positions)
            positions[i] = maps[positions[i] * directions[dir_cur]]
            if positions[i][3] == 'Z'
                t_first_end[i] = steps
            end
        end
        # change to next direction, wrapping as necessary
        dir_cur = dir_cur == length(directions) ? 1 : dir_cur + 1
        steps += 1
    end

    # offset by one to account for the start and take the lowest common multiple
    return lcm(t_first_end .+ 1)
end

function main()
    println("PART ONE: ", part_one())
    @btime part_one()
    println("PART TWO: ", part_two())
    @btime part_two()
end

main()
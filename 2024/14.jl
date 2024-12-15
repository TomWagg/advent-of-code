const regex = r"p\=(-*\d+),(-*\d+) v\=(-*\d+),(-*\d+)"

function get_input()
    lines = readlines("inputs/14.txt")
    return map(x->parse.(Int, match(regex, x).captures[[1, 2]]), lines), map(x->parse.(Int, match(regex, x).captures[[3, 4]]), lines)
end

function part_one()
    pos, vel = get_input()
    bounds = (101, 103)
    halfways = (bounds[1] ÷ 2, bounds[2] ÷ 2)
    quadrants = [0, 0, 0, 0]
    for (p, v) in zip(pos, vel)
        x = (p[1] + v[1] * 100) % bounds[1]
        y = (p[2] + v[2] * 100) % bounds[2]
        x = x < 0 ? bounds[1] + x : x
        y = y < 0 ? bounds[2] + y : y

        if x < halfways[1] && y < halfways[2]
            quadrants[1] += 1
        elseif x > halfways[1] && y < halfways[2]
            quadrants[2] += 1
        elseif x > halfways[1] && y > halfways[2]
            quadrants[3] += 1
        elseif x < halfways[1] && y > halfways[2]
            quadrants[4] += 1
        end
    end
    return prod(quadrants)
end

function display_robots(robots, bounds)
    for i in 0:bounds[2]
        line = ""
        for j in 0:bounds[1]
            line *= [j, i] ∈ robots ? "#" : "."
        end
        println(line)
    end
end

function is_tree_candidate(robots)
    # are there a lot of them in a contiguous col?
    sorted_robots = sort(robots)
    # @show sorted_robots

    current_row = -1
    current_col = -1

    longest_chain_start = nothing
    longest_chain = -1
    current_chain = -1

    for (x, y) in sorted_robots
        # @show x, y, current_row, current_chain
        # if we start a new row or jump a column then break the chain
        if x != current_col || (y > current_row + 1)
            if current_chain > longest_chain
                longest_chain_start = (current_col, current_row)
            end
            longest_chain = max(longest_chain, current_chain)
            current_chain = 1
            current_row = y
            current_col = x
        elseif (y == current_row + 1)
            current_row = y
            current_chain += 1
        end
    end
    return longest_chain > 10
end

function part_two()
    pos, vel = get_input()
    bounds = (101, 103)

    seconds = 0
    while seconds < 100000
        for i in eachindex(pos)
            for j in 1:2
                pos[i][j] = (pos[i][j] + vel[i][j]) % bounds[j]
                pos[i][j] = pos[i][j] < 0 ? bounds[j] + pos[i][j] : pos[i][j]
            end
        end
        seconds += 1

        if is_tree_candidate(pos)
            display_robots(pos, bounds)
            return seconds
            # println()
            # println()
            # sleep(10)
        end
    end
    return nothing
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
end

main()
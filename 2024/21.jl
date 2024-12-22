# setup keypads
const numeric_pad = ['7' '8' '9'; '4' '5' '6'; '1' '2' '3'; ' ' '0' 'A' ]
const directional_pad = [' ' '^' 'A'; '<' 'v' '>']
const num_start = findfirst(numeric_pad .== 'A')
const dir_start = findfirst(directional_pad .== 'A')
const dir_convert = Dict('>' => CartesianIndex(0, 1),
                         '<' => CartesianIndex(0, -1),
                         '^' => CartesianIndex(-1, 0),
                         'v' => CartesianIndex(1, 0))
const BASICALLY_INF = 1000000000000000
const manhattan_distance(a, b) = abs(a[1] - b[1]) + abs(a[2] - b[2])

function find_pad_path(pad::Matrix{Char},
                       pos::CartesianIndex{2},
                       remaining_code::Vector{Char},
                       path::Vector)
    """Find the path to trace around a pad to enter the `remaining_code` given you start at `pos`"""
    # return a wrapped path once the code is fully entered
    if length(remaining_code) == 0
        return [path]
    end

    # identify the target location
    target = findfirst(pad .== remaining_code[1])

    # once we're on the target then hit A and reduce the remaining code
    if pos == target
        return find_pad_path(pad, pos, remaining_code[2:end], [path..., 'A'])
    end

    # otherwise try moving in any of the four directions
    paths = []
    for dir ∈ keys(dir_convert)
        new_pos = pos + dir_convert[dir]
        # only move to something (a) in bounds, (b) that isn't a gap and (c) something that's closer to the goal
        if checkbounds(Bool, pad, new_pos) && pad[new_pos] != ' ' && manhattan_distance(new_pos, target) <= manhattan_distance(pos, target)
            append!(paths, find_pad_path(pad, new_pos, remaining_code, [path..., dir]))
        end
    end
    return paths
end

function min_button_presses(robot_level::Int,
                            buttons_to_press::Vector{Char},
                            cache = Dict())
    """Calculate the minimum number of presses needed to type `buttons_to_press` when `robot_level` levels
    removed from the main robot (results are `cache`d)"""

    # when it's me pressing buttons, I can do it directly, so it's just length
    if robot_level == 0
        return length(buttons_to_press)
    end

    # check the cache to save some time
    if (robot_level, buttons_to_press) in keys(cache)
        return cache[robot_level, buttons_to_press]
    end

    # always start on the A button
    # we also ALWAYS need to return to A, so we can just take the smallest number of button presses for
    # each robot greedily!
    n_buttons = 0
    start = dir_start

    for button in buttons_to_press
        # find the shortest way to get to this button from the current start position
        min_presses = BASICALLY_INF
        for path in find_pad_path(directional_pad, start, [button], [])
            min_presses = min(min_presses, min_button_presses(robot_level - 1, path, cache))
        end
        # add to the total and adjust the start position
        n_buttons += min_presses
        start = findfirst(directional_pad .== button)
    end
    # save to the cache and move on
    cache[robot_level, buttons_to_press] = n_buttons
    return n_buttons
end

function aoc()
    p1, p2 = 0, 0
    for code in (collect(line) for line in eachline("inputs/21.txt"))
        paths = find_pad_path(numeric_pad, num_start, code, [])
        numeric = parse(Int, join(code[1:end-1]))
        p1 += minimum(min_button_presses(2, buttons_to_press) for buttons_to_press in paths) * numeric
        p2 += minimum(min_button_presses(25, buttons_to_press) for buttons_to_press in paths) * numeric
    end
    return p1, p2
end

function main()
    println("BOTH PARTS: ", aoc())
    @time aoc()
end

main()
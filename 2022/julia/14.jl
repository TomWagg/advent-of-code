function find_resting_place(blocked_coords::Set, min_x::Int, max_x::Int, max_y::Int)
    """find the final resting place of a grain of sand"""
    # track the position of the sand
    pos = [500, 0]

    # as long as the sand is within the bounds of the blocked coordinates keep moving
    while min_x <= pos[1] <= max_x && pos[2] < max_y
        # move down if possible
        if !in([pos[1], pos[2] + 1], blocked_coords)
            pos = [pos[1], pos[2] + 1]
        # otherwise diagonal left down
        elseif !in([pos[1] - 1, pos[2] + 1], blocked_coords)
            pos = [pos[1] - 1, pos[2] + 1]
        # otherwise diagonal right down
        elseif !in([pos[1] + 1, pos[2] + 1], blocked_coords)
            pos = [pos[1] + 1, pos[2] + 1]
        # otherwise you've reached your resting places
        else
            return pos
        end
    end

    # if you've entered the abyss then return nothing
    return nothing
end;

function drop_sand(part_two)
    # set up a unique set of blocked off coordinates
    blocked_coords = Set()

    # track the x-bounds and depth
    min_x = 10000
    max_x = -1
    max_y = -1
    open("../inputs/14.txt", "r") do input
        for line in eachline(input)
            previous = nothing
            for coords in split.(split(line, " -> "), ",")
                x = parse(Int, coords[1])
                y = parse(Int, coords[2])
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                max_y = max(max_y, y)

                # create previous, draw a line between previous and current and add to blocked coords
                if previous == nothing
                    previous = [x, y]
                elseif previous[1] == x
                    for i in min(previous[2], y):max(previous[2], y)
                        push!(blocked_coords, [x, i])
                    end
                    previous = [x, y]
                elseif previous[2] == y
                    for i in min(previous[1], x):max(previous[1], x)
                        push!(blocked_coords, [i, y])
                    end
                    previous = [x, y]
                end
            end
        end
    end

    # pretend we have an infinite floor and just make a BIG finite floor
    # yes it is dumb...but it worked (:
    if part_two
        min_x = 0
        max_x = 1000

        # floor is at depth + 2
        max_y += 2
        for x in min_x:max_x
            push!(blocked_coords, [x, max_y])
        end
    end

    # move the first grain of sand (the do of my do-while loop)
    i = 1
    new_block = find_resting_place(blocked_coords, min_x, max_x, max_y)
    push!(blocked_coords, new_block)

    if part_two
        # for part 2 we keep going until the source is blocked off
        while new_block != [500, 0]
            new_block = find_resting_place(blocked_coords, min_x, max_x, max_y)
            push!(blocked_coords, new_block)
            i += 1
        end
        return i
    else
        # for part one we keep going until the sand doesn't rest
        while new_block != nothing
            new_block = find_resting_place(blocked_coords, min_x, max_x, max_y)
            push!(blocked_coords, new_block)
            i += 1
        end
        return i - 1
    end
end
println("PART ONE: ", drop_sand(false))
println("PART TWO: ", drop_sand(true))
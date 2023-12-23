function get_bricks()
    brick_strs = split.(split(read("../inputs/22.txt", String), '\n'), "~")
    return [[parse.(Int, split(left, ",")), parse.(Int, split(right, ","))] for (left, right) in brick_strs]
end

# convert a brick to a set of individual xy-coordinates
bricks_to_xycoords(brick) = [(i, j) for i in brick[1][1]:brick[2][1] for j in brick[1][2]:brick[2][2]]

# get the bottom or top of a brick
brick_bottom(b) = min(b[1][3], b[2][3])
brick_top(b) = max(b[1][3], b[2][3])

function drop_bricks(bricks)
    # track the dropped positions of each brick and which bricks support each
    dropped_bricks = Vector{Vector{Int}}[]
    supported_by = Dict{Int, Vector{Int}}()

    # step through and drop each brick (assume sorted by brick_bottom)
    for (brick_id, brick) in enumerate(bricks)
        # remember where the brick start and decide how far to drop it
        starting_z = brick_bottom(brick)
        dropped_z = 0
        xy_coords = bricks_to_xycoords(brick)

        # step through each brick potentially supporting this (the ones dropped so far)
        for (below_id, below_brick) in enumerate(dropped_bricks)
            below_coords = bricks_to_xycoords(below_brick)

            # check if there is ever an overlapping xy-coordinate
            if length(xy_coords ∩ below_coords) > 0
                below_z = brick_top(below_brick)

                # if the brick is above our current drop target
                if below_z > dropped_z
                    # adjust target and reset list of supports (it's just this one now)
                    dropped_z = below_z
                    supported_by[brick_id] = [below_id]

                # otherwise add to the list of supports
                elseif below_z == dropped_z
                    push!(supported_by[brick_id], below_id)
                end
            end
        end
        # we'll drop one above the supports
        dropped_z += 1

        # adjust the z height of this brick and drop it
        z_diff = starting_z - dropped_z
        brick[1][3] -= z_diff
        brick[2][3] -= z_diff
        push!(dropped_bricks, brick)
    end
    return dropped_bricks, supported_by
end

function main()
    # get the bricks, sort them by their bottoms and drop them
    bricks = get_bricks()
    bricks = sort(bricks, by=brick_bottom)
    bricks, supported_by = drop_bricks(bricks)

    # by default assume you can disintegrate everything
    can_disintegrate = fill(true, length(bricks))

    # if there's ever a brick supported by only a single brick, mark that single brick as false
    for supports in values(supported_by)
        if length(supports) == 1
            can_disintegrate[supports[1]] = false
        end
    end
    println("PART ONE: ", sum(can_disintegrate))

    falling_bricks = 0
    # try disintegrating every brick (gotta love brute force)
    for i in eachindex(can_disintegrate)
        # skip any that we know won't cause any falling
        if can_disintegrate[i]
            continue
        end

        # copy the support structure so we can mess with it
        supports = copy(supported_by)

        # track which bricks need destroying and keep going until none left
        to_destroy = [i]
        while length(to_destroy) > 0
            destroy_me = pop!(to_destroy)
            # step through each support
            for (key, val) in supports
                # for any that have the brick to destroy in this loop
                if destroy_me ∈ val
                    # if it's the only one left
                    if length(val) == 1
                        # also destroy the brick being supported
                        falling_bricks += 1
                        push!(to_destroy, key)
                        delete!(supports, key)
                    
                    # otherwise just remove it from the supports
                    else
                        supports[key] = filter(x->x!=destroy_me, val)
                    end
                end
            end
        end
    end
    println("PART TWO: ", falling_bricks)
end
main()

function get_hailstones()
    positions, velocities = [], []
    lines = split.(split(read("../inputs/24.txt", String), '\n'), " @ ")
    for (pos, vel) in lines
        push!(positions, parse.(Int, split(pos, ", ")))
        push!(velocities, parse.(Int, split(vel, ", ")))
    end
    return positions, velocities
end

function find_intersection(pos_a, pos_b, vel_a, vel_b)
    """Find the intersection point of two lines and time for each particle to get there (just some maths)"""
    vr_a = vel_a[2] / vel_a[1]
    vr_b = vel_b[2] / vel_b[1]

    x = ((pos_a[2] - pos_b[2]) - vr_a * pos_a[1] + vr_b * pos_b[1]) / (vr_b - vr_a)
    y = pos_a[2] + vr_a * (x - pos_a[1])
    t_a, t_b = (x - pos_a[1]) / vel_a[1], (x - pos_b[1]) / vel_b[1]
    return x, y, t_a, t_b
end

function count_collisions(p, v, safe_area=(200000000000000, 400000000000000))
    """Count the number of collisions between pairs of particle that occur in a given safe area"""
    collisions = 0
    for i in eachindex(p)
        for j in i + 1:length(p)
            x, y, t_a, t_b = find_intersection(p[i], p[j], v[i], v[j])
            # ensure the collision happens in the safe area and in the future for each particle
            if safe_area[1] <= x <= safe_area[2] && safe_area[1] <= y <= safe_area[2] && t_a > 0 && t_b > 0
                collisions += 1
            end
        end
    end
    return collisions
end

function all_collide_same_point(p, v)
    """Check whether every particle collides with the first particle in the same location"""
    # track the position of the collision
    collision_pos = [0, 0]

    # compare to the first particle
    i = 1

    # for each OTHER particle
    for j in 2:length(p)
        # check for a collision
        x, y, t_a, t_b = find_intersection(p[i], p[j], v[i], v[j])

        # ensure it happens in the future
        if t_a > 0 && t_b > 0
            # for the first collision, just update the value
            if collision_pos == [0, 0]
                collision_pos = [x, y]

            # otherwise, ensure both the x and y match and if not, return a failure
            elseif !all([x, y] .≈ collision_pos)
                return [0, 0]
            end
        end
    end
    # on success return the position that everything collided at
    return collision_pos
end

function check_z(lp, p, lv, v)
    """Find the time of collision for the first couple of particles, check that the z position give a 
    consistent z velocity"""
    # get the z positions and times of each collision
    z, t = [], []
    for i in 1:3
        _, _, t_a, _= find_intersection(p[i], lp, v[i], lv)
        push!(z, (p[i][3] + t_a * v[i][3]))
        push!(t, t_a)
    end

    # convert those into z velocities
    vz_s = diff(z) ./ diff(t)

    # if there are all the same (i.e. matches a straight line - celebration time)
    if all(vz_s .≈ vz_s[1])
        # get the launch velocity and position of the z coordinate
        vz = round(vz_s[1])
        z = round(p[3][3] + t[3] * (v[3][3] - vz))
        return (z, vz)
    else
        # otherwise this one is a bust
        return (0, 0)
    end
end

function search_perfect_shot(p, v, search_range=(-500, 500))
    """Search for a perfect shot to hit every single hailstone"""
    # search over the launch velocity space (in x-y)
    for vx in search_range[1]:search_range[2]
        for vy in search_range[1]:search_range[2]
            # switch in the stone's frame (that'll make them all hit the same point)
            launch_vel = [vx, vy, 0]
            adjusted_v = [v[i] .- launch_vel for i in eachindex(v)]

            # check that they all collide with the first particle at the same point
            launch_pos = all_collide_same_point(p, adjusted_v)

            # if there is not a common x-y collision point move on
            if launch_pos == [0, 0]
                continue
            end

            # check whether the z-coordinates check out
            z, vz = check_z(launch_pos, p, launch_vel, v)

            # if not then give up and move on
            if vz == 0
                continue
            end

            # WOOP! If you've reached here we've found a solution, return it!
            return Int(sum(launch_pos) + z)
        end
    end
end

# grab all of the hailstones
p, v = get_hailstones()

# count how many collide with each other in the x-y plane
println("PART ONE: ", count_collisions(p, v))

# turns out you only need the first couple of particles!
println("PART TWO: ", search_perfect_shot(p[1:5], v[1:5]))

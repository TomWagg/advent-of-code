using BenchmarkTools

function manhattan_distance(a::Array{Int}, b::Array{Int})
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

function get_sensors()
    sensors = Array{Int64}[]
    open("../inputs/15.txt", "r") do input
        for line in eachline(input)
            sensor_string, beacon_string = split(line, ":")
            sensor_x = parse(Int, split(split(sensor_string, "=")[2], ",")[1])
            sensor_y = parse(Int, split(sensor_string, "=")[3])
            beacon_x = parse(Int, split(split(beacon_string, "=")[2], ",")[1])
            beacon_y = parse(Int, split(beacon_string, "=")[3])

            beacon = [beacon_x, beacon_y]
            radius = manhattan_distance([sensor_x, sensor_y], beacon)

            # store each sensor as (x, y, radius_of_influence)
            push!(sensors, [sensor_x, sensor_y, radius])
        end
    end
    return sensors
end

function part_one()
    sensors = get_sensors()

    ROW_HEIGHT = 2_000_000
    covered_ranges = Array{Int64}[]

    # go over each sensor and check how much of the row it covers
    for i in eachindex(sensors)
        # first calculate how much extra distance it covers after reaching the row
        extra_radius = sensors[i][3] - abs(sensors[i][2] - ROW_HEIGHT)

        # if it reaches the row, add a range of x values covered
        if extra_radius >= 0
            push!(covered_ranges, [sensors[i][1] - extra_radius, sensors[i][1] + extra_radius])
        end
    end
    
    # sort the ranges by start time
    sort!(covered_ranges, by=x->x[1])

    # merge ranges into a series of disjoint ranges
    stack = [covered_ranges[1]]
    for rng in covered_ranges
        if rng[1] > last(stack)[2]
            push!(stack, rng)
        elseif rng[2] > last(stack)[2]
            last(stack)[2] = rng[2]
        end
    end

    # count up the length of each disjoint range and return the total
    total_covered = 0
    for i in eachindex(stack)
        total_covered += (stack[i][2] - stack[i][1])
    end
    return total_covered
end

function rotate(x::Int64, y::Int64)
    # rotate coordinates by 45 degrees
    return -x + y, x + y
end

function anti_rotate(x::Int64, y::Int64)
    # undo the rotation of the function above
    return [y - ((x + y) ÷ 2), (x + y) ÷ 2]
end

function get_rotated_corners(sensor::Array{Int64})
    # rotate all of the corners of influence of a sensor
    return Dict("bottom left" => rotate(sensor[1], sensor[2] - sensor[3]),
                "top right" => rotate(sensor[1], sensor[2] + sensor[3]),
                "top left" => rotate(sensor[1] + sensor[3], sensor[2]),
                "bottom right" => rotate(sensor[1] - sensor[3], sensor[2]))
end

function common_range(a1::Int64, a2::Int64, b1::Int64, b2::Int64)
    # work out the common range between two ranges
    lower = max(a1, b1)
    upper = min(a2, b2)

    if upper > lower
        return (lower, upper)
    else
        return nothing
    end
end

function compare_sensors(s1::Array{Int64}, s2::Array{Int64})
    # we're rotating them 45 degrees to get squares rather than diamonds because that make my head hurt less
    c1 = get_rotated_corners(s1)
    c2 = get_rotated_corners(s2)

    # compare edges to other boxes
    # the missing beacon can only occur when the edges have a gap between them (difference is 2)
    # so we basically just find the cases where this occurs and then brute force those ones

    # this top, other bottom
    if c1["top left"][2] + 2 == c2["bottom left"][2]
        overlap = common_range(c1["top left"][1], c1["top right"][1],
                               c2["bottom left"][1], c2["bottom right"][1])
        if overlap !== nothing
            return Set([anti_rotate(i, c1["top left"][2] + 1) for i in overlap[1]:overlap[2]])
        end

    # this right, other left
    elseif c1["top right"][1] + 2 == c2["top left"][1]
        overlap = common_range(c1["bottom right"][2], c1["top right"][2],
                               c2["bottom left"][2], c2["bottom left"][2])
        if overlap !== nothing
            return Set([anti_rotate(c1["top right"][2] + 1, i) for i in overlap[1]:overlap[2]])
        end

    # this bottom, other top
    elseif c1["bottom left"][1] - 2 == c2["top left"][1]
        overlap = common_range(c1["bottom left"][1], c1["bottm right"][1],
                               c2["top left"][1], c2["top right"][1])
        if overlap !== nothing
            return Set([anti_rotate(c1["bottom left"][2] - 1, i) for i in overlap[1]:overlap[2]])
        end

    # this left, other right
    elseif c1["top left"][1] - 2 == c2["top right"][1]
        overlap = common_range(c1["bottom left"][2], c1["top left"][2],
                               c2["bottom right"][2], c2["bottom right"][2])
        if overlap !== nothing
            return Set([anti_rotate(c1["top left"][1] - 1, i) for i in overlap[1]:overlap[2]])
        end
    end
end

function is_the_beacon(sensors::Array{Array{Int64}}, coord::Array{Int64})
    # check if a coordinate is the beacon we are looking for

    # make sure it is in the valid range
    if coord[1] < 0 || coord[2] > 4_000_000
        return false
    end

    # check if it is too close to any sensor
    for sensor in sensors
        if manhattan_distance(sensor[1:2], coord) <= sensor[3]
            return false
        end
    end

    # if not then we found it!
    return true
end

function part_two()
    # get all of the sensors
    sensors = get_sensors()

    # setup a set of candidate coordinates
    candidates = Set()

    # loop over the sensors in pairs
    for i in eachindex(sensors)
        for j in eachindex(sensors)
            # ignore self comparison
            if i != j
                # get a list of new candidates
                new_candidates = compare_sensors(sensors[i], sensors[j])

                # if we found any then combine them with the current set
                if new_candidates !== nothing
                    union!(candidates, new_candidates)
                end
            end
        end
    end

    # check whether every candidate is the beacon and return if you find it
    for coord in candidates
        if is_the_beacon(sensors, coord)
            return coord[1] * 4_000_000 + coord[2]
        end
    end

    # shouldn't reach here :crosses-fingers:
    return nothing
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())

@btime part_one()
@btime part_two()
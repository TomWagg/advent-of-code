using DataStructures

function manhattan_distance(a::Array{Int}, b::Array{Int})
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

function get_sensors_beacons()
    sensors = Array{Int64}[]
    beacons = Set()
    open("../inputs/15.txt", "r") do input
        for line in eachline(input)
            sensor_string, beacon_string = split(line, ":")
            sensor_x = parse(Int, split(split(sensor_string, "=")[2], ",")[1])
            sensor_y = parse(Int, split(sensor_string, "=")[3])
            beacon_x = parse(Int, split(split(beacon_string, "=")[2], ",")[1])
            beacon_y = parse(Int, split(beacon_string, "=")[3])

            beacon = [beacon_x, beacon_y]
            radius = manhattan_distance([sensor_x, sensor_y], beacon)

            push!(sensors, [sensor_x, sensor_y, radius])
            push!(beacons, beacon)
        end
    end
    return sensors, beacons
end

function part_one()
    sensors, beacons = get_sensors_beacons()

    ROW_HEIGHT = 2000000
    no_beacons = Set()
    for i in 1:length(sensors)
        extra_radius = abs(sensors[i][2] - ROW_HEIGHT) - sensors[i][3]
        if extra_radius <= 0
            push!(no_beacons, [sensors[i][1], ROW_HEIGHT])
            for j in 1:abs(extra_radius)
                push!(no_beacons, [sensors[i][1] - j, ROW_HEIGHT])
                push!(no_beacons, [sensors[i][1] + j, ROW_HEIGHT])
            end
        end
    end
    return length(setdiff(no_beacons, beacons))
end

function rotate(x, y)
    return -x + y, x + y
end

function anti_rotate(x, y)
    return [y - ((x + y) ÷ 2), (x + y) ÷ 2]
end

function get_rotated_corners(sensor)
    #lrtb
    return Dict("bottom left" => rotate(sensor[1], sensor[2] - sensor[3]),      # left bottom
                "top right" => rotate(sensor[1], sensor[2] + sensor[3]),      # right top
                "top left" => rotate(sensor[1] + sensor[3], sensor[2]),      # left top
                "bottom right" => rotate(sensor[1] - sensor[3], sensor[2]))      # right bottom
end

function common_range(a1, a2, b1, b2)
    lower = max(a1, b1)
    upper = min(a2, b2)

    if upper > lower
        return (lower, upper)
    else
        return nothing
    end
end

function compare_sensors(s1, s2)
    c1 = get_rotated_corners(s1)
    c2 = get_rotated_corners(s2)

    # this top, other bottom
    if c1["top left"][2] + 2 == c2["bottom left"][2]
        overlap = common_range(c1["top left"][1], c1["top right"][1],
                               c2["bottom left"][1], c2["bottom right"][1])
        if overlap != nothing
            return Set([anti_rotate(i, c1["top left"][2] + 1) for i in overlap[1]:overlap[2]])
        end

    # this right, other left
    elseif c1["top right"][1] + 2 == c2["top left"][1]
        overlap = common_range(c1["bottom right"][2], c1["top right"][2],
                               c2["bottom left"][2], c2["bottom left"][2])
        if overlap != nothing
            return Set([anti_rotate(c1["top right"][2] + 1, i) for i in overlap[1]:overlap[2]])
        end

    # this bottom, other top
    elseif c1["bottom left"][1] - 2 == c2["top left"][1]
        overlap = common_range(c1["bottom left"][1], c1["bottm right"][1],
                               c2["top left"][1], c2["top right"][1])
        if overlap != nothing
            return Set([anti_rotate(c1["bottom left"][2] - 1, i) for i in overlap[1]:overlap[2]])
        end

    # this left, other right
    elseif c1["top left"][1] - 2 == c2["top right"][1]
        overlap = common_range(c1["bottom left"][2], c1["top left"][2],
                               c2["bottom right"][2], c2["bottom right"][2])
        if overlap != nothing
            return Set([anti_rotate(c1["top left"][1] - 1, i) for i in overlap[1]:overlap[2]])
        end
    end
end

function is_the_beacon(sensors, coord)
    if coord[1] < 0 || coord[2] > 4_000_000#20
        return false
    end
    if all(isinteger.(coord))
        coord = Int.(coord)
    else
        return false
    end
    for sensor in sensors
        if manhattan_distance(sensor[1:2], coord) <= sensor[3]
            return false
        end
    end
    return true
end

function part_two()
    sensors, beacons = get_sensors_beacons()

    BOUNDARY = 4_000_000

    # rings = collect(out_of_reach_rings(sensors, BOUNDARY))
    # sort!(rings, by=x->x[2], rev=true)

    candidates = Set()
    for i in 1:length(sensors)
        for j in 1:length(sensors)
            if i != j
                new_things = compare_sensors(sensors[i], sensors[j])
                if new_things != nothing
                    union!(candidates, new_things)
                end
            end
        end
    end

    # @show candidates
    for coord in candidates
        if is_the_beacon(sensors, coord)
            return coord[1] * BOUNDARY + coord[2]
        end
    end
    return nothing
end

# @show Set([[i, i + 1] for i in 1:5])

# println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
# @time part_two()
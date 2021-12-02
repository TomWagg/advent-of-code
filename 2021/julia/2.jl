function move_ship(file)
    pos, depth = 0, 0
    open("../inputs/2.txt", "r") do input
        for line in eachline(input)
            direction, magnitude = split(line)
            mag_int = parse.(Int, magnitude)
            if direction == "forward"
                pos += mag_int
            elseif direction == "down"
                depth += mag_int
            elseif direction == "up"
                depth -= mag_int
            else
                error("Invalid direction")
            end;
        end;
    end;
    return pos * depth
end;

function move_ship_with_aim(file)
    pos, depth, aim = 0, 0, 0
    open("../inputs/2.txt", "r") do input
        for line in eachline(input)
            direction, magnitude = split(line)
            mag_int = parse.(Int, magnitude)
            if direction == "forward"
                pos += mag_int
                depth += mag_int * aim
            elseif direction == "down"
                aim += mag_int
            elseif direction == "up"
                aim -= mag_int
            else
                error("Invalid direction")
            end;
        end;
    end;
    return pos * depth
end;

function main()
    println("PART ONE: ", move_ship("../inputs/2.txt"))
    println("PART TWO: ", move_ship_with_aim("../inputs/2.txt"))
end;

main()
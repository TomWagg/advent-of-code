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

function main()
    println(move_ship("../inputs/2.txt"))
end;

main()
function move_ship(file)
    x, y = 0, 0
    open("../inputs/2.txt", "r") do input
        for line in eachline(input)
            direction, magnitude = split(line)
            mag_int = parse.(Int, magnitude)
            if direction == "forward"
                x += mag_int
            elseif direction == "down"
                y += mag_int
            elseif direction == "up"
                y -= mag_int
            else
                error("Invalid direction")
            end;
        end;
    end;
    return x * y
end;

function main()
    println(move_ship("../inputs/2.txt"))
end;

main()
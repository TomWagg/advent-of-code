function find_min_fuel(positions)
    # brute force, let's try aligning at every position in the range we are given
    min_loc = minimum(positions)
    max_loc = maximum(positions)

    # start with some massive fuel usage
    min_fuel = 1e20
    for loc in min_loc:max_loc
        # sum up the distances for each position
        fuel_needs = sum([abs(pos - loc) for pos in positions])

        # record the minimum
        min_fuel = minimum([min_fuel, fuel_needs])
    end;

    # return the min
    return min_fuel
end;



function find_min_fuel_nonlinear(positions)
    # brute force, let's try aligning at every position in the range we are given
    min_loc = minimum(positions)
    max_loc = maximum(positions)

    # start with some massive fuel usage
    min_fuel = 1e20
    for loc in min_loc:max_loc
        fuel_needs = 0

        # for every position in the possible range
        for pos in positions
            # find the distance it would need to travel
            distance = abs(pos - loc)

            # turn that into a fuel usage by doing a sum of integers
            fuel_needs += (distance + 1) * distance ÷ 2
        end;

    min_fuel = minimum([min_fuel, fuel_needs])
    end;

    # return the minimum
    return min_fuel
end;


function main()
    positions = open("../inputs/7.txt", "r") do input
        positions = parse.(Int, split(readline(input), ","))
    end;

    println("PART ONE: ", find_min_fuel(positions))
    println("PART TWO: ", find_min_fuel_nonlinear(positions))
end;


main()

function count_larger(depths)
    # start a count of how many depths were larger than the last one
    larger = 0
    for i in 2:length(depths)
        # add one every time the current depth is larger than the last depth
        larger += convert(Int, depths[i] - depths[i - 1] > 0)
    end;
    return larger
end;

function count_larger_window(depths)
    # start a count and a sliding window sum of the first three items
    larger = 0
    window = sum(depths[1:3])
    for i in 2:length(depths) - 2
        # add one every time the new window is larger than the window
        new_window = sum(depths[i:i + 2])
        larger += convert(Int, new_window > window)
        window = new_window
    end;
    return larger
end;

function main()
    # open up the input file
    depths = open("../inputs/1.txt", "r") do input
        # read all lines and use broadcast to parse all as ints
        depths = [parse(Int, line) for line in eachline(input)]
    end;

    # print out the result!
    println("PART ONE: ", count_larger(depths))
    println("PART TWO: ", count_larger_window(depths))
end;

main()
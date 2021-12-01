# open up the input file
open("../inputs/1.txt", "r") do input
    # read all lines and use broadcast to parse all as ints
    depths = parse.(Int, readlines(input))

    # start a count of how many depths were larger than the last one
    larger = 0
    for i in 2:length(depths)
        # add one every time the current depth is larger than the last depth
        larger += convert(Int, depths[i] - depths[i - 1] > 0)
    end;

    # print out the result!
    println(larger)
end;
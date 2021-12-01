open("../inputs/1.txt", "r") do input
    depths = parse.(Int, readlines(input))

    larger = 0
    for i in 2:length(depths)
        larger += convert(Int, depths[i] - depths[i - 1] > 0)
    end;

    println(larger)
end;
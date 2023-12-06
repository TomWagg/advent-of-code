using BenchmarkTools

function get_ways(time::Int, record::Int)
    low, high = 0.5 * (time - sqrt(time^2 - 4 * record)), 0.5 * (time + sqrt(time^2 - 4 * record))
    return Int(ceil(high - 1) - floor(low + 1) + 1)
end

function part_one()
    times, records = Array{Int}(undef, 0), Array{Int}(undef, 0)
    open("../inputs/6.txt", "r") do input
        for line in eachline(input)
            split_line = split(line, ":")
            if split_line[1] == "Time"
                times = parse.(Int, split(strip(split_line[2])))
            else
                records = parse.(Int, split(strip(split_line[2])))
            end
        end
    end
    return prod([get_ways(time, record) for (time, record) in zip(times, records)])
end

function part_two()
    time, record = 0, 0
    open("../inputs/6.txt", "r") do input
        for line in eachline(input)
            split_line = split(line, ":")
            if split_line[1] == "Time"
                time = parse.(Int, replace(split_line[2], " "=>""))
            else
                record = parse.(Int, replace(split_line[2], " "=>""))
            end
        end
    end
    return get_ways(time, record)
end

function main()
    println("PART ONE: ", part_one())
    @btime part_one()
    println("PART TWO: ", part_two())
    @btime part_two()
end

main()
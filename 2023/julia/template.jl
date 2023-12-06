# using DelimitedFiles
# using BenchmarkTools

function get_input()
    open("../inputs/.txt", "r") do input
        for line in eachline(input)
        end
    end
    return nothing
end

function part_one()
    nothing = get_input()
    return nothing
end

function part_two()
    nothing = get_input()
    return nothing
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end
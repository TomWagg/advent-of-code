using DelimitedFiles

function get_input()
    open("../inputs/.txt", "r") do input
        for line in eachline(input)
        end
    end
    return nothing
end

function part_one()
    return nothing
end

function part_two()
    return nothing
end

function main()
    nothing = get_input()
    part_one()
    part_two()
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
# using DelimitedFiles
# using BenchmarkTools

function get_input()
    left, right = Vector{Int}(undef, 0), Vector{Int}(undef, 0)
    for line in eachsplit(read("inputs/1.txt", String), '\n')
        vals = parse.(Int, split(line, "   "))
        push!(left, vals[1])
        push!(right, vals[2])
    end
    return left, right
end

function part_one()
    left, right = get_input()
    sort!(left), sort!(right)
    return sum(abs.(left .- right))
end

function part_two()
    left, right = get_input()
    uni = unique(right)
    uni_counts = Dict((element, count(==(element), right)) for element in uni)
    total = 0
    for thing in left
        if thing in right
            total += thing * uni_counts[thing]
        end
    end
    return total
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
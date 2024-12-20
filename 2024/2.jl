# using DelimitedFiles
# using BenchmarkTools

function get_input()
    levels = Vector{Vector{Int}}(undef, 0)
    for line in eachsplit(read("inputs/2.txt", String), '\n')
        push!(levels, parse.(Int, split(line, " ")))
    end
    return levels
end

function level_is_valid(level::Vector{Int})
    differences = diff(level)
    positive = differences .>= 0
    if all(positive) || all(.!positive)
        abs_diff = abs.(differences)
        if minimum(abs_diff) >= 1 && maximum(abs_diff) <= 3
            return true
        end
    end
    return false
end

function part_one()
    return mapreduce(level->level_is_valid(level), +, get_input())
end

function part_two()
    levels = get_input()
    n_safe = 0
    for level in levels
        if level_is_valid(level)
            n_safe += 1
            continue
        end
        for i in eachindex(level)
            new_level = deleteat!(copy(level), i)
            if level_is_valid(new_level)
                n_safe += 1
                break
            end
        end
    end
    return n_safe
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
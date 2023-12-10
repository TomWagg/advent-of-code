# using DelimitedFiles
# using BenchmarkTools

function get_input()
    numbers = []
    open("../inputs/1.txt", "r") do input
        for line in eachline(input)
            push!(numbers, parse(Int, line))
        end
    end
    return numbers
end

function part_one()
    numbers = get_input()
    for i in 1:length(numbers)
        for j in 1:length(numbers)
            if i != j && numbers[i] + numbers[j] == 2020
                return numbers[i] * numbers[j]
            end
        end
    end
end

function part_two()
    numbers = get_input()
    for i in 1:length(numbers)
        for j in 1:length(numbers)
            for k in 1:length(numbers)
                if i != j && i != k && j != k && numbers[i] + numbers[j] + numbers[k] == 2020
                    return numbers[i] * numbers[j] * numbers[k]
                end
            end
        end
    end
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
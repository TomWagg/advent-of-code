# using DelimitedFiles
# using BenchmarkTools

function get_input()
    sequences = Array{Array{Int}}(undef, 0)
    open("../inputs/9.txt", "r") do input
        for line in eachline(input)
            push!(sequences, parse.(Int, split(line)))
        end
    end
    return sequences
end

function extrapolate_sum(sequences)
    total = 0
    for sequence in sequences
        diffs = [diff(sequence)]
        while length(unique(diffs[length(diffs)])) > 1
            push!(diffs, diff(diffs[length(diffs)]))
        end

        total += sequence[length(sequence)]
        for i in eachindex(diffs)
            total += diffs[i][length(diffs[i])]
        end
    end
    return total
end

function part_one()
    sequences = get_input()

    total = 0
    for sequence in sequences
        diffs = [diff(sequence)]
        while length(unique(diffs[length(diffs)])) > 1
            push!(diffs, diff(diffs[length(diffs)]))
        end

        total += sequence[length(sequence)]
        for i in eachindex(diffs)
            total += diffs[i][length(diffs[i])]
        end
    end
    return total
end

function part_two_alt()
    sequences = get_input()

    total = 0
    for sequence in sequences
        reverse!(sequence)
        diffs = [diff(sequence)]
        while length(unique(diffs[length(diffs)])) > 1
            push!(diffs, diff(diffs[length(diffs)]))
        end

        total += sequence[length(sequence)]
        for i in eachindex(diffs)
            total += diffs[i][length(diffs[i])]
        end
    end
    return total
end

function part_two()
    sequences = get_input()

    total = 0
    for sequence in sequences
        diffs = [diff(sequence)]
        while length(unique(diffs[length(diffs)])) > 1
            push!(diffs, diff(diffs[length(diffs)]))
        end
        if length(diffs) > 1
            for i in length(diffs) - 1:-1:1
                diffs[i][1] -= diffs[i + 1][1]
            end
        end
        total += sequence[1] - diffs[1][1]
    end
    return total
end

function main()

    println("PART ONE: ", extrapolate_sum(get_input()))
    # @time part_one()
    println("PART TWO: ", extrapolate_sum(reverse!.(get_input())))
    # @time part_two()
end

main()
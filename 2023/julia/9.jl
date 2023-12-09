function get_input()
    sequences = Vector{Vector{Int}}(undef, 0)
    open("../inputs/9.txt", "r") do input
        for line in eachline(input)
            push!(sequences, parse.(Int, split(line)))
        end
    end
    return sequences
end

function extrapolate_sum(sequences::Vector{Vector{Int}})
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

println("PART ONE: ", extrapolate_sum(get_input()))
println("PART TWO: ", extrapolate_sum(reverse!.(get_input())))
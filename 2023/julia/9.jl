get_sequences() = map(x->parse.(Int, split(x)), split(read("../inputs/9.txt", String), '\n'))

function extrapolate_sum(sequences::Vector{Vector{Int}})
    total = 0
    for sequence in sequences
        diffs = [diff(sequence)]
        while length(unique(diffs[end])) > 1
            push!(diffs, diff(diffs[end]))
        end
        total += sequence[end]
        for i in eachindex(diffs)
            total += diffs[i][end]
        end
    end
    return total
end

println("PART ONE: ", extrapolate_sum(get_sequences()))
println("PART TWO: ", extrapolate_sum(reverse!.(get_sequences())))
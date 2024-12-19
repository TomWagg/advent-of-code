using Memoize

function get_input()
    towels_str, patterns_str = split(read("inputs/19.txt", String), "\n\n")
    return split(towels_str, ", "), split(patterns_str, "\n")
end

@memoize function arrange_towels(pattern::SubString{String})
    # if we've emptied the pattern then this arrangement works
    if pattern == ""
        return 1
    end
    # check which towels we could use next
    options = [towel for towel in towels if startswith(pattern, towel)]

    # if there are none left then we've failed, otherwise trim off this towel and sum the recursions
    return length(options) == 0 ? 0 : sum(arrange_towels(pattern[length(towel) + 1:end]) for towel in options)
end

function sol()
    n_possible, arrangements = 0, 0
    for pattern in patterns
        ways = arrange_towels(pattern)
        arrangements += ways
        n_possible += ways > 0
    end
    return n_possible, arrangements
end

const towels, patterns = get_input()
println("BOTH PARTS: ", sol())
@time sol()
using BenchmarkTools
using Memoization

@memoize function n_arrangements(springs::String, records::Tuple, n_group::Int)
    """Calculate the number of arrangements possible for a given list of springs, records of contiguous groups
    and the number of damaged springs in the current group"""
    # success criterion: no springs left, no records left and no ongoing group
    if length(springs) == 0
        return length(records) == 0 && n_group == 0 ? 1 : 0
    end

    # track the number of arrangements
    n = 0

    # if the spring is functional (or unknown)
    if springs[1] ∈ ['.', '?']
        # if you've previously started a group
        if n_group > 0
            # if the group is the correct length, remove it and continue
            if length(records) > 0 && records[1] == n_group
                n += n_arrangements(springs[2:lastindex(springs)], records[2:lastindex(records)], 0)
            end
        # otherwise just keep on truckin'
        else
            n += n_arrangements(springs[2:lastindex(springs)], records, 0)
        end
    end

    # if the spring is damaged (or unknown) then extend the current group and move on
    if springs[1] ∈ ['#', '?']
        n += n_arrangements(springs[2:lastindex(springs)], records, n_group + 1)
    end
    return n
end

function get_input()
    springs_list = []
    records_list = []
    open("../inputs/12.txt", "r") do input
        for line in eachline(input)
            springs, records_str = split(line)
            records = Tuple(parse.(Int, split(records_str, ",")))
            push!(springs_list, springs)
            push!(records_list, records)
        end
    end
    return springs_list, records_list
end

function part_one()
    springs_list, records_list = get_input()

    # sum the arrangements for each set of springs and records (the extra "." ensures every group gets caught)
    return sum([n_arrangements(springs * ".", records, 0)
                for (springs, records) in zip(springs_list, records_list)])
end

function part_two()
    springs_list, records_list = get_input()

    # repeat the input as defined in part 2
    repeated_input = [(repeat(springs * "?", 5), Tuple(repeat(collect(records), 5)))
                      for (springs, records) in zip(springs_list, records_list)]

    # as above (removing the last spring character because there will be an extra ?)
    return sum([n_arrangements(springs[1:lastindex(springs) - 1] * ".", records, 0)
                for (springs, records) in repeated_input])
end

function main()
    println("PART ONE: ", part_one())
    @btime part_one()                   # ~2 ms
    println("PART TWO: ", part_two())
    @btime part_two()                   # ~4 ms
end

main()
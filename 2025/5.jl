function part_one(ranges::Vector{Tuple{Int, Int}}, ids::Vector{Int})
    sort!(ranges)
    fresh = 0
    for id in ids
        for (low, high) in ranges
            if low ≤ id ≤ high
                fresh += 1
                break
            end
        end
    end
    return fresh
end

function part_two(ranges::Vector{Tuple{Int, Int}})
    # sort the ranges by the lower edge
    sort!(ranges)

    merged_ranges = Vector{Tuple{Int, Int}}(undef, 0)

    # consider each range in the list
    while length(ranges) > 0
        r_low, r_high = popfirst!(ranges)
        no_insert, to_delete = false, Vector{Int}(undef, 0)
        for m_ind in eachindex(merged_ranges)
            m_low, m_high = merged_ranges[m_ind]

            if r_low < m_low
                if r_high ≥ m_high
                    push!(to_delete, m_ind)
                elseif r_high ≥ m_low
                    r_high = m_high
                    push!(to_delete, m_ind)
                end
            elseif m_low ≤ r_low ≤ m_high && r_high > m_high
                r_low = m_low
                push!(to_delete, m_ind)
            elseif m_low ≤ r_low ≤ m_high && m_low ≤ r_high ≤ m_high
                no_insert = true
                break
            end
        end
        if length(to_delete) != 0
            deleteat!(merged_ranges, to_delete)
        end
        if ~no_insert
            push!(merged_ranges, (r_low, r_high))
        end
    end
    return sum(h - l + 1 for (l, h) in merged_ranges)
end

function main()
    range_str, id_str = split(read("inputs/5.txt", String), "\n\n")
    ranges = [Tuple(parse.(Int, split(r, '-'))) for r in eachsplit(range_str, '\n')]
    ids = [parse(Int, i) for i in eachsplit(id_str, '\n')]

    println("PART ONE: ", part_one(ranges, ids))
    @time part_one(ranges, ids)
    println("PART TWO: ", part_two(copy(ranges)))
    @time part_two(ranges)
end

main()
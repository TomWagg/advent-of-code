function sol(ranges::Vector{Vector{Int}}, regex::Regex)
    invalid_ids = Set([])
    for range in ranges
        for i in range[1]:range[2]
            if match(regex, string(i)) !== nothing
                push!(invalid_ids, i)
            end
        end
    end
    return sum(invalid_ids)
end

function main()
    ranges = [parse.(Int, split(range, "-")) for range in eachsplit(read("inputs/2.txt", String), ',')]
    part_one() = sol(ranges, r"^(\d+)\1$")
    part_two() = sol(ranges, r"^(\d+)\1+$")

    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
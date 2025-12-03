function largest_joltage(bank::AbstractString, n_bat::Int, cache::Dict{Tuple{AbstractString, Int}, Int})
    if length(bank) == 1
        return parse(Int, bank), cache
    end

    if (bank, n_bat) ∉ keys(cache)
        max_joltage = 0
        for i in 1:length(bank) - (n_bat - 1)
            joltage = parse(Int, bank[i]) * 10^(n_bat - 1)
            if n_bat > 1
                more_joltage, cache = largest_joltage(bank[i + 1:end], n_bat - 1, cache)
                joltage += more_joltage
            end
            max_joltage = max(max_joltage, joltage)
        end
        cache[(bank, n_bat)] = max_joltage
    end
    
    return cache[(bank, n_bat)], cache
end

function main()
    banks = [bank for bank in eachsplit(read("inputs/3.txt", String), '\n')]
    cache = Dict{Tuple{AbstractString, Int}, Int}()

    part_one() = sum(largest_joltage(bank, 2, cache)[1] for bank in banks)
    part_two() = sum(largest_joltage(bank, 12, cache)[1] for bank in banks)

    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
function get_input()
    seeds = Array{Int}(undef, 0)
    maps = []
    new_map = []
    open("../inputs/5.txt", "r") do input
        for line in eachline(input)
            split_line = split(line, ":")
            if length(split_line) > 1
                if split_line[1] == "seeds"
                    seeds = parse.(Int, split(strip(split_line[2])))
                elseif length(new_map) > 0
                    push!(maps, new_map)
                    new_map = []
                end
            elseif length(line) > 1
                dest_start, source_start, l = parse.(Int, split(line))
                push!(new_map, [source_start, source_start + l, source_start - dest_start])
            end
        end
    end

    if length(new_map) > 0
        push!(maps, new_map)
    end
    @show seeds
    @show maps
    return seeds, maps
end

function part_one(seeds, maps)
    soils = zeros(Int, length(seeds))
    for (i, seed) in enumerate(seeds)
        # @show "Starting seed", seed
        for map in maps
            # @show seed, map
            for (low, high, convert) in map
                if seed >= low && seed < high
                    seed -= convert
                    break
                end
            end
        end
        soils[i] = seed
        # @show "end seed", seed
    end
    return minimum(soils)
end

function part_two()
    return nothing
end

function main()
    seeds, maps = get_input()

    println("PART ONE: ", part_one(seeds, maps))
    println("PART TWO: ", part_two())
end

main()
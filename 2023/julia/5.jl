using BenchmarkTools

function get_input()
    seeds = Array{Int}(undef, 0)
    maps = Array{Array{Array{Int}}}(undef, 0)
    new_map = Array{Array{Int}}(undef, 0)
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
                push!(new_map, [source_start, source_start + l, dest_start - source_start])
            end
        end
    end

    if length(new_map) > 0
        push!(maps, new_map)
    end
    return seeds, maps
end

function part_one()
    seeds, maps = get_input()
    soils = zeros(Int, length(seeds))
    for (i, seed) in enumerate(seeds)
        for map in maps
            for (low, high, convert) in map
                if seed >= low && seed < high
                    seed += convert
                    break
                end
            end
        end
        soils[i] = seed
    end
    return minimum(soils)
end

function part_two()
    seeds, maps = get_input()
    # convert seeds into seed ranges
    seed_ranges = Array{Array{Int}}(undef, 0)
    for i in 1:2:length(seeds)
        push!(seed_ranges, [seeds[i], seeds[i] + seeds[i + 1]])
    end

    # track the minimum final location
    min_location = Inf

    for seed_range in seed_ranges
        # track all of the ranges that get spawned
        ranges = [seed_range]
        
        # go through each of the conversion maps
        for map in maps

            # track the ranges that have been converted and those that need doing
            done_ranges = Array{Array{Int}}(undef, 0)
            todo_ranges = ranges

            # keep going until there are no ranges left
            while length(todo_ranges) > 0
                seed_low, seed_high = pop!(todo_ranges)

                # go through each of the minimaps in this map
                for i in eachindex(map)
                    map_low, map_high, convert = map[i]
                    # no overlap
                    if seed_high < map_low || seed_low >= map_high
                        # if it's the last one then we need to mark it as done
                        if i == length(map)
                            push!(done_ranges, [seed_low, seed_high])
                        end

                        # otherwise we just continue to the next minimap
                        continue

                    # left overlap
                    elseif seed_low < map_low && seed_high > map_low && seed_high < map_high
                        push!(todo_ranges, [seed_low, map_low])
                        push!(done_ranges, [map_low, seed_high] .+ convert)
                        break

                    # right overlap
                    elseif seed_low >= map_low && seed_low < map_high && seed_high > map_high
                        push!(done_ranges, [seed_low, map_high] .+ convert)
                        push!(todo_ranges, [map_high, seed_high])
                        break

                    # fully contained
                    elseif seed_low >= map_low && seed_high <= map_high
                        push!(done_ranges, [seed_low, seed_high] .+ convert)
                        break

                    # fully overlaps
                    elseif seed_low < map_low && seed_high > map_high
                        push!(todo_ranges, [seed_low, map_low])
                        push!(done_ranges, [map_low, map_high] .+ convert)
                        push!(todo_ranges, [map_high, seed_high])
                        break
                    end
                end
            end
            # update the ranges for next time
            ranges = done_ranges
        end

        # go through the final ranges and find the minimum location
        for (low, _) in ranges
            if low < min_location
                min_location = low
            end
        end
    end
    return min_location
end

function main()
    println("PART ONE: ", part_one())
    @btime part_one()
    println("PART TWO: ", part_two())
    @btime part_two()
end

main()
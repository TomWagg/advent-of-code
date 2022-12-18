using DataStructures

function youve_got_wind()
    wind = nothing
    open("../inputs/17.txt", "r") do input
        gusts = collect(String(read(input)))
        wind = falses(length(gusts) - 1)
        for i in 1:length(gusts) - 1
            wind[i] = (gusts[i] == '>')
        end
    end
    return wind
end

function print_cave(blocked_positions::BitMatrix, limit::Int64)
    println("+-------+")
    for i in 1:limit - 1
        print("|")
        for j in 2:8
            if blocked_positions[j, limit + 1 - i]
                print("#")
            else
                print(".")
            end
        end
        print("|")
        println()
    end
    println("+-------+")
end

function cave_to_file(blocked_positions::BitMatrix, limit::Int64)
    open("17.out", "w") do f
        write(f, "+-------+\n")
        for i in 1:limit - 1
            write(f, "|")
            for j in 2:8
                if blocked_positions[j, limit + 1 - i]
                    write(f, "#")
                else
                    write(f, ".")
                end
            end
            write(f, "|\n")
        end
        write(f, "+-------+\n")
    end
end

function shift_block_down(block::Vector{Vector{Int64}}, mag::Int64)
    for i in eachindex(block)
        block[i][2] -= mag
    end
    return block
end

function shift_block_right(block::Vector{Vector{Int64}}, mag::Int64)
    for i in eachindex(block)
        block[i][1] += mag
    end
    return block
end

function can_move_down(blocked_positions::BitMatrix, block::Vector{Vector{Int64}})
    for i in eachindex(block)
        if blocked_positions[block[i][1], block[i][2] - 1]
            return false
        end
    end
    return true
end

function can_move_right(blocked_positions::BitMatrix, block::Vector{Vector{Int64}})
    for i in eachindex(block)
        if blocked_positions[block[i][1] + 1, block[i][2]]
            return false
        end
    end
    return true
end

function can_move_left(blocked_positions::BitMatrix, block::Vector{Vector{Int64}})
    for i in eachindex(block)
        if blocked_positions[block[i][1] - 1, block[i][2]]
            return false
        end
    end
    return true
end

function get_surface_heights(blocked_positions::BitMatrix, highest_block::Int64)
    surface_heights = Array{Int64}(undef, 7)
    for x in 2:8
        y = highest_block
        while !blocked_positions[x, y]
            y -= 1
        end
        surface_heights[x - 1] = y - highest_block
    end
    return surface_heights
end

function drop_rocks(n_block_max::Int64)
    wind = youve_got_wind()

    blocks = []
    push!(blocks, [[4, 1], [5, 1], [6, 1], [7, 1]])
    push!(blocks, [[5, 1], [4, 2], [5, 2], [6, 2], [5, 3]])
    push!(blocks, [[4, 1], [5, 1], [6, 1], [6, 2], [6, 3]])
    push!(blocks, [[4, 1], [4, 2], [4, 3], [4, 4]])
    push!(blocks, [[4, 1], [4, 2], [5, 1], [5, 2]])

    nb = length(blocks)
    nw = length(wind)
    highest_block = 1
    total_highest_block = 0

    blocked_positions = falses(9, 14 * 50000)
    blocked_positions[1, :] .= 1
    blocked_positions[9, :] .= 1
    blocked_positions[:, 1] .= 1

    cache = Dict{Tuple, Tuple}()
    heights = []

    n_blocks = 1
    wind_cursor = 1
    while n_blocks <= n_block_max
        push!(heights, highest_block)
        current_block = deepcopy(blocks[((n_blocks - 1) % nb) + 1])
        bottom_of_block = minimum(x -> x[2], current_block)

        key = get_surface_heights(blocked_positions, highest_block)
        push!(key, ((n_blocks - 1) % nb) + 1)
        push!(key, ((wind_cursor - 1) % nw) + 1)
        tkey = Tuple(key)
        
        # this is triggered when a cycle is detected so we can skip doing the rest
        if haskey(cache, tkey)
            cycle_start, start_highest = cache[tkey]
            
            # don't ask.
            n_blocks -= 1
            highest_block -= 2
            blocks_required = n_blocks - cycle_start
            height_gained = highest_block - start_highest
            n_cycles = (n_block_max - cycle_start) ÷ blocks_required
            return n_cycles * height_gained + heights[((n_block_max - cycle_start) % blocks_required) + cycle_start + 1] - 1
        end
        cache[tkey] = (n_blocks - 1, highest_block - 2)

        shift = highest_block + 3 - bottom_of_block + 1
        current_block = shift_block_down(current_block, -shift)

        while true
            if wind[((wind_cursor - 1) % nw) + 1]
                if can_move_right(blocked_positions, current_block)
                    current_block = shift_block_right(current_block, 1)
                end
            else
                if can_move_left(blocked_positions, current_block)
                    current_block = shift_block_right(current_block, -1)
                end
            end
            wind_cursor += 1

            if can_move_down(blocked_positions, current_block)
                current_block = shift_block_down(current_block, 1)
            else
                break
            end
        end

        for i in eachindex(current_block)
            blocked_positions[current_block[i][1], current_block[i][2]] = 1
            highest_block = max(highest_block, current_block[i][2])
        end
        n_blocks += 1
    end

    return total_highest_block - 1 + highest_block
end

println("PART ONE: ", drop_rocks(2022))
println("PART TWO: ", drop_rocks(1000000000000))
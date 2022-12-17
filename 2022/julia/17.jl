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

function can_move_down(blocked_positions, block)
    for i in eachindex(block)
        if blocked_positions[block[i][1], block[i][2] - 1]
            return false
        end
    end
    return true
end

function can_move_right(blocked_positions, block)
    for i in eachindex(block)
        if blocked_positions[block[i][1] + 1, block[i][2]]
            return false
        end
    end
    return true
end

function can_move_left(blocked_positions, block)
    for i in eachindex(block)
        if blocked_positions[block[i][1] - 1, block[i][2]]
            return false
        end
    end
    return true
end

function part_one(n_block_max)
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

    blocked_positions = falses(9, 500)
    blocked_positions[1, :] .= 1
    blocked_positions[9, :] .= 1
    blocked_positions[:, 1] .= 1

    n_blocks = 1
    wind_cursor = 1
    while n_blocks <= n_block_max
        current_block = deepcopy(blocks[((n_blocks - 1) % nb) + 1])
        # @show current_block
        bottom_of_block = minimum(x->x[2], current_block)
        # left_of_block = minimum(x->x[1], current_block)
        # right_of_block = maximum(x->x[1], current_block)

        shift = highest_block + 3 - bottom_of_block + 1
        current_block = shift_block_down(current_block, -shift)

        while true
            # @show wind_cursor, wind[((wind_cursor - 1) % nw) + 1]
            if wind[((wind_cursor - 1) % nw) + 1]
                # if n_blocks <= 7
                #     @show n_blocks, can_move_right(blocked_positions, current_block)
                # end
                if can_move_right(blocked_positions, current_block)
                    current_block = shift_block_right(current_block, 1)
                end
            else
                # if n_blocks <= 7
                #     @show n_blocks, can_move_left(blocked_positions, current_block)
                # end
                if can_move_left(blocked_positions, current_block)
                    current_block = shift_block_right(current_block, -1)
                end
            end
            wind_cursor += 1

            if can_move_down(blocked_positions, current_block)
                # if n_blocks <= 7
                #     @show n_blocks, "moving down"
                # end
                current_block = shift_block_down(current_block, 1)
            else
                break
            end
        end

        # @show current_block

        rows_to_check = []
        for i in eachindex(current_block)
            blocked_positions[current_block[i][1], current_block[i][2]] = 1
            push!(rows_to_check, current_block[i][2])
            highest_block = max(highest_block, current_block[i][2])
        end

        for i in reverse(eachindex(rows_to_check))

            # check whether we can erase everything below and continue
            if all(blocked_positions[2:8, rows_to_check[i]])
                new_bp = falses(9, 500)
                new_bp[1, :] .= 1
                new_bp[9, :] .= 1
                new_bp[:, 1] .= 1
                total_highest_block += rows_to_check[i] - 1
                for j in rows_to_check[i] + 1:highest_block
                    new_bp[:, j - (rows_to_check[i] + 1) + 2] = blocked_positions[:, j]
                end
                highest_block -= (rows_to_check[i] - 1)

                blocked_positions = new_bp
                break
            end
        end
        n_blocks += 1
    end

    # open("17.out", "w") do f
    #     write(f, "+-------+\n")
    #     for i in 1:49
    #         write(f, "|")
    #         for j in 2:8
    #             if blocked_positions[j, 51 - i]
    #                 write(f, "#")
    #             else
    #                 write(f, ".")
    #             end
    #         end
    #         write(f, "|\n")
    #     end
    #     write(f, "+-------+\n")
    # end

    # println("+-------+")
    # for i in 1:49
    #     print("|")
    #     for j in 2:8
    #         if blocked_positions[j, 51 - i]
    #             print("#")
    #         else
    #             print(".")
    #         end
    #     end
    #     print("|")
    #     println()
    # end
    # println("+-------+")

    return total_highest_block - 1 + highest_block
end

function part_two()
    return nothing
end

println("PART ONE: ", part_one(2022))
@time part_one(2022)
@time part_one(20220)
@time part_one(202200)
@time part_one(1000000000000)
# println("PART TWO: ", part_one(1000000000000))
using DataStructures

function matrix_to_set(A::Matrix{Int64})
    m, _ = size(A)
    B = Set()
    for i in 1:m
        push!(B, A[i, :])
    end
    return B
end

function valid_move(new_pos::Array{Int64}, blizzard_set::Set, max_row::Int, max_col::Int, start::Array{Int})
    if new_pos in blizzard_set
        return false
    end

    if new_pos == start
        return true
    end

    return 1 < new_pos[1] < max_row && 1 < new_pos[2] < max_col
end

function get_initial_state()
    max_col = 0
    max_row = 0
    n_blizzard = 0

    open("../inputs/24.txt", "r") do input
        for line in eachline(input)
            max_col = length(line)
            max_row += 1

            matches = collect(eachmatch(r"[><\^v]", line))

            if matches !== nothing
                n_blizzard += length(matches)
            end
        end
    end

    start = nothing
    exit = nothing
    blizzards = Matrix{Int64}(undef, n_blizzard, 2)
    directions = Matrix{Int64}(undef, n_blizzard, 2)

    dir_to_int = Dict('>' => [0, 1], '<' => [0, -1], '^' => [-1, 0], 'v' => [1, 0])
    blizzard_counter = 1
    open("../inputs/24.txt", "r") do input
        for (row, line) in enumerate(eachline(input))
            for (col, c) in enumerate(collect(line))
                if c == '.' && row == 1
                    start = [row, col]
                elseif c == '.'
                    exit = [row, col]
                end

                if c in ['>', '<', '^', 'v']
                    blizzards[blizzard_counter, :] = [row, col]
                    directions[blizzard_counter, :] = dir_to_int[c]
                    blizzard_counter += 1
                end
            end
        end
    end
    return blizzards, directions, max_row, max_col, start, exit
end

function traverse_blizzard()
    blizzards, directions, max_row, max_col, start, exit = get_initial_state()

    total_time = 0

    time, blizzards = search_paths(blizzards, directions, max_row, max_col, start, exit)
    total_time += time
    println("PART ONE: ", time)

    time, blizzards = search_paths(blizzards, directions, max_row, max_col, exit, start)
    total_time += time
    time, blizzards = search_paths(blizzards, directions, max_row, max_col, start, exit)
    total_time += time
    println("PART TWO: ", total_time)
end

function evolve_blizzards(blizzards::Matrix{Int64}, directions::Matrix{Int64}, max_row::Int64, max_col::Int64)
    blizzards .+= directions

    blizz_row = blizzards[:, 1]
    blizz_col = blizzards[:, 2]

    blizz_row[blizz_row .>= max_row] .= 2
    blizz_row[blizz_row .<= 1] .= max_row - 1
    blizz_col[blizz_col .>= max_col] .= 2
    blizz_col[blizz_col .<= 1] .= max_col - 1

    blizzards = hcat(blizz_row, blizz_col)

    return blizzards
end

function search_paths(blizzards::Matrix{Int64}, directions::Matrix{Int64}, max_row::Int64, max_col::Int64,
                      start::Array{Int64}, exit::Array{Int64})
    # basic BFS
    pos = start
    time = 0

    moves = [[0, 0], [0, 1], [1, 0], [0, -1], [-1, 0]]

    queue = [pos]
    while length(queue) > 0
        # evolve the blizzards forward a timestep and convert to a Set
        blizzards = evolve_blizzards(blizzards, directions, max_row, max_col)
        blizzard_set = matrix_to_set(blizzards)

        visited = Set()
        for _ in 1:length(queue)

            # get the first thing from the queue
            pos = popfirst!(queue)

            # if we're about to exit then just do it
            if [pos[1] + 1, pos[2]] == exit || [pos[1] - 1, pos[2]] == exit
                return time + 1, blizzards
            end

            # try the five different moves
            for move in moves
                new_pos = pos + move

                # push any that are valid
                if valid_move(new_pos, blizzard_set, max_row, max_col, start) && !(new_pos in visited)
                    push!(visited, new_pos)
                    push!(queue, new_pos)
                end
            end
        end
        time += 1
    end

    return nothing
end

traverse_blizzard()
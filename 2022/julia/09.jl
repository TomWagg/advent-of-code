function get_moves()
    # create an array of x, y moves
    moves = Array{Int64}[]
    open("../inputs/9.txt") do input
        for line in eachline(input)
            dir, mag = split(line, " ")
            vec = nothing
            if dir == "R"
                vec = [1, 0]
            elseif dir == "L"
                vec = [-1, 0]
            elseif dir == "U"
                vec = [0, 1]
            elseif dir == "D"
                vec = [0, -1]
            end
            # all moves have magnitude 1 (add multiple for larger moves)
            for i in 1:parse(Int, mag)
                push!(moves, vec)
            end
        end
    end
    return moves
end

function part_one()
    moves = get_moves()

    # keep track of unique tail positions and current head/tail
    tail_positions = Set{Array}()
    head = [0, 0]
    tail = [0, 0]

    for i in 1:length(moves)
        # keep track of original head location and move head
        og_head = copy(head)
        head .+= moves[i]

        # if the head and tail are separated too much then put tail where head used to be
        diff = head - tail
        if any(abs.(diff) .> 1)
            tail = og_head
        end;

        # add tail position to set
        push!(tail_positions, copy(tail))
    end
    return length(tail_positions)
end

function part_two()
    moves = get_moves()

    # as part one but now 10 knots instead of just head/tail
    tail_positions = Set{Array}()
    knots = zeros(Int64, 10, 2)

    for i in 1:length(moves)
        # move the head
        knots[1, :] .+= moves[i]

        # go through each of the subsequent knots
        for j in 1:9
            # if the separation is more than 1 in any direction
            diff = knots[j, :] - knots[j + 1, :]
            if any(abs.(diff) .> 1)
                # reduce any 2's to ones
                diff[diff .> 1] .= 1
                diff[diff .< -1] .= -1

                # move the difference
                knots[j + 1, :] .+= diff
            end
        end
        # keep track of unique tail positions
        push!(tail_positions, copy(knots[10, :]))
    end
    return length(tail_positions)
end

function main()
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end

main()
const convert_d = Dict('<'=>CartesianIndex(0, -1), '^'=>CartesianIndex(-1, 0),
                       '>'=>CartesianIndex(0, 1), 'v'=>CartesianIndex(1, 0))

function get_input(is_p2::Bool)
    file = read("inputs/15.txt", String)
    map, directions = split(file, "\n\n")
    # expand the map for part 2
    map = is_p2 ? replace(map, "#"=>"##", "O"=>"[]", "."=>"..", "@"=>"@.") : map

    board = permutedims(hcat(collect.(split(map, "\n"))...), (2,1))
    directions = replace(directions, '\n'=>"")
    return findfirst(board .== '@'), directions, board
end

function move(board::Matrix{Char}, pos::CartesianIndex, dir::CartesianIndex, perform_move::Bool)
    # save the new coords and value at that pos
    new_pos = pos + dir
    adjacent = board[new_pos]

    # check whether you can move
    can_move = false

    # recurse when you find a rock
    if adjacent == '.'
        can_move = true
    elseif adjacent == 'O' || adjacent == '[' || adjacent == ']'
        can_move = move(board, new_pos, dir, perform_move)
    end

    # for vertical moves also check the other half of the rock
    if dir[1] != 0 && (adjacent == '[' || adjacent == ']')
        can_move = can_move && move(board, new_pos + CartesianIndex(0, adjacent == '[' ? 1 : -1),
                                    dir, perform_move)
    end

    # if you're okay to move and we're actually performing the move this time then go ahead and do it
    if can_move && perform_move
        board[new_pos] = board[pos]
        board[pos] = '.'
    end
    return can_move
end

function sol(is_p2)
    robot, directions, board = get_input(is_p2)

    for d in directions
        dir = convert_d[d]
        
        # attempt to move
        moved = move(board, robot, dir, false)

        # if the move worked then then actually do the move
        if moved
            move(board, robot, dir, true)
            robot += dir
        end
    end
    return sum(100 * (loc[1] - 1) + (loc[2] - 1) for loc in findall(board .== (is_p2 ? '[' : 'O')))
end

function main()
    println("PART ONE: ", sol(false))
    @time sol(false)
    println("PART TWO: ", sol(true))
    @time sol(true)
end

main()

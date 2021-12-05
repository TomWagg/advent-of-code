function find_first_winner(values, boards)
    # at the start there are no matches for each board
    n_boards, board_size = size(boards)
    matches = zeros(Int, (n_boards, board_size))

    # read out a value one at a time
    for i in eachindex(values)
        # check each board
        for j in 1:n_boards
            # if this value is on the board then mark it
            if values[i] in boards[j, :]
                matches[j, indexin(values[i], boards[j, :])[1]] = 1
            end;

            # check if this board just won
            if is_winning_board(matches[j, :])
                # get all of the unmarked values
                unmarked = boards[j, :] .* (1 .- matches[j, :])

                # sum them up and multiply by the winning value
                return sum(unmarked) * values[i]
            end;
        end;
    end;

    # return -1 if no one won
    return -1
end;


function find_last_winner(values, boards)
    # at the start there are no matches for each board
    n_boards, board_size = size(boards)
    matches = zeros(Int, (n_boards, board_size))

    # keep track of which boards haven't won yet
    playing = collect(1:n_boards)

    # Also who won last and what the value was
    last_winner = -1
    winning_value = -1

    # read out a value one at a time
    for i in eachindex(values)
        # track who won this round
        winners_this_round = []

        # check each board
        for j in eachindex(playing)
            # if this value is on the board then mark it
            if values[i] in boards[playing[j], :]
                matches[playing[j], indexin(values[i], boards[playing[j], :])[1]] = 1
            end;

            # check if this board just won
            if is_winning_board(matches[playing[j], :])
                winners_this_round = [winners_this_round;playing[j]]
                last_winner = playing[j]
                winning_value = values[i]
            end;
        end;

        for j in eachindex(winners_this_round)
            filter!(x -> x ≠ winners_this_round[j], playing)
        end;
    end;

    # count up the unmarked values in the last winner's board
    unmarked = boards[last_winner, :] .* (1 .- matches[last_winner, :])

    # multiply by winning value
    return sum(unmarked) * winning_value
end;


function is_winning_board(matches)
    """ Check if a board wins bingo"""
    n_row, n_col = 5, 5

    # check every row
    for i in 1:n_row
        row = matches[ (i - 1) * n_col + 1 : i * n_col]

        # if every value in the row matches then this board wins
        if sum(row) == n_col
            return true
        end;
    end;

    # check every column (more annoying than rows since not contiguous)
    base_inds = 1:n_row:n_col*n_row
    for i in 1:n_col
        col = [matches[ind + i - 1] for ind in base_inds]

        # if every value in the col matches then this board wins
        if sum(col) == n_row
            return true
        end;
    end;

    # otherwise this board hasn't won (yet!)
    return false
end;


function main()
    # start up an array of boards
    boards = Int[]
    values = Int[]
    open("../inputs/4.txt", "r") do input
        # get the first line of the file which contains the value that get read outs
        values = parse.(Int, split(chomp(readline(input)), ","))

        # start a new board
        current_board = nothing
        current_board = []
        for line in eachline(input)
            # if a new line occurs, save the current board and start a new one
            if chomp(line) == "" && current_board != []
                append!(boards, current_board)
                current_board = []
            # otherwise flatten out the board (combine rows)
            elseif chomp(line) != ""
                current_board = [current_board; parse.(Int, split(chomp(line)))]
            end;
        end;

        # don't miss the last board!
        append!(boards, current_board)
    end;

    boards = reshape(boards, (25, length(boards) ÷ 25)) |> transpose

    println("PART ONE:", find_first_winner(values, boards))
    println("PART TWO:", find_last_winner(values, boards))
end;

main()


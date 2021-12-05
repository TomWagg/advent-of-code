def find_first_winner(values, boards):
    # at the start there are no matches for each board
    matches = [[0 for i in range(len(boards[0]))] for j in range(len(boards))]

    # read out a value one at a time
    for value in values:
        # check each board
        for i in range(len(boards)):
            # if this value is on the board then mark it
            if value in boards[i]:
                matches[i][boards[i].index(value)] = 1

            # check if this board just won
            if is_winning_board(matches[i]):
                # get all of the unmarked values
                unmarked = [boards[i][j] if not matches[i][j] else 0 for j in range(len(boards[i]))]

                # sum them up and multiply by the winning value
                return sum(unmarked) * value

    # return -1 if no one won
    return -1


def find_last_winner(values, boards):
    # at the start there are no matches for each board
    matches = [[0 for i in range(len(boards[0]))] for j in range(len(boards))]

    # keep track of which boards haven't won yet
    not_won_yet = list(range(len(boards)))

    # Also who won last and what the value was
    last_winner = -1
    winning_value = -1

    # loop over each value
    for value in values:
        # track who won this round
        winners_this_round = []

        # loop over boards that haven't won yet
        for i in not_won_yet:
            # if value is on the board then mark it
            if value in boards[i]:
                matches[i][boards[i].index(value)] = 1

            # if the board just won
            if is_winning_board(matches[i]):
                # mark it as a winner and save the values
                winners_this_round.append(i)
                last_winner = i
                winning_value = value

        # remove the winners from the running
        for winner in winners_this_round:
            not_won_yet.remove(winner)

    # count up the unmarked values in the last winner's board
    unmarked = [boards[last_winner][j] if not matches[last_winner][j] else 0 for j in range(len(boards[last_winner]))]

    # multiply by winning value
    return sum(unmarked) * winning_value


def is_winning_board(matches, n_row=5, n_col=5):
    """ Check if a board wins bingo"""

    # check every row
    for i in range(n_row):
        row = matches[i * n_col:(i + 1) * n_col]

        # if every value in the row matches then this board wins
        if sum(row) == n_col:
            return True

    # check every column (more annoying than rows since not contiguous)
    base_inds = list(range(0, len(matches), n_row))
    for i in range(n_col):
        col = [matches[ind + i] for ind in base_inds]

        # if every value in the col matches then this board wins
        if sum(col) == n_row:
            return True

    # otherwise this board hasn't won (yet!)
    return False


def main():
    # start up an array of boards
    boards = []
    with open("../inputs/4.txt", "r") as input:
        # get the first line of the file which contains the value that get read outs
        values = list(map(int, input.readline().split(",")))

        # start a new board
        current_board = None
        for line in input:
            # if a new line occurs, save the current board and start a new one
            if line == "\n" and current_board is not None:
                boards.append(current_board)
                current_board = None
            # otherwise flatten out the board (combine rows)
            else:
                new_row = list(map(int, line.strip("\n").split()))
                if current_board is None:
                    current_board = new_row
                else:
                    current_board.extend(new_row)

        # don't miss the last board!
        if current_board is not None:
            boards.append(current_board)

    print("PART ONE:", find_first_winner(values, boards))
    print("PART TWO:", find_last_winner(values, boards))

main()


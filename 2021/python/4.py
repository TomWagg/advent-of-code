def find_first_winner(values, boards, matches):
    for value in values:
        for i in range(len(boards)):
            if value in boards[i]:
                matches[i][boards[i].index(value)] = 1

            if is_winning_board(matches[i]):
                unmarked = [boards[i][j] if not matches[i][j] else 0 for j in range(len(boards[i]))]
                return sum(unmarked) * value
    return -1


def find_last_winner(values, boards, matches):
    not_won_yet = list(range(len(boards)))
    last_winner = -1
    winning_value = -1
    for value in values:
        new_winners = []
        for i in not_won_yet:
            if value in boards[i]:
                matches[i][boards[i].index(value)] = 1

            if is_winning_board(matches[i]):
                new_winners.append(i)
                last_winner = i
                winning_value = value

        for winner in new_winners:
            not_won_yet.remove(winner)

    unmarked = [boards[last_winner][j] if not matches[last_winner][j] else 0 for j in range(len(boards[last_winner]))]
    return sum(unmarked) * winning_value


def print_board(board):
    for i in range(5):
        print(board[i*5:(i+1)*5])


def is_winning_board(matches):
    n_row, n_col = 5, 5
    for i in range(n_row):
        row = matches[i * n_col:(i + 1) * n_col]
        if sum(row) == 5:
            return True

    base_inds = list(range(0, len(matches), n_row))
    for i in range(n_col):
        col = [matches[ind + i] for ind in base_inds]
        if sum(col) == 5:
            return True

    return False


def main():
    boards = []
    matches = []
    with open("../inputs/4.txt", "r") as input:
        values = list(map(int, input.readline().split(",")))
        current_board = None
        for line in input:
            if line == "\n" and current_board is not None:
                boards.append(current_board)
                current_board = None
            else:
                new_row = list(map(int, line.strip("\n").split()))
                if current_board is None:
                    current_board = new_row
                else:
                    current_board.extend(new_row)
    if current_board is not None:
        boards.append(current_board)

    # boards = [boards[0]]

    matches = [[0 for i in range(len(boards[0]))] for j in range(len(boards))]

    print("PART ONE:", find_first_winner(values, boards, matches))

    # reset everything
    matches = [[0 for i in range(len(boards[0]))] for j in range(len(boards))]

    print("PART TWO:", find_last_winner(values, boards, matches))

main()


from collections import defaultdict


def game_part_one(pos, win=1000):
    scores = [0, 0]
    dice = list(range(1, win))
    cursor = 0

    # loop infinitely, will return when done
    while True:
        # for each player
        for i in range(2):
            # get the deterministic dice
            roll = sum(dice[cursor:cursor + 3])
            cursor += 3

            # move the position and adjust score
            pos[i] = (pos[i] + roll) % 10
            scores[i] += (pos[i] + 1)

            # check if the player just won
            if scores[i] >= win:
                return scores[1 - i] * cursor


def game_part_two(pos, win_value=21):
    # work out the possible throw totals for use later
    rolls = [1, 2, 3]
    totals = defaultdict(int)
    for roll1 in rolls:
        for roll2 in rolls:
            for roll3 in rolls:
                totals[sum([roll1, roll2, roll3])] += 1

    # create the initial universes, index using tuple of flattened positions and scores
    active_universes = defaultdict(int)
    active_universes[(*pos, 0, 0)] = 1

    # track universes that players have won, start with player 1
    wins, turn = [0, 0], 0

    # while there are still universes with unfinished games
    while list(active_universes.keys()) != []:
        updated_universes = defaultdict(int)
        for u in active_universes:
            for throw in totals:
                pos, scores = [u[0], u[1]], [u[2], u[3]]
                pos[turn] = (pos[turn] + throw) % 10
                scores[turn] += (pos[turn] + 1)

                # check if the player just won
                if scores[turn] >= win_value:
                    wins[turn] += active_universes[u] * totals[throw]
                else:
                    updated_universes[(*pos, *scores)] += active_universes[u] * totals[throw]

        # update the current universes
        active_universes = updated_universes

        # change to other player's turn
        turn = 1 - turn

    # return the number of wins for whichever player won more
    return max(wins)


def main():
    # get starting positions (change to 0-indexed)
    pos = []
    with open("../inputs/21.txt", "r") as input:
        for line in input:
            line = line.strip()
            pos.append(int(line.split(": ")[-1]) - 1)

    print("PART ONE:", game_part_one(pos))

    # get starting positions (change to 0-indexed)
    pos = []
    with open("../inputs/21.txt", "r") as input:
        for line in input:
            line = line.strip()
            pos.append(int(line.split(": ")[-1]) - 1)

    print("PART TWO:", game_part_two(pos))


if __name__ == "__main__":
    main()

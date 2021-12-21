from collections import defaultdict
from copy import deepcopy


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


class Universe():
    def __init__(self, pos, scores):
        self.pos = pos
        self.scores = scores

    def __str__(self):
        return "state: [{}, {}], [{}, {}]".format(self.pos[0], self.pos[1], self.scores[0], self.scores[1])


def game_part_two(pos, win_value=21):
    # work out the possible throw totals
    rolls = [1, 2, 3]
    totals = defaultdict(int)
    for roll1 in rolls:
        for roll2 in rolls:
            for roll3 in rolls:
                totals[sum([roll1, roll2, roll3])] += 1

    # create the initial universes 
    active_universes = defaultdict(int)
    active_universes[Universe(pos, [0, 0])] = 1

    # initial conditions, start with player 1
    wins, turn = [0, 0], 0

    # while there are still universes with unfinished games
    while list(active_universes.keys()) != []:
        print(wins)
        updated_universes = defaultdict(int)
        for state in active_universes:
            for throw in totals:
                new_state = deepcopy(state)
                new_state.pos[turn] = (state.pos[turn] + throw) % 10
                new_state.scores[turn] += (new_state.pos[turn] + 1)

                # check if the player just won
                if new_state.scores[turn] >= win_value:
                    wins[turn] += active_universes[state] * totals[throw]
                else:
                    updated_universes[new_state] += active_universes[state] * totals[throw]

        active_universes = updated_universes
        # for state in playing_states:
        #     print(state, playing_states[state])
        # print()
        # if turn == 1:
        #     break
        turn = 1 - turn

    print(wins)
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

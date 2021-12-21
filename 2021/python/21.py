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


def main():
    # get starting positions (change to 0-indexed)
    pos = []
    with open("../inputs/21.txt", "r") as input:
        for line in input:
            line = line.strip()
            pos.append(int(line.split(": ")[-1]) - 1)

    print("PART ONE:", game_part_one(pos))


if __name__ == "__main__":
    main()

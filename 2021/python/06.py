def evolve_fish(fish_counts, days):
    # for each day of evolution
    for i in range(days):
        # keep track of how many will be spawning
        fish_spawning = fish_counts[0]

        # decrease the timers for the rest
        for j in range(len(fish_counts) - 1):
            fish_counts[j] = fish_counts[j + 1]

        # create new fish, reset the ones that just finished
        fish_counts[-1] = fish_spawning
        fish_counts[6] += fish_spawning
    return fish_counts


def main():
    # get the list of fish
    with open("../inputs/6.txt") as input:
        fish_list = list(map(int, input.readline().split(",")))

    # add counts for each unique age fish
    fish_counts = [0 for i in range(9)]
    for fish in fish_list:
        fish_counts[fish] += 1

    print("PART ONE:", sum(evolve_fish(fish_counts, days=80)))
    print("PART TWO:", sum(evolve_fish(fish_counts, days=256)))


if __name__ == "__main__":
    main()

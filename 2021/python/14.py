from collections import Counter


def polymerise(polymer, pair_insertions, steps=1):
    """ simple solution, brute force add everything """
    while steps > 0:
        # always the same starting character
        new_polymer = polymer[0]

        # run over the pairs currently in the polymer
        for i in range(len(polymer) - 1):
            # add the new pair to the polymer plus the suffix
            pair = polymer[i:i+2]
            new_polymer += pair_insertions[pair] + pair[1]
        
        # update polymer
        polymer = new_polymer

        steps -= 1
    return polymer


def main():
    # grab the original template and pair insertion map from the file
    template = None
    pair_insertions = {}
    with open("../inputs/14.txt") as input:
        template = input.readline().strip()
        for line in input:
            line = line.strip()
            if line != "":
                pair, element = line.split(" -> ")
                pair_insertions[pair] = element

    # evolve the polymer over time
    polymer = polymerise(template, pair_insertions, steps=10)

    # find the most and least common elements
    counter = Counter(polymer).most_common()
    most, least = counter[0], counter[-1]
    print("PART ONE:", most[1] - least[1])


if __name__ == "__main__":
    main()

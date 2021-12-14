from collections import defaultdict


def polymerise(polymer, pair_insertions, steps=1):
    """ better version, just keep track of counts not order """
    # count how many each element are in the original polymer
    element_counts = defaultdict(int)
    for i in range(len(polymer)):
        element_counts[polymer[i]] += 1

    # do the same for all possible pairs in the polymer
    pairs = defaultdict(int)
    for i in range(len(polymer) - 1):
        pairs[polymer[i:i+2]] += 1

    # for each step in the polymerisation
    while steps > 0:
        # create a new list of pairs
        new_pairs = defaultdict(int)
        for key in pairs:
            # add the two new pairs produced by this pair
            new_pairs[key[0] + pair_insertions[key]] += pairs[key]
            new_pairs[pair_insertions[key] + key[1]] += pairs[key]

            # add to the element count for the new element
            element_counts[pair_insertions[key]] += pairs[key]

        # update the pairs to the new pairs
        pairs = new_pairs

        steps -= 1

    # get the counts and return the difference between the max and min
    counts = element_counts.values()
    return max(counts) - min(counts)


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
    print("PART ONE:", polymerise(template, pair_insertions, steps=10))
    print("PART TWO:", polymerise(template, pair_insertions, steps=40))


if __name__ == "__main__":
    main()

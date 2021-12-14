import numpy as np


# grabbed this from here:
# https://stackoverflow.com/questions/8560440/removing-duplicate-columns-and-rows-from-a-numpy-2d-array
def unique_rows(a):
    a = np.ascontiguousarray(a)
    unique_a = np.unique(a.view([('', a.dtype)]*a.shape[1]))
    return unique_a.view(a.dtype).reshape((unique_a.shape[0], a.shape[1]))


def main():
    first = True
    positions = []
    with open("../inputs/13.txt") as input:
        # flag for whether we have reached the instructions
        instructions = False
        for line in input:
            # once we hit the blank line switch over the folding mode
            if line == "\n":
                instructions = True
                positions = np.array(positions)
                maxes = [positions[:, 0].max(), positions[:, 1].max()]
            # folding mode:
            elif instructions:
                # get the axis and folding position from the input
                axis, fold = line.strip().split("fold along ")[1].split("=")
                fold = int(fold)

                if axis not in ["x", "y"]:
                    print("ERROR: bad axis")
                    return

                i = 0 if axis == "x" else 1

                # if the fold is before the halfway point
                if fold < np.floor(maxes[i] / 2):
                    # the points to the left are now on the right
                    positions[:, i][positions[:, i] < fold] += maxes[i] - 2 * fold
                    # append points to the right to the start of the line
                    positions[:, i][positions[:, i] > fold] = maxes[i] - positions[:, i][positions[:, i] > fold]

                else:
                    # flip the points to the right
                    positions[:, i][positions[:, i] > fold] = fold - (positions[:, i][positions[:, i] > fold] - fold)

                # remove the ones along the fold
                positions = positions[positions[:, i] != fold]

                # reset the max value to the fold
                maxes[i] = fold

                # remove any duplicates
                positions = unique_rows(positions)

                # for part one we print here here
                if first:
                    print("PART ONE:", len(positions))
                    first = False
            # read in a new position of a mark
            else:
                positions.append(list(map(int, line.strip().split(","))))

    # draw the letters with dots and #'s
    letters = np.tile(".", (maxes[1] + 1, maxes[0] + 1))
    for x, y in positions:
        letters[y, x] = "#"

    # this was cool!
    print("PART TWO:")
    for letter in letters:
        print("".join(list(letter)))


if __name__ == "__main__":
    main()

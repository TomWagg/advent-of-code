# I have folded and started importing numpy haha
import numpy as np

def flash_octopuses(octopuses, steps=1):
    n_flash = 0
    while steps > 0:
        # increase every octopus energy by 1
        octopuses += 1

        # keep track of which ones flashed during this stage
        has_flashed = np.zeros_like(octopuses).astype(bool)

        # while a flash is going to occur
        while np.any(octopuses > 9):
            # find the locations of those that haven't flashed yet
            reset_these = np.where(np.logical_and(octopuses > 9, np.logical_not(has_flashed)))
            flashers = np.argwhere(np.logical_and(octopuses > 9, np.logical_not(has_flashed)))

            # add to the flashes
            n_flash += len(flashers)

            # increase the values for adjacent ones
            for row_move in [-1, 0, 1]:
                for col_move in [-1, 0, 1]:
                    adds = [[row_move, col_move]]
                    adders = flashers + adds
                    for row, col in adders:
                        if row >= 0 and row < 10 and col >= 0 and col < 10:
                            octopuses[row, col] += 1

            # keep track they flashes and reset their values
            has_flashed[reset_these] = True
            octopuses[reset_these] = 0

        # reset every octopus that flashed
        octopuses[has_flashed] = 0

        steps -= 1
    return octopuses, n_flash



def main():
    # I googled and it is octopuses not octopi: https://qz.com/1446229/let-us-finally-resolve-the-octopuses-v-octopi-debate/
    octopuses = np.zeros((10, 10)).astype(int)
    n_col = 0
    with open("../inputs/11.txt") as input:
        i = 0
        for line in input:
            octopuses[i] = np.array(list(map(int, list(line.strip()))))
            i += 1

    _, flashes = flash_octopuses(octopuses, steps=100)
    print("PART ONE:", flashes)


if __name__ == "__main__":
    main()
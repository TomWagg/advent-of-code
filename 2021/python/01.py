def main():
    # get the depths from the file (mapped to integers)
    with open("../inputs/1.txt") as input:
        depths = list(map(int, input.readlines()))

    # count how many times the depth gets larger
    larger = 0
    for i in range(1, len(depths)):
        larger += int(depths[i] - depths[i - 1] > 0)

    # print the result
    print("PART ONE:", larger)

    # PART TWO: sliding window
    larger = 0

    # start a sliding window sum
    window = sum(depths[:3])

    # loop over the depths
    for i in range(1, len(depths) - 2):
        # calculate the new window, compare and possibly add
        new_window = sum(depths[i:i + 3])
        larger += int(new_window > window)
        window = new_window

    # print the result
    print("PART TWO:", larger)


if __name__ == "__main__":
    main()

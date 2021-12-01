def main():
    # get the depths from the file (mapped to integers)
    with open("../inputs/1.txt") as input:
        depths = list(map(int, input.readlines()))

    # count how many times the depth gets larger
    larger = 0
    for i in range(1, len(depths)):
        larger += int(depths[i] - depths[i - 1] > 0)

    # print the result
    print(larger)


if __name__ == "__main__":
    main()

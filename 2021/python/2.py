def main():
    x, y = 0, 0
    with open("../inputs/2.txt") as input:
        for line in input:
            direction, magnitude = line.split()
            if direction == "forward":
                x += int(magnitude)
            elif direction == "down":
                y += int(magnitude)
            elif direction == "up":
                y -= int(magnitude)
            else:
                raise ValueError()

    print(x * y)


if __name__ == "__main__":
    main()

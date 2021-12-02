def main():
    pos, depth = 0, 0
    with open("../inputs/2.txt") as input:
        for line in input:
            direction, magnitude = line.split()
            if direction == "forward":
                pos += int(magnitude)
            elif direction == "down":
                depth += int(magnitude)
            elif direction == "up":
                depth -= int(magnitude)
            else:
                raise ValueError()

    print(pos * depth)


if __name__ == "__main__":
    main()

def move_ship(file):
    pos, depth = 0, 0
    with open(file) as input:
        for line in input:
            direction, magnitude = line.split()
            mag_int = int(magnitude)
            if direction == "forward":
                pos += mag_int
            elif direction == "down":
                depth += mag_int
            elif direction == "up":
                depth -= mag_int
            else:
                raise ValueError()

    return pos * depth


def move_ship_with_aim(file):
    pos, depth, aim = 0, 0, 0
    with open(file) as input:
        for line in input:
            direction, magnitude = line.split()
            mag_int = int(magnitude)
            if direction == "forward":
                pos += mag_int
                depth += mag_int * aim
            elif direction == "down":
                aim += mag_int
            elif direction == "up":
                aim -= mag_int
            else:
                raise ValueError()

    return pos * depth


def main():
    print("PART ONE:", move_ship("../inputs/2.txt"))
    print("PART TWO:", move_ship_with_aim("../inputs/2.txt"))


if __name__ == "__main__":
    main()

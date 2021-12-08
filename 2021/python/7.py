def find_min_fuel(positions):
    # brute force, let's try aligning at every position in the range we are given
    min_loc = min(positions)
    max_loc = max(positions)

    # start with some massive fuel usage
    min_fuel = 1e20
    for loc in range(min_loc, max_loc + 1):
        # sum up the distances for each position
        fuel_needs = sum([abs(pos - loc) for pos in positions])

        # record the minimum
        min_fuel = min(min_fuel, fuel_needs)

    # return the min
    return min_fuel


def find_min_fuel_nonlinear(positions):
    # brute force, let's try aligning at every position in the range we are given
    min_loc = min(positions)
    max_loc = max(positions)

    # start with some massive fuel usage
    min_fuel = 1e20
    for loc in range(min_loc, max_loc + 1):
        fuel_needs = 0

        # for every position in the possible range
        for pos in positions:
            # find the distance it would need to travel
            distance = abs(pos - loc)

            # turn that into a fuel usage by doing a sum of integers
            fuel_needs += (distance + 1) * distance // 2
        min_fuel = min(min_fuel, fuel_needs)

    # return the minimum
    return min_fuel


def main():
    with open("../inputs/7.txt", "r") as input:
        positions = list(map(int, input.readline().split(",")))

    print("PART ONE:", find_min_fuel(positions))
    print("PART TWO:", find_min_fuel_nonlinear(positions))


if __name__ == "__main__":
    main()

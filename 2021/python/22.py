import numpy as np


def range_inclusive(start, end):
    """ same as range but including endpoint """
    return range(start, end + 1)


def bounds_to_cubeset(bounds):
    """ turn 3D bounds into a set of tuples """
    cubes = set()
    too_big = bounds[0][0] < -50 or bounds[0][1] > 50 or bounds[1][0] < -50 \
        or bounds[1][1] > 50 or bounds[2][0] < -50 or bounds[2][1] > 50
    if too_big:
        return cubes

    for x in range_inclusive(*bounds[0]):
        for y in range_inclusive(*bounds[1]):
            for z in range_inclusive(*bounds[2]):
                cubes.add((x, y, z))
    return cubes


def part_one(operations):
    cubes = set()
    for switch, bounds in operations:
        update_cubes = bounds_to_cubeset(bounds)
        if switch == "on":
            cubes.update(update_cubes)
        else:
            cubes.difference_update(update_cubes)
    return len(cubes)


def main():
    operations = []
    with open("../inputs/22.txt", "r") as input:
        for line in input:
            line = line.strip()
            switch, str_bounds = line.split()
            str_bounds = str_bounds.split(",")

            bounds = [list(map(int, axis.split("=")[-1].split(".."))) for axis in str_bounds]
            operations.append((switch, bounds))

    print("PART ONE:", part_one(operations))


if __name__ == "__main__":
    main()

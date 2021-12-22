from collections import Counter


def find_cube_intersection(cube_a, cube_b):
    intersect_bounds = []
    for ax in range(3):
        lower_bound = max(cube_a[2 * ax], cube_b[2 * ax])
        upper_bound = min(cube_a[2 * ax + 1], cube_b[2 * ax + 1])
        if lower_bound > upper_bound:
            return None
        intersect_bounds.extend([lower_bound, upper_bound])
    return tuple(intersect_bounds)


def reboot(operations, part_one=False):
    # we can be more intelligent that just creating a set entry for every coordinate like I did before
    # let's try to keep track of "positive" cuboids and "negative" cuboids instead

    # using a Counter instead of Set to account for repeats
    cubes = Counter()

    # loop over every operation
    for switch, bounds in operations:
        # if we are doing part one then ignore operations that don't intersect with the middle bit
        if part_one and find_cube_intersection(bounds, (-50, 50, -50, 50, -50, 50)) is None:
            continue

        # start a new counter for any intersections between the new bounds and current cubes
        intersected_cubes = Counter()
        for cube in cubes:
            # if this cube intersects with the new bounds
            intersect = find_cube_intersection(cube, bounds)
            if intersect is not None:
                # add a "negative" cube to cancel out the intersection
                intersected_cubes[intersect] -= cubes[cube]

        # only when switches are on do we turn on the actual bounds
        if switch == "on":
            cubes[bounds] = 1

        # update the main cubes Counter
        cubes.update(intersected_cubes)

    # count how many cube pixels are lit
    lit_cubes = 0
    for cube in cubes:
        # get the volume of the bounding cube
        volume = 1
        for ax in range(0, len(cube), 2):
            volume *= cube[ax + 1] - cube[ax] + 1

        # increment the total by the product of the volume and value of the bounding cuboid
        lit_cubes += (volume * cubes[cube])

    return lit_cubes


def main():
    operations = []
    with open("../inputs/22.txt", "r") as input:
        for line in input:
            line = line.strip()
            switch, str_bounds = line.split()
            str_bounds = str_bounds.split(",")

            bounds = []
            for axis in str_bounds:
                bounds.extend(list(map(int, axis.split("=")[-1].split(".."))))
            bounds = tuple(bounds)
            operations.append((switch, bounds))

    print("PART ONE:", reboot(operations, part_one=True))
    print("PART TWO:", reboot(operations))


if __name__ == "__main__":
    main()

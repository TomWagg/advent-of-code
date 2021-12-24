def find_minima(heights, n_col):
    # find the local minima in the caves
    minima = []
    for i in range(len(heights)):
        min_nearest = None
        # check in the adjacent squares
        for index in [i - 1, i + 1, i - n_col, i + n_col]:
            if index > 0 and index < len(heights):
                # reset minimum
                if min_nearest is None or heights[index] < min_nearest:
                    min_nearest = heights[index]
        # add to the minima list
        if heights[i] < min_nearest:
            minima.append(i)
    return minima


def find_basin_sizes(heights, minima_inds, n_col):
    basin_sizes = [len(grow_basin(heights,
                                  ind,
                                  members=[],
                                  n_col=n_col))
                   for ind in minima_inds]
    return basin_sizes


def grow_basin(heights, position, members, n_col):
    # base case: we hit a 9 or already added this position
    if heights[position] == 9 or position in members:
        return members
    else:
        # add the new basin member
        members.append(position)

        # create a list of directions that keep it in bounds
        directions = []
        if position - n_col >= 0:
            directions.append(-n_col)
        if position + n_col < len(heights):
            directions.append(n_col)
        if position % n_col != 0:
            directions.append(-1)
        if (position + 1) % n_col != 0:
            directions.append(1)

        # check for members in those directions
        for direction in directions:
            members = grow_basin(heights, position + direction, members, n_col)
        return members


def main():
    heights = []
    n_col = 0
    with open("../inputs/9.txt") as input:
        for line in input:
            n_col = len(line.strip())
            heights.extend(list(map(int, list(line.strip()))))

    minima_inds = find_minima(heights, n_col)

    print("PART ONE:", sum([int(heights[i]) + 1 for i in minima_inds]))

    basin_sizes = find_basin_sizes(heights, minima_inds, n_col)
    top_three = sorted(basin_sizes)[-3:]
    total = top_three[0] * top_three[1] * top_three[2]

    print("PART TWO:", total)


if __name__ == "__main__":
    main()

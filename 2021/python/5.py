def count_overlaps(lines, max_x, max_y):
    # start off with nothing in the grid
    grid = [[0 for i in range(max_y + 1)] for j in range(max_x + 1)]

    for start, end in lines:
        # get coordinates
        x_i, y_i = start
        x_f, y_f = end

        # if horizontal line
        if x_i == x_f:
            # work out offset and step size (depending on direction)
            offset = -1 if y_f < y_i else 1
            step = -1 if y_f < y_i else 1

            for y in range(y_i, y_f + offset, step):
                grid[x_i][y] += 1

        # if vertical line
        elif y_i == y_f:
            # work out offset and step size (depending on direction)
            offset = -1 if x_f < x_i else 1
            step = -1 if x_f < x_i else 1
            for x in range(x_i, x_f + offset, step):
                grid[x][y_i] += 1

    # sum up the number of points that have at least 2 overlaps
    overlaps = sum([int(item >= 2) for row in grid for item in row])
    return overlaps


def main():
    lines = []
    max_x, max_y = 0, 0
    with open("../inputs/5.txt", "r") as input:
        for line in input:
            start, end = line.strip().split(" -> ")
            start, end = tuple(map(int, start.split(","))), tuple(map(int, end.split(",")))
            max_x = max(max_x, max(start[0], end[0]))
            max_y = max(max_y, max(start[1], end[1]))
            lines.append([start, end])

    print("PART ONE:", count_overlaps(lines, max_x, max_y))

if __name__ == "__main__":
    main()
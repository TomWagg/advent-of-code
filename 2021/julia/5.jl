function count_overlaps(lines, max_x, max_y)
    # start off with nothing in the grid
    grid = [[0 for i in 1:(max_y + 1)] for j in 1:(max_x + 1)]

    for line in lines
        # get coordinates
        start, final = line
        x_i, y_i = start
        x_f, y_f = final

        # slightly wasteful and do everything for x and y
        # work out step size (depending on direction)
        x_step = x_f < x_i ? -1 : 1
        x_range = x_i:x_step:x_f

        y_step = y_f < y_i ? -1 : 1
        y_range = y_i:y_step:y_f

        # if horizontal line
        if x_i == x_f
            for y in y_range
                grid[x_i][y] += 1
            end;

        # if vertical line
        elseif y_i == y_f
            # work out offset and step size (depending on direction)
            for x in x_range
                grid[x][y_i] += 1
            end;

        # if diagonal line
        else
            for xy in zip(x_range, y_range)
                x, y = xy
                grid[x][y] += 1
            end;
        end;
    end;

    # sum up the number of points that have at least 2 overlaps
    overlaps = sum([item >= 2 ? 1 : 0 for row in grid for item in row])
    return overlaps
end;


function main()
    lines = []
    max_x, max_y = 0, 0
    open("../inputs/5.txt", "r") do input
        for line in eachline(input)
            start, final = split(chomp(line), " -> ")
            start, final = tuple(parse.(Int, split(start, ","))...) .+ 1, tuple(parse.(Int, split(final, ","))...) .+ 1
            max_x = max(max_x, max(start[1], final[1]))
            max_y = max(max_y, max(start[2], final[2]))
            push!(lines, [start, final])
        end;
    end;

    println("FULL SOLUTION:", count_overlaps(lines, max_x, max_y))
end;

main()

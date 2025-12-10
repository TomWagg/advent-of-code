using Combinatorics


function part_one()
    tiles = [parse.(Int, split(line, ',')) for line in readlines("inputs/9.txt")]
    return mapreduce(x->(abs(x[1][1] - x[2][1]) + 1) * (abs(x[1][2] - x[2][2]) + 1),
                     max, combinations(tiles, 2), init=-1)
end

function overlaps(r1, r2)
    x_min_1 = min(r1[1][1], r1[2][1])
    x_min_2 = min(r2[1][1], r2[2][1])
    y_min_1 = min(r1[1][2], r1[2][2])
    y_min_2 = min(r2[1][2], r2[2][2])

    x_max_1 = max(r1[1][1], r1[2][1])
    x_max_2 = max(r2[1][1], r2[2][1])
    y_max_1 = max(r1[1][2], r1[2][2])
    y_max_2 = max(r2[1][2], r2[2][2])

    left = x_max_1 ≤ x_min_2
    right = x_min_1 ≥ x_max_2
    below = y_max_1 ≤ y_min_2
    above = y_min_1 ≥ y_max_2

    return !(left || right || below || above)
end

function part_two()
    # read in the red tiles
    tiles = [parse.(Int, split(line, ',')) for line in readlines("inputs/9.txt")]

    # define the potential rectangles and areas as part one
    rectangles = collect(combinations(tiles, 2))
    areas = map(x->(abs(x[1][1] - x[2][1]) + 1) * (abs(x[1][2] - x[2][2]) + 1), rectangles)

    # sort them in descending area to speed things up
    perm = sortperm(areas, rev=true)
    rectangles = rectangles[perm]
    areas = areas[perm]

    # define the edges based on adjacent red tiles
    edges = [[tiles[i], tiles[i + 1]] for i in 1:length(tiles) - 1]
    push!(edges, [tiles[end], tiles[1]])

    # core logic: a rectangle is only valid if it doesn't cross any edge
    # perform this check for each, returning the first valid rectangle (since we pre-sorted)
    for i in eachindex(rectangles)
        valid = true
        for e in edges
            if overlaps(rectangles[i], e)
                valid = false
                break
            end
        end
        if valid
            return areas[i]
        end
    end
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
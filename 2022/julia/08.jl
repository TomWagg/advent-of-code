function get_trees()
    # read in the trees as a matrix of ints
    trees = nothing
    open("../inputs/8.txt") do input
        i = 1
        for line in eachline(input)
            if trees == nothing
                trees = Matrix{Int64}(undef, countlines("../inputs/8.txt"), length(line))
            end
            trees[i, :] = parse.(Int, collect(line))
            i += 1
        end
    end
    return trees, size(trees, 1), size(trees, 2)
end


function part_one()
    trees, width, height = get_trees()
    n_hidden = 0

    for i in 2:width - 1
        for j in 2:height - 1
            above = any(trees[1:i - 1, j] .>= trees[i, j])
            left = any(trees[i, 1:j - 1] .>= trees[i, j])
            right = any(trees[i, j + 1:height] .>= trees[i, j])
            below = any(trees[i + 1:width, j] .>= trees[i, j])
            n_hidden += Int(above && left && right && below)
        end;
    end;
    return length(trees) - n_hidden
end;

function viewing_distance(los::Array{Int64}, height::Int64)
    # find distance along line of sight that is below height of tree
    too_high_ind = findall(los .>= height)
    if too_high_ind == Array{Int64}[]
        return length(los)
    else
        return first(too_high_ind)
    end
end

function part_two()
    trees, width, height = get_trees()
    best_scenic_score = 0

    for i in 2:width - 1
        for j in 2:height - 1
            above = viewing_distance(reverse(trees[1:i - 1, j]), trees[i, j])
            left = viewing_distance(reverse(trees[i, 1:j - 1]), trees[i, j])
            right = viewing_distance(trees[i, j + 1:height], trees[i, j])
            below = viewing_distance(trees[i + 1:width, j], trees[i, j])
            scenic_score = above * left * right * below
            best_scenic_score = max(best_scenic_score, scenic_score)
        end;
    end;
    return best_scenic_score
end;

function main()
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end

main()
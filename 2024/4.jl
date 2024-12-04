# quick and dirty

const convertor = Dict(
    'X' => 0,
    'M' => 1,
    'A' => 2,
    'S' => 3,
)
const directions = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1],
]
const p2_dirs = [
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1]
]

function part_one(word_search::Vector{Vector{Int}})
    n_found = 0
    for i in 1:length(word_search)
        for j in 1:length(word_search[i])
            if word_search[i][j] == 0
                for (v, h) in directions
                    found = true
                    for k in 1:3
                        new_row, new_col = i + k * v, j + k * h
                        out_of_bounds = new_row <= 0 || new_row > length(word_search) || new_col <= 0 || new_col > length(word_search[i])
                        if out_of_bounds || word_search[new_row][new_col] != k
                            found = false
                            break
                        end
                    end
                    n_found += found
                end
            end
        end
    end
    return n_found
end

function part_two(word_search::Vector{Vector{Int}})
    n_found = 0
    for i in 1:length(word_search)
        for j in 1:length(word_search[i])
            if word_search[i][j] == 1
                for (v, h) in p2_dirs
                    found = true
                    for k in 2:3
                        new_row, new_col = i + (k - 1) * v, j + (k - 1) * h
                        if new_row <= 0 || new_row > length(word_search) || new_col <= 0 || new_col > length(word_search[i]) || word_search[new_row][new_col] != k
                            found = false
                            break
                        end
                    end
                    if !found
                        continue
                    end
                    if word_search[i + 2 * v][j] == 1
                        v = -v
                        for k in 2:3
                            new_row, new_col = i - 2 * v + (k - 1) * v, j + (k - 1) * h
                            if new_row <= 0 || new_row > length(word_search) || new_col <= 0 || new_col > length(word_search[i]) || word_search[new_row][new_col] != k
                                found = false
                                break
                            end
                        end
                    elseif word_search[i][j + 2 * h] == 1
                        h = -h
                        for k in 2:3
                            new_row, new_col = i + (k - 1) * v, j - 2 * h + (k - 1) * h
                            if new_row <= 0 || new_row > length(word_search) || new_col <= 0 || new_col > length(word_search[i]) || word_search[new_row][new_col] != k
                                found = false
                                break
                            end
                        end
                    else
                        found = false
                    end
                    if found
                        n_found += 1
                    end
                end
            end
        end
    end
    return n_found ÷ 2
end

function main()
    lines = readlines("inputs/4.txt")
    word_search = [[convertor[c] for c in collect(line)] for line in lines]
    println("PART ONE: ", part_one(word_search))
    @time part_one(word_search)
    println("PART TWO: ", part_two(word_search))
    @time part_two(word_search)
end

main()
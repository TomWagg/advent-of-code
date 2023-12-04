function target_adjacent(loc::Int, targets::Set{Int}, n_col::Int)
    # check to the right (above, in-line and below) - if not at the end of a column
    if (mod(loc, n_col) != 0) && (loc + 1 in targets
                                  || loc + 1 + n_col in targets
                                  || loc + 1 - n_col in targets)
        return true
    end
    # check to the left (above, in-line and below) - if not at the start of a column
    if (mod(loc + 1, n_col) != 0) && (loc - 1 in targets
                                      || loc - 1 + n_col in targets
                                      || loc - 1 - n_col in targets)
        return true
    end;
    # check above and below
    if loc + n_col in targets || loc - n_col in targets
        return true
    end;
    # otherwise just false
    return false
end;

function get_input()
    n_col = 0
    input_str = ""
    open("../inputs/3.txt", "r") do input
        for line in eachline(input)
            n_col = length(line)
            input_str *= line
        end;
    end;
    
    # track the numbers + where to find them, and locations of symbols/gears
    numbers = Array{Int}(undef, 0)
    number_bounds = Array{Tuple{Int, Int}}(undef, 0)
    symbols = Set{Int}()
    gears = Set{Int}()
    
    start, finish = -1, -1
    for (cursor, c) in enumerate(input_str)
        if isnumeric(c)
            if start == -1
                start = cursor
            end;
        else
            if start != -1
                finish = cursor - 1
                push!(number_bounds, (start, finish))
                push!(numbers, parse(Int, input_str[start:finish]))
                start, finish = -1, -1
            end;

            if c != '.'
                push!(symbols, cursor)
                if c == '*'
                    push!(gears, cursor)
                end;
            end;
        end;
    end;
    return numbers, number_bounds, symbols, gears, n_col
end;

function main()
    numbers, number_bounds, symbols, gears, n_col = get_input()
    number_locs = []

    # part one
    total_part_numbers = 0
    for (i, bounds) in enumerate(number_bounds)
        low, high = bounds
        for j in low:high
            if target_adjacent(j, symbols, n_col)
                total_part_numbers += numbers[i]
                break;
            end;
        end;

        for j in low:high
            push!(number_locs, j)
        end
    end;
    @show total_part_numbers

    # part two
    gear_ratio_sum = 0
    for gear in gears
        adjacents = []
        for (i, bounds) in enumerate(number_bounds)
            low, high = bounds
            if target_adjacent(gear, Set{Int}(low:high), n_col)
                push!(adjacents, numbers[i])
            end
        end
        if length(adjacents) == 2
            gear_ratio_sum += prod(adjacents)
        end
    end;
    @show gear_ratio_sum
end;

main()
@time main()

function symbol_adjacent(loc::Int, symbols::Set, n_col::Int)
    # check to the right if not at the end of a column
    if mod(loc, n_col) != 0
        if loc + 1 in symbols
            return true
        end

        if loc + 1 + n_col in symbols
            return true
        end

        if loc + 1 - n_col in symbols
            return true
        end
    end

    # check to the left if not at the start of a column
    if mod(loc + 1, n_col) != 0
        if loc - 1 in symbols
            return true
        end;

        if loc - 1 + n_col in symbols
            return true
        end;

        if loc - 1 - n_col in symbols
            return true
        end;
    end;
    
    # check above and below
    if loc + n_col in symbols
        return true
    end;
    if loc - n_col in symbols
        return true
    end;
    return false
end;

function main()
    n_row, n_col = 0, 0
    input_str = ""
    open("../inputs/3.txt", "r") do input
        for line in eachline(input)
            n_col = length(line)
            n_row += 1
            input_str *= line
        end;
    end;
    
    numbers = []
    number_bounds = []
    symbols = Set()
    
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
            end;
        end;
    end;

    total = 0
    for (i, bounds) in enumerate(number_bounds)
        low, high = bounds
        for j in low:high
            if symbol_adjacent(j, symbols, n_col)
                total += numbers[i]
                break;
            end
        end;
    end;
    @show total
end;

main()

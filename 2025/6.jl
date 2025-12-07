function part_one()
    lines = [split(line) for line in eachline("inputs/6.txt")]
    numbers = Matrix{Int}(undef, length(lines) - 1, length(lines[1]))
    for i in 1:length(lines) - 1
        numbers[i, :] = parse.(Int, lines[i])
    end
    ops = [op == "+" ? (+) : (*) for op in lines[length(lines)]]

    return sum(reduce(popfirst!(ops), col) for col in eachcol(numbers))
end

function part_two()
    lines = [line for line in eachline("inputs/6.txt")]
    n_row, n_col = length(lines), length(lines[1])
    file = Matrix{Char}(undef, n_row, n_col)
    for i in 1:n_row
        file[i, :] = collect(lines[i])
    end

    total = 0
    numbers = Vector{Int}(undef, 0)
    j = size(file, 2)
    while j ≥ 1
        c = file[end, j]
        # need to add a number
        push!(numbers, parse.(Int, join(file[1:size(file, 1) - 1, j])))
        if c != ' '
            # operate on numbers
            op = c == '+' ? (+) : (*)
            # add to total
            # @show numbers, reduce(op, numbers), op
            total += reduce(op, numbers)
            # reset numbers
            numbers = []
            j -= 2
        else
            j -= 1
        end
    end
    return total
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
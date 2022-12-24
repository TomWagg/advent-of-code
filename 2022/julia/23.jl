using DataStructures

function has_no_neighbours(elf, elves)
    row, col = elf
    for row_offset in -1:1
        for col_offset in -1:1
            if row_offset == 0 && col_offset == 0
                continue
            end
            if [row + row_offset, col + col_offset] in elves
                return false
            end
        end
    end
    return true
end

function where_to_go(current, elves, directions)
    row, col = current

    if has_no_neighbours(current, elves)
        return current
    end

    for dir in directions
        if dir == 'N' && !([row - 1, col - 1] in elves) && !([row - 1, col] in elves) && !([row - 1, col + 1] in elves)
            return [row - 1, col]
        end
            
        if dir == 'S' && !([row + 1, col - 1] in elves) && !([row + 1, col] in elves) && !([row + 1, col + 1] in elves)
            return [row + 1, col]
        end

        if dir == 'W' && !([row + 1, col - 1] in elves) && !([row, col - 1] in elves) && !([row - 1, col - 1] in elves)
            return [row, col - 1]
        end

        if dir == 'E' && !([row + 1, col + 1] in elves) && !([row, col + 1] in elves) && !([row - 1, col + 1] in elves)
            return [row, col + 1]
        end
    end
    return current
end

function print_elves(elves, min_row, max_row, min_col, max_col)
    for row in min_row:max_row
        for col in min_col:max_col
            if [row, col] in elves
                print("#")
            else
                print(".")
            end
        end
        println()
    end
end

function part_one()
    elves = Set()
    open("../inputs/23.txt", "r") do input
        for (row, line) in enumerate(eachline(input))
            for (col, c) in enumerate(collect(line))
                if c === '#'
                    push!(elves, [row, col])
                end
            end
        end
    end

    # @show elves

    dirs = ['N', 'S', 'W', 'E']

    for round in 1:20000
        if round % 50 == 0
            @show round
        end
        new_elves = Set()
        new_to_old = DefaultDict(() -> [])
        for elf in collect(elves)
            push!(new_to_old[where_to_go(elf, elves, dirs)], elf)
        end
        for (key, val) in new_to_old
            # @show key, val
            if length(val) == 1
                push!(new_elves, key)
            else
                push!(new_elves, val[1])
                push!(new_elves, val[2])
            end
        end
        if new_elves == elves
            println("PART TWO: ", round)
            return
        end
        # println()
        # println("== End of Round ", round, " ==")
        # print_elves(new_elves, -1, 10, -2, 11)
        elves = new_elves
        dirs = circshift(dirs, -1)

        if round == 10
            min_row = 10000
            max_row = 0
            min_col = 10000
            max_col = 0
            for elf in elves
                min_row = min(elf[1], min_row)
                max_row = max(elf[1], max_row)
                min_col = min(elf[2], min_col)
                max_col = max(elf[2], max_col)
            end
            println("PART ONE: ", (max_row - min_row + 1) * (max_col - min_col + 1) - length(elves))
        end
    end

    # @show elves
end

function part_two()
    return nothing
end

part_one()
# println("PART ONE: ", part_one())
# println("PART TWO: ", part_two())
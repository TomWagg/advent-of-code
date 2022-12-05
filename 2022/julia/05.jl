function get_stacks()
    stacks = nothing
    rows = nothing
    open("../inputs/5.txt", "r") do input
        n_stacks = nothing
        for line in eachline(input)
            if line == "" || line[2] == '1'
                break
            end;
            if stacks == nothing
                n_stacks = Int((length(line) + 1) / 4)
                stacks = Array{Char}[]
                rows = Array{Char}[]
            end;
            row = Array{Char}(undef, n_stacks)
            for i in 1:n_stacks
                row[i] = line[(i * 4) - 2]
            end;
            push!(rows, row)
        end;

        # I'm lazy and can't find a better way to transpose this
        for i in 1:n_stacks
            stack = []
            for j in 1:length(rows)
                if rows[j][i] != ' '
                    push!(stack, rows[j][i])
                end;
            end;
            push!(stacks, stack)
        end;
    end;
    return stacks
end;

function part_one()
    stacks = get_stacks()
    open("../inputs/5.txt", "r") do input
        for line in eachline(input)
            if line == "" || line[2] == '1'
                break
            end;
        end;

        for line in eachline(input)
            if line != ""
                sline = split(line)
                count, from, to = parse.(Int, sline[[2, 4, 6]])

                # transfer them one at a time
                for i in 1:count
                    pushfirst!(stacks[to], popfirst!(stacks[from]))
                end;
            end;
        end;
    end;

    final_str = ""
    for i in 1:length(stacks)
        final_str *= stacks[i][1]
    end;

    return final_str
end;

function part_two()
    stacks = get_stacks()
    open("../inputs/5.txt", "r") do input
        n_stacks = nothing
        for line in eachline(input)
            if line == "" || line[2] == '1'
                break
            end;
        end;

        for line in eachline(input)
            if line != ""
                sline = split(line)
                count, from, to = parse.(Int, sline[[2, 4, 6]])
                transfer_these = first(stacks[from], count)

                # transfer them in a big ol' chunk
                deleteat!(stacks[from], 1:count)
                prepend!(stacks[to], transfer_these)
            end;
        end;
    end;

    final_str = ""
    for i in 1:length(stacks)
        final_str *= stacks[i][1]
    end;

    return final_str
end;

function main()
    # open up the input file
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end;

main()
function shape_to_score(shape)
    if shape == 'X'
        return 1
    elseif shape == 'Y'
        return 2
    elseif shape == 'Z'
        return 3
    else
        return nothing
    end;
end;

function part_one(file)
    total_score = 0
    open(file, "r") do input
        for line in eachline(input)
            opponent, you = split(line)
            opponent, you = opponent[1], you[1]
            total_score += shape_to_score(you)

            opponent = Char(Int(opponent) - 65 + 88)

            you_beats = Char(Int(you) - 1)
            if you_beats < 'X'
                you_beats = 'Z'
            end;
            if opponent == you
                total_score += 3
                # println(you, " ", opponent, " DRAW")
            elseif opponent == you_beats
                # println(you, " ", opponent, " WIN")
                total_score += 6
            else
                # println(you, " ", opponent, " LOSS")
            end;            
        end;
    end;
    return total_score
end;

function part_two(file)
    total_score = 0
    open(file, "r") do input
        for line in eachline(input)
            opponent, outcome = split(line)
            opponent, outcome = opponent[1], outcome[1]

            opponent = Char(Int(opponent) - 65 + 88)
            you = nothing

            if outcome == 'X'
                you = Char(Int(opponent) - 1)
            elseif outcome == 'Y'
                you = opponent
                total_score += 3
            elseif outcome == 'Z'
                you = Char(Int(opponent) + 1)
                total_score += 6
            end;

            if you < 'X'
                you = 'Z'
            end;
            if you > 'Z'
                you = 'X'
            end;
            total_score += shape_to_score(you)     
        end;
    end;
    return total_score
end;

function main()
    # open up the input file
    println("PART ONE: ", part_one("../inputs/2.txt"))
    println("PART TWO: ", part_two("../inputs/2.txt"))
end;

main()
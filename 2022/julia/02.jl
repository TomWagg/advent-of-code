using DelimitedFiles

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
    # read the file into a matrix of Chars and convert to Ints
    file_content = Int.(readdlm(file, ' ', Char, '\n'))

    # normalise both to 1,2,3
    file_content[:, 1] .-= 64
    file_content[:, 2] .-= 87

    # find difference between the two
    difference = file_content[:, 1] .- file_content[:, 2]

    # check the outcome in each case, by default a loss
    outcome_score = zeros(Int64, length(difference))

    # if they are the same then add 3 to the score
    outcome_score[difference .== 0] .= 3

    # if it's a win (2 is same as -1 because wrap around) then give 6
    outcome_score[difference .== -1 .|| difference .== 2] .= 6

    # return the total score from the outcome and what you play
    return sum(outcome_score) + sum(file_content[:, 2])
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
using DelimitedFiles

function part_one_vector(file)
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

function part_two_vector(file)
    # read the file into a matrix of Chars and convert to Ints
    file_content = Int.(readdlm(file, ' ', Char, '\n'))

    # normalise both to 1,2,3
    file_content[:, 1] .-= 64
    file_content[:, 2] .-= 87

    # work out what you would play to get the desired outcome
    yous = Array{Int64}(undef, length(file_content[:, 1]))
    yous[file_content[:, 2] .== 1] .= (file_content[:, 1][file_content[:, 2] .== 1] .- 1)
    yous[file_content[:, 2] .== 2] .= file_content[:, 1][file_content[:, 2] .== 2]
    yous[file_content[:, 2] .== 3] .= (file_content[:, 1][file_content[:, 2] .== 3] .+ 1)
    yous[yous .< 1] .= 3
    yous[yous .> 3] .= 1

    outcome_score = zeros(Int64, length(yous))
    outcome_score[file_content[:, 2] .== 2] .= 3
    outcome_score[file_content[:, 2] .== 3] .= 6

    # return the total score from the outcome and what you play
    return sum(outcome_score) + sum(yous)
end;

function part_one(file)
    total_score = 0
    open(file, "r") do input
        for line in eachline(input)
            opponent, you = split(line)
            opponent, you = opponent[1], you[1]
            total_score += Int(you) - Int('X') + 1

            opponent = Char(Int(opponent) - 65 + 88)

            you_beats = Char(Int(you) - 1)
            if you_beats < 'X'
                you_beats = 'Z'
            end;
            if opponent == you
                total_score += 3
            elseif opponent == you_beats
                total_score += 6
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
            total_score += Int(you) - Int('X') + 1
        end;
    end;
    return total_score
end;

function main()
    # open up the input file
    println("PART ONE: ", part_one("../inputs/2.txt"))
    println("PART TWO: ", part_two("../inputs/2.txt"))

    println("PART ONE: ", part_one_vector("../inputs/2.txt"))
    println("PART TWO: ", part_two_vector("../inputs/2.txt"))
end;

main()
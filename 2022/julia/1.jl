function main()
    # open up the input file
    elves = open("../inputs/1.txt", "r") do input
        # create an elf array and append a list of calories for each elf
        elves = []
        calories = []
        for line in eachline(input)
            if line == ""
                push!(elves, calories)
                calories = Array{Int64}(undef, 0)
            else
                push!(calories, parse(Int, line))
            end;
        end;
        elves
    end;

    sorted_total_cals = sort(sum.(elves), rev=true)
    println("PART ONE: ", sorted_total_cals[1])
    println("PART TWO: ", sum(sorted_total_cals[1:3]))
end;

main()
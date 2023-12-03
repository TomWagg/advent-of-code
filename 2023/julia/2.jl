function read_games()
    # games = open("../inputs/2.txt", "r") do input
    games = open("/home/tom/Downloads/input.txt", "r") do input
        games = Array{Dict{String, Int}}(undef, 0)
        for line in eachline(input)
            # trim off the "Game X:", then replace the semicolons with commas because it doesn't matter
            draws = replace(strip(split(line, ":")[2]), ";" => ",")
            draw_values = Dict{String, Int}("red" => 0, "green" => 0, "blue" => 0)

            # go through each draw and update the max number of cubes for that colour
            for value in eachsplit(draws, ",")
                n_cubes, colour = split(strip(value), " ")
                draw_values[colour] = max(parse(Int, n_cubes), draw_values[colour])
            end;

            # save this game and move on
            push!(games, draw_values)
        end;
        games
    end;
    return games
end;

function main()
    # read in the games
    games = read_games()

    possible = 0
    power = 0
    for i in eachindex(games)
        # if the game is possible then add its ID to the total
        if games[i]["red"] <= 12 && games[i]["green"] <= 13 && games[i]["blue"] <= 14
            possible += i
            @show i
        end;

        # track the total power as the product of the max number of cubes for each colour
        power += (games[i]["red"] * games[i]["green"] * games[i]["blue"])
    end;
    @show possible
    @show power
end;

main()

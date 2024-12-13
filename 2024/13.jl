const regex = r"((?<=\+)|(?<=\=))(?<x>\d+).*((?<=\+)|(?<=\=))(?<y>\d+)"

function game_solution(game::Vector{Int}, offset::Int)
    # use linear algebra to solve equations, only keep integer solutions
    xa, ya, xb, yb, nx, ny = game
    A = [xa xb; ya yb]
    res = [nx; ny] .+ offset
    sol = round.(Int, A \ res)
    return A * sol == res ? sol[1] * 3 + sol[2] : 0
end

function how_many_presses()
    # read in groups of inputs, convert each to 6 integers with regular expressions
    groups = split(read("inputs/13.txt", String), "\n\n")
    games = [mapreduce(x->parse.(Int, match(regex, x).captures[[2, 4]]), vcat, split(group, "\n"))
             for group in groups]
    return sum(game_solution(game, 0) for game in games), sum(game_solution(game, 10000000000000) for game in games)
end

function main()
    println("BOTH PARTS: ", how_many_presses())
    @time how_many_presses()
end

main()
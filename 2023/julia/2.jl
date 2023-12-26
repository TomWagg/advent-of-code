using DataStructures

const game_regex = r"(?<count>[0-9]+) (?<colour>\bred\b|\bgreen\b|\bblue\b)"
games = []
for str in eachsplit(read("../inputs/2.txt", String), '\n')
    game = DefaultDict(0)
    for (count, colour) in eachmatch(game_regex, str)
        game[colour] = max(game[colour], parse(Int, count))
    end
    push!(games, game)
end

possible = mapreduce(((i, g), )->(g["red"] <= 12 && g["green"] <= 13 && g["blue"] <= 14) ? i : 0, +, enumerate(games))
power = mapreduce(g->prod(values(g)), +, games)
@show possible
@show power
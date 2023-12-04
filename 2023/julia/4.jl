function main()
    # track the total points and number of matches for each scratchcard
    points, matches = 0, Array{Int}(undef, 0)
    open("../inputs/4.txt", "r") do input
        for line in eachline(input)
            # parse the scratchcards and split into winners and guesses
            scratchcards = strip.(split(strip(split(line, ":")[2]), "|"))
            winners = Set(parse.(Int, split(scratchcards[1])))
            guesses = Set(parse.(Int, split(scratchcards[2])))

            # track number of matching guesses, update points based on this
            n_match = length(intersect(winners, guesses))
            points += n_match > 0 ? 2^(n_match - 1) : 0
            push!(matches, n_match)
        end
    end

    # keep track of how many of each scratchcard you have
    copies = ones(Int, length(matches))
    for i in eachindex(matches)
        # if card has at least one match, add copies of the subsequent n_match scratchcards
        if matches[i] > 0
            copies[i + 1:i + matches[i]] .+= copies[i]
        end
    end

    println("PART ONE: ", points)
    println("PART TWO: ", sum(copies))
end
main()

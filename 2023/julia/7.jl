# using DelimitedFiles
# using BenchmarkTools

function get_input()
    hands, bids = Array{Array{Int}}(undef, 0), Array{Int}(undef, 0)
    open("../inputs/7.txt", "r") do input
        for line in eachline(input)
            og_hand, bid = split(line)
            hand = parse.(Int, replace(collect(og_hand), 'T' => "10", 'J' => "11", 'Q' => "12", 'K' => "13", 'A' => "14"))
            push!(hands, hand)
            push!(bids, parse.(Int, bid))
        end
    end
    return hands, bids
end

translator = Dict(
    1 => "high card",
    2 => "one pair",
    3 => "two pairs",
    4 => "three of a kind",
    5 => "full house",
    6 => "four of a kind",
    7 => "five of a kind"
)

function part_one()
    hands, bids = get_input()

    strengths = zeros(Int, length(hands))
    for (i, hand) in enumerate(hands)
        u_hand = unique(hand)
        c_hand = [count(==(element), hand) for element in u_hand]

        if length(u_hand) == 1
            # 5 of a kind
            strengths[i] = 7
        elseif length(u_hand) == 2
            if 4 in c_hand
                # four of a kind
                strengths[i] = 6
            else
                # full house
                strengths[i] = 5
            end
        elseif length(u_hand) == 3
            if 3 in c_hand
                # three of a kind
                strengths[i] = 4
            else
                # two pairs
                strengths[i] = 3
            end
        elseif length(u_hand) == 4
            # one pair
            strengths[i] = 2
        else
            # high card
            strengths[i] = 1
        end

        # @show hand, translator[strengths[i]]

    end

    grouped_hands = [hands[strengths .== i] for i in 1:7]
    grouped_bids = [bids[strengths .== i] for i in 1:7]
    # @show grouped_hands[3]
    # @show sort(grouped_hands[3])

    winnings = 0
    rank = 1

    for (group, bid) in zip(grouped_hands, grouped_bids)
        if length(group) > 0
            sorted_bids = bid[sortperm(group)]
            for sb in sorted_bids
                winnings += sb * rank
                rank += 1
            end
        end
    end

    return winnings
end

function part_two()
    nothing = get_input()
    return nothing
end

function main()
    println("PART ONE: ", part_one())
    # @time part_one()
    # println("PART TWO: ", part_two())
    # @time part_two()
end

main()
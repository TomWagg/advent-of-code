using BenchmarkTools

function get_input(J_replace::String="11")
    hands, bids = Array{Array{Int}}(undef, 0), Array{Int}(undef, 0)
    open("../inputs/7.txt", "r") do input
        for line in eachline(input)
            og_hand, bid = split(line)
            # convert any face cards to their numerical values (jokers do weird things for part two)
            hand = parse.(Int, replace(collect(og_hand),
                                       'T' => "10", 'J' => J_replace,
                                       'Q' => "12", 'K' => "13", 'A' => "14"))
            push!(hands, hand)
            push!(bids, parse.(Int, bid))
        end
    end
    return hands, bids
end

function get_hand_strength(hand::Array{Int})
    # find the unique cards and their counts
    u_hand = unique(hand)
    c_hand = [count(i->i == element, hand) for element in u_hand]

    # work out the strength of the hand
    if length(u_hand) == 1
        return 7                        # 5 of a kind
    elseif length(u_hand) == 2
        if 4 in c_hand
            return 6                    # 4 of a kind
        else
            return 5                    # full house
        end
    elseif length(u_hand) == 3
        if 3 in c_hand
            return 4                    # 3 of a kind
        else
            return 3                    # two pairs
        end
    elseif length(u_hand) == 4
        return 2                        # one pair
    else
        return 1                        # high card
    end
end

function convert_jokers(hand::Array{Int})
    """Convert a hand with jokers to the most valuable hand possible."""
    # if there are any jokers in the hand (but not all jokers)
    if any(hand .== 1) && ~all(hand .== 1)
        # remove jokers from the hand and find the most common non-joker card
        no_joker_hand = hand[hand .!= 1]
        u_hand = unique(no_joker_hand)
        c_hand = [count(==(element), no_joker_hand) for element in u_hand]

        # replace jokers with the most common non-joker card
        hand[hand .== 1] .= u_hand[c_hand .== maximum(c_hand)][1]
    end
    return hand
end

function get_winnings(hands, strengths, bids)
    """Calculate the total winnings for a set of hands, strengths and bids."""
    # group the hands and bids by their strengths
    grouped_hands = [hands[strengths .== i] for i in 1:7]
    grouped_bids = [bids[strengths .== i] for i in 1:7]

    # track the total winnings and the rank of the next hand
    winnings, rank = 0, 1
    for (group, bid) in zip(grouped_hands, grouped_bids)
        if length(group) > 0
            # sort the bids within each group and add to the winnings
            sorted_bids = bid[sortperm(group)]
            for sb in sorted_bids
                winnings += sb * rank
                rank += 1
            end
        end
    end
    return winnings
end

function part_one()
    hands, bids = get_input("11")
    return get_winnings(hands, [get_hand_strength(hand) for hand in hands], bids)
end

function part_two()
    hands, bids = get_input("1")
    return get_winnings(hands, [get_hand_strength(convert_jokers(copy(hand))) for hand in hands], bids)
end

function main()
    println("PART ONE: ", part_one())
    @btime part_one()
    println("PART TWO: ", part_two())
    @btime part_two()
end

main()

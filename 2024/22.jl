using DataStructures

const mix(a, b) = a ⊻ b
const prune(a) = a % 16777216

function evolve_number(secret::Int, loops::Int)
    """Evolve a `secret` for `loops` steps and save the last digit at each step as the price"""
    prices = zeros(Int, loops + 1)
    prices[1] = parse(Int, string(secret)[end])
    for i in 1:loops
        secret = prune(mix(secret, secret * 64))
        secret = prune(mix(secret, secret ÷ 32))
        secret = prune(mix(secret, secret * 2048))
        prices[i + 1]  = parse(Int, string(secret)[end])
    end
    return secret, prices
end

function sol()
    secret_total, latest_buyer, total_bananas = 0, DefaultDict(0), DefaultDict(0)
    for (buyer_ind, secret) in enumerate(parse(Int, line) for line in eachline("inputs/22.txt"))
        # evolve each secret over the day and update total for P1
        final_secret, prices = evolve_number(secret, 2000)
        secret_total += final_secret

        # find the difference in prices
        diffs = diff(prices)
        for i in 4:length(diffs)
            # for each sequence of 4 price changes
            key = diffs[i - 3:i]

            # if this buyer hasn't seen it yet
            if latest_buyer[key] != buyer_ind
                # log that this buyer has seen it and update the total bananas
                latest_buyer[key] = buyer_ind
                total_bananas[key] += prices[i + 1]
            end
        end
    end
    # the answer for P2 is then just the maximum for total bananas
    return secret_total, maximum(values(total_bananas))
end

println("BOTH PARTS: ", sol())
@time sol()
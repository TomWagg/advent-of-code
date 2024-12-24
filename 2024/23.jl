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

function bron_kerbosch(R::Set, P::Set, X::Set, lan_party, edges)
    if isempty(P) && isempty(X)
        if length(R) > length(lan_party)
            lan_party = [v for v ∈ R]
        end
        return lan_party
    end

    for v ∈ P
        lan_party = bron_kerbosch(
            union(R, [v]),
            intersect(P, edges[v]),
            intersect(X, edges[v]),
            lan_party,
            edges
        )
        delete!(P, v)
        push!(X, v)
    end
    return lan_party
end

function sol()
    vertices = Set()
    edges = DefaultDict(Set)
    for (left, right) in (split(line, "-") for line in eachline("inputs/23.txt"))
        push!(edges[left], right)
        push!(edges[right], left)
        push!(vertices, left)
        push!(vertices, right)
    end
    
    groups = Set()
    for (key, vals) in edges
        if key[1] == 't'
            for val1 in vals
                for val2 in vals
                    if val2 ∈ edges[val1]
                        push!(groups, sort([key, val1, val2]))
                    end
                end
            end
        end
    end
    lan_party = bron_kerbosch(Set(), vertices, Set(), [], edges)
    return length(groups), join(sort(lan_party), ",")
end

println("BOTH PARTS: ", sol())
@time sol()
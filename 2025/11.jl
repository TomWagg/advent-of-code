using Memoization

@memoize function n_paths(edges, source, sink, must_contain, contains)
    """Count the number of paths between a source and a sink given a set of edges, enforcing that the path
    must contain certain nodes (and already contains a subset of them)."""
    # if we've hit the target, return 1 only if we've hit every essential node along the way
    if source == sink
        return all(contains)
    end
    
    # count how many paths one can take between the current source and sink
    n = 0
    for e in edges[source]
        # if the edge is in the required set, track that we've hit it
        new_contains = e ∈ must_contain ? contains .|| (must_contain .== e) : contains

        # recursively search for the number of edges
        n += n_paths(edges, e, sink, must_contain, new_contains)
    end
    return n
end

function main()
    edges = Dict{AbstractString}{Vector{AbstractString}}()
    for (from, to) in split.(eachline("inputs/11.txt"), ": ")
        edges[from] = [s for s in eachsplit(to)]
    end

    part_one() = n_paths(edges, "you", "out", [], [])
    part_two() = n_paths(edges, "svr", "out", ["dac", "fft"], falses(2))

    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
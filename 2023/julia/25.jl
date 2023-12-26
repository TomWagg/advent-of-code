function get_wires()
    """Convert the input into a set of vertices and a list of edges between them"""
    lines = split(read("../inputs/25.txt", String), '\n')
    vertices = Set{String}(reduce(union, split.(replace.(lines, ":"=>""))))
    edges = reduce(vcat, [(from, to) for (from, to_list) in split.(lines, ": ") for to in split(to_list)])
    return vertices, edges
end

function contract(vertices::Set{String}, edges::Vector{Tuple{SubString{String}, SubString{String}}})
    """Contract the edges of a graph following the Karger algorithm"""
    # track the group of vertices that each contract vertex represents (to begin with just itself)
    vertices_groups = Dict(v=>Set([v]) for v in vertices)

    # continue until only two groups remain
    while length(keys(vertices_groups)) > 2
        # draw a random edge, we are going to merge both of these vertices into "from"
        from, to = rand(edges)

        # "from" now represents the union of both vertices' collections, delete "to" from the groups list
        vertices_groups[from] = union(vertices_groups[from], vertices_groups[to])
        delete!(vertices_groups, to)

        # remove any edges between from & to
        filter!(e->!((e[1] == from && e[2] == to) || (e[1] == to && e[2] == from)), edges)

        # transform any "to"s in edges to "from"s
        map!(e->((e[1] == to ? from : e[1]), (e[2] == to ? from : e[2])), edges, edges)
    end
    return vertices_groups, edges
end

function which_3_wires(vertices::Set{String}, edges::Vector{Tuple{SubString{String}, SubString{String}}})
    """Perform random contractions until you find one that results in two groups connected by only three edges
    
    This represents the two groups that can be split apart by cutting only 3 wires. The algorithm is
    non-deterministic, but takes ≈1 minute to run"""
    while true
        # perform a random contraction
        vertices_groups, final_edges = contract(copy(vertices), copy(edges))

        # if every group has at least 2 members and there are 3 wires then we're done
        if all(length(v) > 1 for v in values(vertices_groups)) && length(final_edges) == 3
            # return the product of the size of the groups
            return mapreduce(g->length(g), *, values(vertices_groups))
        end
    end
end

vertices, edges = get_wires()
@show which_3_wires(vertices, edges)
@time which_3_wires(vertices, edges)
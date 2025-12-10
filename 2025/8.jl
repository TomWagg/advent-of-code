using DataStructures
using Combinatorics

function dfs(edges, visited, start, circuit)
    visited[start] = true
    push!(circuit, start)
    for e in edges[start]
        if !visited[e]
            dfs(edges, visited, e, circuit)
        end
    end
end

function get_circuits(nodes, edges)
    visited = falses(length(nodes))
    res = []

    for i in eachindex(nodes)
        if !visited[i]
            circuit = []
            dfs(edges, visited, i, circuit)
            push!(res, circuit)
        end
    end
    return res
end

function part_one()
    lines = readlines("inputs/8.txt")
    coords = Matrix{Int}(undef, length(lines), 3)
    for i in eachindex(lines)
        coords[i, :] = parse.(Int, split(lines[i], ","))
    end
    distances = [(i, j, sum((coords[i, :] .- coords[j, :]).^2))
                 for (i, j) in combinations(collect(1:size(coords, 1)), 2)]
    sorted_distances = sort(distances, by=x->x[3])

    nodes = collect(1:size(coords, 1))
    edges = DefaultDict(Vector)
    connections = 0
    while connections < 1000
        (i, j, d) = popfirst!(sorted_distances)

        if i ∉ edges[j]
            push!(edges[i], j)
            push!(edges[j], i)
            connections += 1
        end
    end

    res = get_circuits(nodes, edges)
    circuit_lengths = [length(c) for c in res]
    return reduce(*, sort(circuit_lengths, rev=true)[1:3])
end

function part_two()
    lines = readlines("inputs/8.txt")
    coords = Matrix{Int}(undef, length(lines), 3)
    for i in eachindex(lines)
        coords[i, :] = parse.(Int, split(lines[i], ","))
    end
    distances = [(i, j, sum((coords[i, :] .- coords[j, :]).^2))
                 for (i, j) in combinations(collect(1:size(coords, 1)), 2)]
    sorted_distances = sort(distances, by=x->x[3])

    nodes = collect(1:size(coords, 1))
    edges = DefaultDict(Vector)
    connections = 0

    i, j = -1, -1

    while connections < 100000
        (i, j, d) = popfirst!(sorted_distances)

        if i ∉ edges[j]
            push!(edges[i], j)
            push!(edges[j], i)
            connections += 1
        end

        visited = falses(length(nodes))
        dfs(edges, visited, 1, [])
        if all(visited)
            break
        end
    end
    return coords[i, 1] * coords[j, 1]
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
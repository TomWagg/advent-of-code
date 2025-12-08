using DataStructures

function part_one()
    # edges = DefaultDict{Tuple{Int, Int}, Set{Tuple{Int, Int}}}(Set{Tuple{Int, Int}})
    edges = DefaultDict(Set)
    start = nothing
    row = 1

    y_max = nothing

    for line in eachline("inputs/7.txt")
        y_max = length(line)
        for col in 1:length(line)
            if line[col] == '^'
                push!(edges[(row, col)], (row + 1, col - 1))
                push!(edges[(row, col)], (row + 1, col + 1))
            else
                push!(edges[(row, col)], (row + 1, col))
                if line[col] == 'S'
                    start = (row, col)
                end
            end
        end
        row += 1
    end

    x_max = row - 1

    n_splits = 0
    
    queue = [start]
    visits = DefaultDict(0)
    while length(queue) > 0
        node = pop!(queue)
        visits[node] += 1
        if length(edges[node]) == 2
            n_splits += 1
        end
        for e in edges[node]
            if visits[e] == 0
                push!(queue, e)
            end
        end
    end

    total = 0
    for v ∈ keys(visits)
        if v[1] == x_max && v[2] ≥ 1 && v[2] ≤ y_max
            total += 1
            # @show v, visits[v]
        end
    end
    return n_splits
end

function part_two()
    # edges = DefaultDict{Tuple{Int, Int}, Set{Tuple{Int, Int}}}(Set{Tuple{Int, Int}})
    edges = DefaultDict(Set)
    start = nothing
    row = 1

    y_max = nothing

    for line in eachline("inputs/7.txt")
        y_max = length(line)
        for col in 1:length(line)
            if line[col] == '^'
                push!(edges[(row, col)], (row + 1, col - 1))
                push!(edges[(row, col)], (row + 1, col + 1))
            else
                push!(edges[(row, col)], (row + 1, col))
                if line[col] == 'S'
                    start = (row, col)
                end
            end
        end
        row += 1
    end

    x_max = row - 1

    
    # queue = [start]
    visits = DefaultDict(0)
    # timelines = DefaultDict(1)
    # while length(queue) > 0
    #     node = popfirst!(queue)
    #     if node ∈ queue
    #         # @show node, timelines[node], visits[node], "skip for now"
    #         timelines[node] += 1
    #     else
    #         # @show node, timelines[node], visits[node], "last one found"
    #         for e in edges[node]
    #             if visits[e] == 0
    #                 push!(queue, e)
    #                 timelines[e] = timelines[node]
    #             else
    #                 timelines[e] += timelines[node]
    #             end
    #         end
    #         visits[node] += timelines[node]
    #     end
    # end

    visits[start] = 1
    for i in 1:x_max
        for j in 1:y_max
            if length(edges[(i, j)]) == 2
                visits[(i + 1, j - 1)] += visits[(i, j)]
                visits[(i + 1, j + 1)] += visits[(i, j)]
            elseif length(edges[(i, j)]) == 1
                visits[(i + 1, j)] += visits[(i, j)]
            end
        end
    end

    # for i in 1:x_max
    #     for j in 1:y_max
    #         print(visits[(i, j)] > 0 ? string(visits[(i, j)]) : '.')
    #     end
    #     print('\n')
    # end
    # @show visits

    total = 0
    for v ∈ keys(visits)
        if v[1] == x_max && v[2] ≥ 1 && v[2] ≤ y_max
            # @show v, visits[v]
            total += visits[v]
        end
    end
    return total
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
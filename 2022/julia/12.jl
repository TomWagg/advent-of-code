using Graphs

function create_graph()
    heights = []
    n_col = 0
    n_row = 0
    start_ind = nothing
    end_ind = nothing
    open("../inputs/12.txt", "r") do input
        for line in eachline(input)
            n_col = length(line)
            n_row += 1
            row = collect(line)
            for j in 1:length(row)
                if row[j] == 'S'
                    push!(heights, Int('a'))
                    start_ind = length(heights)
                elseif row[j] == 'E'
                    push!(heights, Int('z'))
                    end_ind = length(heights)
                else
                    push!(heights, Int(row[j]))
                end
            end
        end
    end

    g = SimpleDiGraph(length(heights), 0)
    for i in 1:length(heights)
        if i % n_col != 1 && heights[i] >= heights[i - 1] - 1
            add_edge!(g, i, i - 1)
        end
        if i % n_col != 0 && heights[i] >= heights[i + 1] - 1
            add_edge!(g, i, i + 1)
        end
        if i / n_col > 1 && heights[i] >= heights[i - n_col] - 1
            add_edge!(g, i, i - n_col)
        end
        if i / n_col < n_row - 1 && heights[i] >= heights[i + n_col] - 1
            add_edge!(g, i, i + n_col)
        end
    end
    return g, heights, start_ind, end_ind
end

function get_dat_signal()
    g, heights, start_ind, end_ind = create_graph()
    println("PART ONE: ", length(a_star(g, start_ind, end_ind)))

    smallest = 10000
    potential_start_inds = findall(x->x==Int('a'), heights)
    for i in 1:length(potential_start_inds)
        path = length(a_star(g, potential_start_inds[i], end_ind))
        if path > 0
            smallest = min(path, smallest)
        end
    end
    println("PART TWO: ", smallest)
end

get_dat_signal()
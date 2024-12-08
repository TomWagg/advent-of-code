using DataStructures
using Combinatorics

function get_input()
    nodes = DefaultDict{Char, Vector{Tuple{Int, Int}}}(Vector{Tuple{Int, Int}})
    lines = readlines("inputs/8.txt")
    for i in eachindex(lines)
        cols = collect(lines[i])
        for j in eachindex(cols)
            if cols[j] != '.'
                push!(nodes[cols[j]], (i, j))
            end
        end
    end
    return nodes, length(lines), length(lines[1])
end

function part_one()
    nodes, h, w = get_input()
    anti_nodes = Set{Tuple{Int, Int}}()
    for n in values(nodes)
        for (left, right) in combinations(n, 2)
            dx = right[1] - left[1]
            dy = right[2] - left[2]
            for option in [(right[1] + dx, right[2] + dy), (left[1] - dx, left[2] - dy)]
                if option[1] > 0 && option[1] <= h && option[2] > 0 && option[2] <= w
                    push!(anti_nodes, option)
                end
            end
        end
    end
    return length(anti_nodes)
end

function part_two()
    nodes, h, w = get_input()
    anti_nodes = Set{Tuple{Int, Int}}()
    for n in values(nodes)
        for (left, right) in combinations(n, 2)
            dx = right[1] - left[1]
            dy = right[2] - left[2]
            for dir in (1, -1)
                i = 0
                while true
                    new_x = right[1] + dir * i * dx
                    new_y = right[2] + dir * i * dy
                    if new_x > 0 && new_x <= h && new_y > 0 && new_y <= w
                        push!(anti_nodes, (new_x, new_y))
                        i += 1
                    else
                        break
                    end
                end
            end
        end
    end
    return length(anti_nodes)
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
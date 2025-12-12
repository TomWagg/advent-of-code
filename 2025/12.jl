# This is very dumb, but it works.

function part_one()
    lines = readlines("inputs/12.txt")
    areas = []
    i = 1
    while i ≤ length(lines)
        if length(split(lines[i], ":")[1]) > 1
            break
        end
        push!(areas, sum(sum(collect(lines[j]) .== '#' for j in i + 1:i + 3)))
        i += 5
    end
    total = 0
    while i ≤ length(lines)
        (box_size, blocks) = split(lines[i],  ": ")
        box_area = prod(parse.(Int, split(box_size, "x")))
        block_inds = parse.(Int, split(blocks))
        total += sum(areas[i] * block_inds[i] for i in eachindex(block_inds)) ≤ box_area
        i += 1
    end
    return total
end

println("PART ONE: ", part_one())
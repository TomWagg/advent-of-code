using DataStructures

function get_input()
    switch = false
    ordering = DefaultDict{Int, Vector{Int}}(Vector{Int})
    updates = []
    open("inputs/5.txt", "r") do input
        for line in eachline(input)
            if line == ""
                switch = true
            elseif switch
                push!(updates, parse.(Int, split(line, ",")))
            else
                (left, right) = parse.(Int, split(line, "|"))
                push!(ordering[left], right)
            end
        end
    end
    return ordering, updates
end

function update_is_valid(update::Vector{Int}, ordering::DefaultDict{Int, Vector{Int}})
    # check whether an update is valid given an ordering dictionary
    valid = true
    indices = Dict()
    for (i, val) in enumerate(update)
        indices[val] = i
    end

    # go through each key in the order
    for (k, vals) in ordering
        # if the key is part of the ordering
        if k ∈ keys(indices)
            left = indices[k]
            # confirm that all of its values are to its right
            if !all([v ∉ keys(indices) || left < indices[v] for v in vals])
                valid = false
                break
            end
        end
    end
    return valid
end

function part_one()
    ordering, updates = get_input()
    total = 0
    for update in updates
        if update_is_valid(update, ordering)
            total += update[length(update) ÷ 2 + 1]
        end
    end
    return total
end

function part_two()
    ordering, updates = get_input()
    total = 0
    for update in updates
        # find any invalid update
        if !update_is_valid(update, ordering)
            # prepare a newly sorted update and remaining things to sort
            new_update = []
            sort_me = Set(update)

            # go through the remaining values
            while length(sort_me) > 0
                # check each item that could be sorted
                for item in sort_me
                    # if every other item is to its right then this must be the next one
                    cond = [item == other_item || other_item ∈ ordering[item] for other_item in sort_me]
                    if all(cond)
                        setdiff!(sort_me, item)
                        push!(new_update, item)
                    end
                end

                # should probably have condition here if no solution but I'm assuming there is one
            end
            total += new_update[length(new_update) ÷ 2 + 1]
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
function get_input()
    mins, maxes, targets, passwords = [], [], [], []
    open("../inputs/2.txt", "r") do input
        for line in eachline(input)
            other, password = split(line, ": ")
            lim_string, target = split(other)
            lims = parse.(Int, split(lim_string, "-"))
            push!(mins, lims[1])
            push!(maxes, lims[2])
            push!(targets, target[1])
            push!(passwords, password)
        end
    end
    return mins, maxes, targets, passwords
end

function part_one()
    mins, maxes, targets, passwords = get_input()

    valids = 0
    for i in eachindex(passwords)
        valids += (mins[i] <= sum(collect(passwords[i]) .== targets[i]) <= maxes[i])
    end
    return valids
end

function part_two()    
    mins, maxes, targets, passwords = get_input()

    valids = 0
    for i in eachindex(passwords)
        mask = collect(passwords[i]) .== targets[i]
        valids += mask[mins[i]] ⊻ mask[maxes[i]]
    end
    return valids 
end

function main()
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end

main()
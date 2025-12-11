# using LinearSolve

function presses_necessary(state::BitVector, buttons::Vector{Vector{Int}},
                           presses_so_far::Int, goal::Vector{Bool}, cache)
    if all(state .== goal)
        return presses_so_far
    end

    min_presses = 10000
    for (i, button) in enumerate(buttons)
        new_state = copy(state)
        new_state[button] .= .!new_state[button]
        new_buttons = copy(buttons)
        deleteat!(new_buttons, i)

        if (new_state, new_buttons) ∉ keys(cache)
            new_presses = presses_necessary(new_state, new_buttons, presses_so_far + 1, goal, cache)
            cache[(new_state, new_buttons)] = new_presses
        end

        min_presses = min(min_presses, cache[(new_state, new_buttons)])
    end
    return min_presses
end

function part_one()
    total = 0
    things = []
    for line in readlines("inputs/10.txt")
        split_line = split(line)
        indicators = split_line[1]
        buttons_str = split_line[2:length(split_line) - 1]

        goal = [c == '#' for c in indicators[2:length(indicators) - 1]]
        buttons = [parse.(Int, split(b[2:length(b) - 1], ',')) .+ 1 for b in buttons_str]

        cache = Dict{Tuple{BitVector, Vector{Vector{Int}}}, Int}()
        x =  presses_necessary(falses(length(goal)), buttons, 0, goal, cache)
        total += x
        push!(things, x)
    end
    # @show things
    return total
end

function joltage_presses_necessary(current_joltage, input_buttons,
                                   presses_so_far, goal, cache)
    buttons = copy(input_buttons)
    if all(current_joltage .== goal)
        return presses_so_far
    end

    if any(current_joltage .> goal)
        @show "This one is impossible"
        return 1000000
    end

    min_presses = 1000000
    n_deletions = 0

    for (i, button) in enumerate(buttons)
        # @show buttons
        new_joltage = copy(current_joltage)
        new_joltage[button] .+= 1

        # if this is true, shouldn't have pressed this button, never should again
        if any(new_joltage .> goal)
            deleteat!(buttons, i - n_deletions)
            n_deletions += 1
        else
            if (new_joltage, buttons) ∉ keys(cache)
                new_presses = joltage_presses_necessary(new_joltage, buttons, presses_so_far + 1, goal, cache)
                cache[(new_joltage, buttons)] = new_presses
            end

            min_presses = min(min_presses, cache[(new_joltage, buttons)])
        end
    end
    return min_presses
end

function part_two()
    total = 0
    for line in readlines("inputs/10.txt")
        split_line = split(line)
        # indicators = split_line[1]
        buttons_str = split_line[2:length(split_line) - 1]
        joltage = split_line[end]

        goal = [parse(Int, j) for j in eachsplit(joltage[2:length(joltage) - 1], ',')]
        buttons = [parse.(Int, split(b[2:length(b) - 1], ',')) .+ 1 for b in buttons_str]

        goal = reshape(goal, length(goal), 1)

        sort!(buttons, by=x->length(x), rev=true)

        cache = Dict()

        total += joltage_presses_necessary(zeros(Int, length(goal)), buttons, 0, goal, cache)
    end
    return total
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    # println("PART TWO: ", part_two())
    # @time part_two()
end

main()

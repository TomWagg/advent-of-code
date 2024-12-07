# quick function to check divisibility
can_divide(m::Int, n::Int) = iszero(m % n)

function sol()
    p1, p2 = 0, 0
    open("inputs/7.txt", "r") do input
        for line in eachline(input)
            (goal, numbers) = split(line, ": ")
            goal = parse(Int, goal)
            numbers = parse.(Int, split(numbers, " "))
            if can_reach_goal(goal, numbers, false)
                p1 += goal
            end
            if can_reach_goal(goal, numbers, true)
                p2 += goal
            end
        end
    end
    return p1, p2
end

function can_reach_goal(goal::Int, numbers::Vector{Int}, p2=false)
    # stack some options, we're going to reverse solve this
    stack = [(goal, numbers)]
    while length(stack) > 0
        # try the next option
        (g, n) = pop!(stack)

        # base case, solution found if they are equal
        if length(n) == 1
            if g == n[1]
                return true
            end
        else
            # create a new num list without the last value
            new_n = copy(n)
            last = pop!(new_n)

            # add an option where it's subtracted if doesn't make goal negative
            if g - last > 0
                push!(stack, (g - last, new_n))
            end
            
            # add divide option as long as it's divisible
            if can_divide(g, last)
                push!(stack, (g ÷ last, new_n))
            end

            # PART TWO: add concatenation option if the goal ends with the last num
            if p2
                g_str, last_str = string(g), string(last)
                if length(g_str) > length(last_str) && g_str[end - length(last_str) + 1:end] == last_str
                    push!(stack, (parse(Int, g_str[1:end - length(last_str)]), new_n))
                end
            end
        end
    end
    # if the stack is empty then we've failed
    return false
end

function main()
    p1, p2 = sol()
    println("PART ONE: ", p1)
    println("PART TWO: ", p2)
    @time sol()
end

main()
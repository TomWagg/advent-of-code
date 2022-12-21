using DataStructures, InverseFunctions

function say_what(monkey, waiting_room, shouting, operations)

    if monkey == "humn"
        return nothing
    end

    # base condition
    if length(waiting_room[monkey]) == 0
        return shouting[monkey]
    end

    first_waiter = say_what(waiting_room[monkey][1], waiting_room, shouting, operations)
    second_waiter = say_what(waiting_room[monkey][2], waiting_room, shouting, operations)

    if first_waiter === nothing || second_waiter === nothing
        return nothing
    end

    shout = 0
    if operations[monkey] == "+"
        shout = first_waiter + second_waiter
    elseif operations[monkey] == "-"
        shout = first_waiter - second_waiter
    elseif operations[monkey] == "*"
        shout = first_waiter * second_waiter
    elseif operations[monkey] == "/"
        shout = first_waiter ÷ second_waiter
    end
    shouting[monkey] = shout
    waiting_room[monkey] = []

    return shout
end

function aggregate_operations(monkey, waiting_room, shouting, operations)
    # base condition
    if monkey == "humn"
        return monkey
    end
    if length(waiting_room[monkey]) == 0
        return string(shouting[monkey])
    end

    first_waiter = aggregate_operations(waiting_room[monkey][1], waiting_room, shouting, operations)
    second_waiter = aggregate_operations(waiting_room[monkey][2], waiting_room, shouting, operations)

    if occursin("humn", first_waiter) || occursin("humn", second_waiter)
        op_string = "(" * first_waiter * " " * operations[monkey] * " " * second_waiter * ")"
    else
        shout = 0
        first_waiter = parse(Int, first_waiter)
        second_waiter = parse(Int, second_waiter)
        if operations[monkey] == "+"
            shout = first_waiter + second_waiter
        elseif operations[monkey] == "-"
            shout = first_waiter - second_waiter
        elseif operations[monkey] == "*"
            shout = first_waiter * second_waiter
        elseif operations[monkey] == "/"
            shout = first_waiter ÷ second_waiter
        end
        shouting[monkey] = shout
        op_string = string(shout)
    end
    waiting_room[monkey] = []

    return op_string
end


function wrangle_monkeys()
    waiting_room = Dict{String, Array{String}}()
    shouting = Dict{String, Int64}()
    operations = Dict{String, String}()
    open("../inputs/21.txt", "r") do input
        for line in eachline(input)
            name, action = split(line, ": ")
            if length(action) == 11
                waiters = split(action, " ")
                waiting_room[name] = [waiters[1], waiters[3]]
                operations[name] = waiters[2]
            else
                waiting_room[name] = []
                shouting[name] = parse(Int, action)
            end
        end
    end
    return waiting_room, shouting, operations
end

function part_one()
    waiting_room, shouting, operations = wrangle_monkeys()
    return say_what("root", waiting_room, shouting, operations)
end

function part_two()
    waiting_room, shouting, operations = wrangle_monkeys()

    # @show aggregate_operations(waiting_room["root"][1], waiting_room, shouting, operations)

    target = say_what(waiting_room["root"][1], waiting_room, shouting, operations)
    if target === nothing
        target = say_what(waiting_room["root"][2], waiting_room, shouting, operations)
        return solve_it(waiting_room["root"][1], target, waiting_room, shouting, operations)
    else
        return solve_it(waiting_room["root"][2], target, waiting_room, shouting, operations)
    end

    return nothing
end

function solve_it(monkey, target, waiting_room, shouting, operations)
    if monkey == "humn"
        return target
    end
    branches = [say_what(waiting_room[monkey][i], waiting_room, shouting, operations) for i in 1:2]

    value = -1
    next = -1
    if branches[1] === nothing
        value = 2
        next = 1
    else
        value = 1
        next = 2
    end

    new_target = 0
    if operations[monkey] == "+"
        new_target = target - branches[value]
    elseif operations[monkey] == "-"
        if value == 2
            new_target = target + branches[value]
        else
            new_target = branches[value] - target
        end
    elseif operations[monkey] == "*"
        new_target = target ÷ branches[value]
    elseif operations[monkey] == "/"
        if value == 2
            new_target = target * branches[value]
        else
            new_target = branches[value] ÷ target
        end
    end

    return solve_it(waiting_room[monkey][next], new_target, waiting_room, shouting, operations)
end

function test(humn)
    return ((((92540050790154 - (9 * (((((280 + (((((((2 * (264 + ((516 + (((660 + (2 * ((2 * (530 + ((((313 + (((((3 * (615 + (((8 * (915 + ((((246 + (4 * (((483 + (((((((80 + (((((8 * ((((3 * (789 + ((107 + ((humn - 745) ÷ 3)) * 11))) - 695) ÷ 4) - 486)) + 570) ÷ 5) - 757) ÷ 3)) * 5) + 411) * 2) - 885) + 552) + 802)) ÷ 2) - 686))) ÷ 5) - 175) ÷ 3))) - 66) ÷ 2))) - 319) * 2) + 133) + 570)) ÷ 2) - 955) ÷ 2))) - 768))) ÷ 3) - 223)) ÷ 5))) - 933) ÷ 5) + 765) * 9) - 193) * 2)) ÷ 2) + 689) ÷ 6) - 230))) * 2) + 138) ÷ 12)
end

@show test(3453748220116)

# println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
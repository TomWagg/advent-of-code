using BenchmarkTools

function wrangle_monkeys()
    """Wrangle monkeys out of a file and into some data structures"""
    # dictionary connecting monkeys to monkeys that are dependent on
    waiting_room = Dict{String, Array{String}}()
    # dictionarys relating a monkey to what it will shout and what operation it performs
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

function say_what(monkey, waiting_room, shouting, operations, ignore_humn)
    """Monkey says what? (Work out what a monkey will shout)"""
    # if the monkey is the special one that we replace then return nothing (only on part 2)
    if monkey == "humn" && ignore_humn
        return nothing
    end

    # if the monkey isn't waiting on anyone then just shout away my friend
    if length(waiting_room[monkey]) == 0
        return shouting[monkey]
    end

    # work out what the two monkeys that this one is waiting for will shout
    first_waiter = say_what(waiting_room[monkey][1], waiting_room, shouting, operations, ignore_humn)
    second_waiter = say_what(waiting_room[monkey][2], waiting_room, shouting, operations, ignore_humn)

    # if either returns nothing then you don't what to shout and just return nothing
    if ignore_humn && (first_waiter === nothing || second_waiter === nothing)
        return nothing
    end

    # otherwise calculate your shout value based on the operation
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

    # update the shout value and erase the waiting room
    shouting[monkey] = shout
    waiting_room[monkey] = []

    return shout
end

function part_one()
    # just work out what the root will shout
    waiting_room, shouting, operations = wrangle_monkeys()
    return say_what("root", waiting_room, shouting, operations, false)
end

function part_two()
    waiting_room, shouting, operations = wrangle_monkeys()

    targets = [say_what(waiting_room["root"][i], waiting_room, shouting, operations, true) for i in 1:2]
    if targets[1] === nothing
        return what_do_i_shout(waiting_room["root"][1], targets[2], waiting_room, shouting, operations)
    else
        return what_do_i_shout(waiting_room["root"][2], targets[1], waiting_room, shouting, operations)
    end
end

function what_do_i_shout(monkey, target, waiting_room, shouting, operations)
    if monkey == "humn"
        return target
    end
    branches = [say_what(waiting_room[monkey][i], waiting_room, shouting, operations, true) for i in 1:2]

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

    return what_do_i_shout(waiting_room[monkey][next], new_target, waiting_room, shouting, operations)
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())

@btime part_one()
@btime part_two()
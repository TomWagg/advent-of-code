mutable struct Monkey
    items::Array{Int64}
    operation::Function
    divisible::Int64
    throw_to::Array{Int64}
end

function get_monkeys()
    monkeys = []
    open("../inputs/11.txt", "r") do input
        current_monkey = nothing
        for line in eachline(input)
            if line == ""
                push!(monkeys, current_monkey)
            elseif line[1:6] == "Monkey"
                current_monkey = Monkey([], solver, 1, [1,1])
            else
                sline = split(line, ":")
                if sline[1] == "  Starting items"
                    current_monkey.items = parse.(Int64, split(sline[2], ","))
                elseif sline[1] == "  Operation"
                    operator, val = split(split(sline[2], "= ")[2], " ")[2:3]
                    f = (x) -> x
                    if operator == "+" && val == "old"
                        f = (x) -> x .+ x
                    elseif operator == "*" && val == "old"
                        f = (x) -> x .* x
                    elseif operator == "+"
                        f = (x) -> x .+ parse(Int64, val)
                    elseif operator == "*"
                        f = (x) -> x .* parse(Int64, val)
                    end;
                    current_monkey.operation = f
                elseif sline[1] == "  Test"
                    current_monkey.divisible = parse(Int64, split(sline[2], "divisible by ")[2])
                elseif sline[1] == "    If true"
                    current_monkey.throw_to[1] = parse(Int64, split(sline[2], "monkey")[2]) + 1
                elseif sline[1] == "    If false"
                    current_monkey.throw_to[2] = parse(Int64, split(sline[2], "monkey")[2]) + 1
                end;
            end
        end;
        push!(monkeys, current_monkey)
    end
end


function solver(part_two)
    monkeys = get_monkeys()
    inspections = zeros(Int64, length(monkeys))

    lcm = 1
    for i in 1:length(monkeys)
        lcm *= monkeys[i].divisible
    end;

    top = part_two ? 10000 : 20
    
    for i in 1:top
        for j in 1:length(monkeys)
            inspections[j] += length(monkeys[j].items)
            monkeys[j].items = monkeys[j].operation(monkeys[j].items)

            if part_two
                monkeys[j].items .%= lcm
            else
                monkeys[j].items .÷= 3          ## <- this is the hard part, need to do this to make it small
            end
            passes_test = (monkeys[j].items .% monkeys[j].divisible) .== 0

            if any(passes_test)
                monkeys[monkeys[j].throw_to[1]].items = vcat(monkeys[j].items[passes_test],
                                                             monkeys[monkeys[j].throw_to[1]].items)
            end
            if !all(passes_test)
                monkeys[monkeys[j].throw_to[2]].items = vcat(monkeys[j].items[.~passes_test],
                                                             monkeys[monkeys[j].throw_to[2]].items)
            end
            monkeys[j].items = []
        end
    end
    return prod(sort(inspections, rev=true)[1:2])

end

println("PART ONE: ", solver(false))
println("PART TWO: ", solver(true))

@time solver(false)
@time solver(true)

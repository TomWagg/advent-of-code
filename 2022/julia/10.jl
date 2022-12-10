function part_one()
    cycle = 0
    register = 1
    total = 0
    open("../inputs/10.txt", "r") do input
        val = nothing
        for line in eachline(input)
            change = nothing
            if line == "noop"
                change = 1
            else
                val = parse(Int, split(line, " ")[2])
                register += val
                change = 2
            end
            cycle += change


            if cycle >= 20 && (cycle - 20) % 40 == 0
                if change == 2
                    total += cycle * (register - val)
                else
                    total += cycle * register
                end
            elseif cycle >= 20 && (cycle - 20 - 1) % 40 == 0 && change != 1
                total += (cycle - 1) * (register - val)
            end
        end
    end
    return total
end

function check_filled(cycle, register, pos_filled)
    cycle += 1
    crt_pos = cycle % 40
    pos_filled[cycle] = (register + 2 == crt_pos || register == crt_pos || register + 1 == crt_pos)
    return cycle, pos_filled
end

function part_two()
    cycle = 0
    register = 1
    pos_filled = zeros(Bool, 240)
    open("../inputs/10.txt", "r") do input
        for line in eachline(input)
            cycle, pos_filled = check_filled(cycle, register, pos_filled)
            if line != "noop"
                cycle, pos_filled = check_filled(cycle, register, pos_filled)
                register += parse(Int, split(line, " ")[2])
            end
        end
    end

    println("PART TWO:")
    for i in 1:240
        if pos_filled[i]
            print("|")
        else
            print(" ")
        end
        if i % 40 == 0
            println()
        end
    end
end

println("PART ONE: ", part_one())
part_two()

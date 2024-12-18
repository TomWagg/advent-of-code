const combo(operand::Int, registers::Vector{Int}) = operand <= 3 ? operand : registers[operand - 3]

function get_input()
    register_str, program_str = split(read("inputs/17.txt", String), "\n\n")
    registers = parse.(Int, map(x->split(x, ":")[2], split(register_str, "\n")))
    program = parse.(Int, split(split(program_str, ": ")[2], ","))
    return registers, program
end

function run_program(registers::Vector{Int}, program::Vector{Int})
    output, i = Vector{Int}(undef, 0), 1
    while i <= length(program)
        operator, operand = program[i:i + 1]
        if operator == 0
            registers[1] >>= combo(operand, registers)
        elseif operator == 1
            registers[2] = registers[2] ⊻ operand
        elseif operator == 2
            registers[2] = combo(operand, registers) % 8
        elseif operator == 3
            i = registers[1] != 0 ? operand - 1 : i
        elseif operator == 4
            registers[2] = registers[2] ⊻ registers[3]
        elseif operator == 5
            push!(output, combo(operand, registers) % 8)
        elseif operator == 6
            registers[2] = registers[1] >> combo(operand, registers)
        elseif operator == 7
            registers[3] = registers[1] >> combo(operand, registers)
        end
        i += 2
    end
    return output
end

function sol()
    registers, program = get_input()
    p1 = join(run_program(registers, program), ",")
    uncorrupted_register = does_it_match(0, program, 1)
    return p1, uncorrupted_register
end

function does_it_match(A::Int, program::Vector{Int}, n_digits::Int)
    """Recursive function that finds the register A value needed to reproduce the program"""
    # check if the output matches the last n_digits of the program
    output = run_program([A, 0, 0], program)
    if output == program[end - n_digits + 1:end] 
        if n_digits == 16
            # if it matches all 16 we've done it!
            return A
        else
            # otherwise a match means we should move on to the next digit
            return does_it_match(A * 8, program, n_digits + 1)
        end
    else
        # without a match then we should just try the next number
        return does_it_match(A + 1, program, n_digits)
    end

    # I thought there should be a check here that the output length isn't larger than the program
    # but it doesn't seem to be necessary because we always find a solution ¯\_(ツ)_/¯
end

function main()
    println("SOLUTION: ", sol())
    @time sol()
end

main()
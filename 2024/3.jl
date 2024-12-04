# using DelimitedFiles
# using BenchmarkTools

const mul_regex = r"(?<=mul\()(?<left>[0-9]+),(?<right>[0-9]+)(?=\))"
const mul2_regex = r"((?<=mul\()(?<left>[0-9]+),(?<right>[0-9]+)(?=\))|do\(\)|don't\(\))"


function part_one(instructions)
    total = 0
    @show matchall(mul_regex, instructions)
    for (left, right) in eachmatch(mul_regex, instructions)
        total += parse(Int, left) * parse(Int, right)
    end
    return total
end

function part_two(instructions)
    enabled = true
    total = 0
    for match in eachmatch(mul2_regex, instructions)
        if match[1] == "do()"
            enabled = true
        elseif match[1] == "don't()"
            enabled = false
        else
            if enabled
                total += parse(Int, match["left"]) * parse(Int, match["right"])
            end
        end
    end
    return total
end

function main()
    instructions = read("inputs/3.txt", String)
    println("PART ONE: ", part_one(instructions))
    @time part_one(instructions)
    println("PART TWO: ", part_two(instructions))
    @time part_two(instructions)
end

main()
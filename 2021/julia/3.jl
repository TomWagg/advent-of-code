function get_most_common(diagnostics, bit_position)
    total = 0

    # loop over each diagnostic and sum the digits
    for i in 1:length(diagnostics)
        total += parse(Int, diagnostics[i][bit_position])
    end;

    # divide by the total number of diagnostics
    total /= length(diagnostics)

    return total < 0.5 ? 0 : 1
end;

function get_power(diagnostics)
    # count how many digits in each binary number
    n_digit = length(diagnostics[1])

    most_common = ""
    least_common = ""

    # loop over each digit
    for i in 1:n_digit
        most = get_most_common(diagnostics, i)
        # this gives most common and least common
        most_common *= string(most)
        least_common *= string(1 - most)
    end;

    # convert numbers to decimals and multiply
    power = parse(Int, most_common, base=2) * parse(Int, least_common, base=2)

    # part 1 done!
    return power
end;


function get_gas_rating(diagnostics, bit_position, least)
    # find the most common bit at this bit position
    most_common = get_most_common(diagnostics, bit_position)
    criterion = least ? 1 - most_common : most_common

    # create a reduced list of diagnostics that match the criterion
    reduced_diagnostics = String[]
    for i in 1:length(diagnostics)
        if string(diagnostics[i][bit_position]) == string(criterion)
            push!(reduced_diagnostics, diagnostics[i])
        end;
    end;

    # if only one left then return it
    if length(reduced_diagnostics) == 1
        return parse(Int, reduced_diagnostics[1], base=2)
    # otherwise recurse
    else
        return get_gas_rating(reduced_diagnostics, bit_position + 1, least)
    end;
end;


function get_life_support(diagnostics)
    return get_gas_rating(diagnostics, 1, false) * get_gas_rating(diagnostics, 1, true)
end;


function main()
    diagnostics = open("../inputs/3.txt", "r") do input
        diagnostics = [chomp(line) for line in eachline(input)]
    end;

    println("PART ONE: ", get_power(diagnostics))
    println("PART TWO: ", get_life_support(diagnostics))
end;

main()
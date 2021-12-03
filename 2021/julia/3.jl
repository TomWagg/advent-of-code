function get_power(diagnostics)
    # count how many digits in each binary number
    n_digit = length(diagnostics[1])

    most_common = ""
    least_common = ""

    # loop over each digit
    for i in 1:n_digit
        total = 0

        # loop over each diagnostic and sum the digits
        for j in 1:length(diagnostics)
            total += parse(Int, diagnostics[j][i])
        end;

        # divide by the total number of diagnostics
        total /= length(diagnostics)

        # this gives most common and least common
        most_common *= total < 0.5 ? "0" : "1"
        least_common *= total < 0.5 ? "1" : "0"
    end;

    # convert numbers to decimals and multiply
    power = parse(Int, most_common, base=2) * parse(Int, least_common, base=2)

    # part 1 done!
    return power
end;


function main()

    diagnostics = open("../inputs/3.txt", "r") do input
        diagnostics = [chomp(line) for line in eachline(input)]
    end;

    println("PART ONE: ", get_power(diagnostics))
end;

main()
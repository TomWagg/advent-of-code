function count_unique_segments(output_values)
    # unique segment lengths are 2,4,3 and 7 for 1,4,7 and 8 respectively
    unique_lengths = Set([2, 4, 3, 7])

    # sum up the lengths in the flattened output values that match this
    return sum([convert(Int, length(j) in unique_lengths) for sub in output_values for j in sub])
end;


function set2list(set)
    return [s for s in set]
end;


function decode_output(signal_patterns, output_values)
    """ This one was a bloody hassle :D """

    # start a running count of the values
    value = 0

    # go through each pattern, output list pair
    for i in 1:length(signal_patterns)

        one, four, seven, eight = nothing, nothing, nothing, nothing
        length_five = []
        length_six = []

        # find the unique numbers and the groups that have lengths 5 or 6
        for j in 1:length(signal_patterns[i])
            if length(signal_patterns[i][j]) == 2
                one = Set(signal_patterns[i][j])
            elseif length(signal_patterns[i][j]) == 3
                seven = Set(signal_patterns[i][j])
            elseif length(signal_patterns[i][j]) == 4
                four = Set(signal_patterns[i][j])
            elseif length(signal_patterns[i][j]) == 7
                eight = Set(signal_patterns[i][j])
            elseif length(signal_patterns[i][j]) == 5
                push!(length_five, Set(signal_patterns[i][j]))
            elseif length(signal_patterns[i][j]) == 6
                push!(length_six, Set(signal_patterns[i][j]))
            else
                println("ERROR")
                return
            end;
        end;

        # by comparison we can find pairs of vlaues using one, four, seven and eight
        top_left_or_middle = set2list(setdiff(four, one))
        bottom_left_or_bottom = set2list(setdiff(eight, union(seven, four)))

        # then we go logically through and work out which number is which
        two, three, five = nothing, nothing, nothing
        for number in length_five
            # only number five will contain both the top left and middle
            if top_left_or_middle[1] in number && top_left_or_middle[2] in number
                five = number
            # only number two will contain both the bottom left and bottom
            elseif bottom_left_or_bottom[1] in number && bottom_left_or_bottom[2] in number
                two = number
            else
                three = number
            end;
        end;

        zero, six, nine = nothing, nothing, nothing
        for number in length_six
            # only number zero won't contain both the top left and middle
            if !(top_left_or_middle[1] in number && top_left_or_middle[2] in number)
                zero = number
            # only number nine won't contain both the bottom left and bottom
            elseif !(bottom_left_or_bottom[1] in number && bottom_left_or_bottom[2] in number)
                nine = number
            else
                six = number
            end;
        end;

        # et voila, a list of Sets corresponding to numbers
        numbers = [zero, one, two, three, four, five, six, seven, eight, nine]

        # now we go through each digit output value
        output = []
        for j in 1:length(output_values[i])
            # create a Set of the output value and find the corresponding number
            output_set = Set(output_values[i][j])
            for k in 1:length(numbers)
                if output_set == numbers[k]
                    # store that digit
                    push!(output, string(k - 1))
                end;
            end;
        end;

        # join the digits into a number and increment the value by this amount
        value += parse(Int, join(output))
    end;
    return value
end;


function main()
    # read in the file
    signal_patterns = []
    output_values = []
    open("../inputs/8.txt", "r") do input
        for line in eachline(input)
            signal_pattern, output_value = split(chomp(line), " | ")
            push!(signal_patterns, split(signal_pattern))
            push!(output_values, split(output_value))
        end;
    end;

    println("PART ONE: ", count_unique_segments(output_values))
    println("PART TWO: ", decode_output(signal_patterns, output_values))
end;


main()

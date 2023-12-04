const digits = [Char('0' + i) for i in 1:9]
const digit_strs = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
const replacements = [(digit_strs[i], digit_strs[i][1] * digits[i] * digit_strs[i][length(digit_strs[i])])
                      for i in eachindex(digit_strs)]

function calibration_value(doc::String)
    cdoc = collect(doc)
    first_loc, first_val = 1000000, ""
    last_loc, last_val = -1, ""

    for digit in digits
        mask = cdoc .== digit

        # find earliest occurence of digit in string, if better than current first, update
        earliest_loc = findfirst(mask)
        if earliest_loc !== nothing && earliest_loc < first_loc
            first_loc = earliest_loc
            first_val = digit
        end;

        # find latest occurence of digit in string, if better than current last, update
        latest_loc = findlast(mask)
        if latest_loc !== nothing && latest_loc > last_loc
            last_loc = latest_loc
            last_val = digit
        end;
    end;
    # concatenate and convert to integers
    return parse(Int, first_val * last_val)
end

function main()
    part_one, part_two = 0, 0
    open("../inputs/1.txt") do input
        for line in eachline(input)
            # perform simple part one version
            part_one += calibration_value(line)

            # then replace any string versions of numbers
            # replace every number => its digit, BUT retain first/last characters in case of ellision
            for (before, after) in replacements
                line = replace(line, before => after)
            end;

            # repeat with the new string
            part_two += calibration_value(line)
        end
    end
    @show part_one
    @show part_two
end

main()
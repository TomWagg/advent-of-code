function item2priority(item)
    # convert an item to a priority using ascii codes
    if item >= 'a'
        return item - 'a' + 1
    else
        return item - 'A' + 27
    end;
end;

function part_one()
    total_priority = 0
    total_priority = open("../inputs/3.txt", "r") do input
        for line in eachline(input)
            # convert the string to an array of characters
            sline = collect(line)

            # split the array in half using integer division
            first_half = sline[1:(length(sline) ÷ 2)]
            second_half = sline[(length(sline) ÷ 2) + 1:length(sline)]

            # find the only character in both halves
            item = intersect(first_half, second_half)[1]

            # add its priority to the total
            total_priority += item2priority(item)
        end;
        # this seems to be necessary to make the variable available out of scope?
        total_priority
    end;
    return total_priority
end;

function part_two()
    total_priority = 0

    # start an empty elf group and counter
    i = 0
    group = []
    total_priority = open("../inputs/3.txt", "r") do input
        for line in eachline(input)
            # convert the string to an array of characters
            sline = collect(line)

            # if you've reached the end of the group
            if i == 3
                # add the priority of the item that is in all 3 groups
                total_priority += item2priority(first(intersect(intersect(group[1], group[2]), group[3])))

                # reset the group and counter
                group = [sline]
                i = 0
            else
                # add the elf's items to the group
                push!(group, sline)
            end;
            i += 1
        end;
        # end case to account for final group
        total_priority += item2priority(intersect(intersect(group[1], group[2]), group[3])[1])
    end;
    return total_priority
end;

function main()
    # open up the input file
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end;

main()
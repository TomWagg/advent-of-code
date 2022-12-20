function adj_mod(x::Int64, y::Int64)
    """Slightly different modulo to account for 1-indexing"""
    return ((x - 1) % y) + 1
end

function get_numbers()
    numbers = []
    open("../inputs/20.txt", "r") do input
        for line in eachline(input)
            push!(numbers, parse(Int64, line))
        end
    end
    return numbers
end

function part_one()
    numbers = get_numbers()
    max_ind = length(numbers)
    inds = collect(1:max_ind)

    # create a mixing bowl that connects numbers and their initial indices
    mixing_bowl = [(ind, numbers[ind]) for ind in inds]
    zero_ind = 0

    # loop over the numbers to move
    for i in 1:max_ind
        # search for the number in the current mixing bowl
        for j in 1:max_ind
            # once you find it
            if mixing_bowl[j][1] == i
                
                # pop out the current number
                _, num = mixing_bowl[j]
                deleteat!(mixing_bowl, j)

                # work out where it should be inserted
                # (max_ind - 1) because we've already removed num
                new_index = adj_mod(j + num, max_ind - 1)

                # if it's negative then offset it from the end of the bowl
                if new_index <= 0
                    new_index = max_ind - 1 + new_index
                end

                # put it back in that index and move on to the next
                insert!(mixing_bowl, new_index, (i, num))
                break
            end
        end
    end

    # search for where the zero ended up
    for i in eachindex(mixing_bowl)
        if mixing_bowl[i][2] == 0
            zero_ind = i
            break
        end
    end

    # calculate the answer using the zero_ind
    answer = 0
    for i in 1:3
        answer += mixing_bowl[adj_mod(zero_ind + i * 1000, max_ind)][2]
    end

    return answer
end

function part_two()
    return nothing
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
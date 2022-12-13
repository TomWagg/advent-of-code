function packet_from_string(s::String)
    """Convert a string of [,],int into a packet (list of lists)"""
    currenly_open = [[]]
    chars = collect(s)
    i = 2

    # loop over the list of characters in the packet
    while i <= length(chars)
        # for every open bracket, create a new array and append it
        if chars[i] == '['
            push!(currenly_open, [])

        # for every close bracket
        elseif chars[i] == ']'
            # pop off the most recently opened array
            closed = pop!(currenly_open)

            # if there are no more then you're done, return!
            if length(currenly_open) == 0
                return closed
            # otherwise, insert it into the next most recently opened array
            else
                push!(last(currenly_open), closed)
            end

        # finally, for every other character that's not a comma (numbers)
        elseif chars[i] != ','
            # work out where the number stops
            j = i
            while j <= length(chars) && Int('0') <= Int(chars[j]) <= Int('9')
                j += 1
            end
            
            # push the number into the most recently opened array
            push!(last(currenly_open), parse(Int64, String(chars[i:j-1])))

            # update the cursor to account for number length
            i = j - 1
        end
        i += 1
    end
    return currenly_open
end

function compare_ints(a::Int, b::Int)
    """Compare two ints, return a flag based on which is larger"""
    if a < b
        return 1
    elseif a > b
        return 0
    else
        return -1
    end
end

function compare_arrays(a::Array, b::Array)
    # go through each array (up to the length of the shorter one to avoid bounds errors)
    for i in 1:min(length(a), length(b))
        # by default leave flag as -1 (means do nothing)
        flag = -1

        # if both are integers then compare directly
        if a[i] isa Int && b[i] isa Int
            flag = compare_ints(a[i], b[i])

        # if both are arrays then recurse
        elseif a[i] isa Array && b[i] isa Array
            flag = compare_arrays(a[i], b[i])

        # if one is Int then convert to Array and recurse
        elseif a[i] isa Array && b[i] isa Int
            flag = compare_arrays(a[i], [b[i]])
        elseif a[i] isa Int && b[i] isa Array
            flag = compare_arrays([a[i]], b[i])
        end

        # if flags are thrown then return
        if flag == 0
            return false
        elseif flag == 1
            return true
        end
    end

    # if you get to the end of the shorter array then return based on length
    if length(a) < length(b)
        return true
    elseif length(a) > length(b)
        return false
    else
        println("SHOULD NOT REACH HERE")
        return nothing
    end
end

function part_one()
    total = 0
    i = 1
    open("../inputs/13.txt", "r") do input
        left = nothing
        right = nothing
        for line in eachline(input)
            if line == ""
                left = nothing
                right = nothing
            elseif left == nothing
                left = packet_from_string(line)
            else
                right = packet_from_string(line)
            end
            if left != nothing && right != nothing
                if compare_arrays(left, right) == true
                    total += i
                end
                i += 1
            end
        end
    end
    return total
end

function part_two()
    packets = Any[[[2]], [[6]]]
    open("../inputs/13.txt", "r") do input
        for line in eachline(input)
            if line != ""
                push!(packets, packet_from_string(line))
            end
        end
    end

    # use compare_arrays func to sort packets with divider packets inserted
    sort!(packets, lt=compare_arrays)

    # find the decoder value by locating the divider packets
    decoder = 1
    for i in 1:length(packets)
        if packets[i] == [[2]] || packets[i] == [[6]]
            decoder *= i
        end
    end
    return decoder
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
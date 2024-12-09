function part_one()
    discmap_str = read("inputs/9.txt", String)
    discmap = parse.(Int, collect(discmap_str))
    final_map = [isodd(i - 1) ? -1 : (i - 1) ÷ 2 for (i, c) in enumerate(discmap) for _ in 1:c]
    last_ind = nothing
    for (i, v) in enumerate(reverse(final_map))
        if v != -1
            last_ind = length(final_map) - i + 1
            break
        end
    end

    final_map = collect(final_map)
    for i in eachindex(final_map)
        if i > last_ind
            break
        end
        if final_map[i] == -1
            final_map[i] = final_map[last_ind]
            final_map[last_ind] = -1
            last_ind -= 1
            while final_map[last_ind] == -1
                last_ind -= 1
            end
        end
    end
    defrag = final_map[1:last_ind]
    checksum = 0
    for (i, v) in enumerate(defrag)
        checksum += (i - 1) * v
    end
    return checksum
end

function part_two()
    discmap_str = read("inputs/9.txt", String)
    discmap = parse.(Int, collect(discmap_str))
    
    files = Vector{Tuple{Int, Int}}(undef, 0)
    gaps = Vector{Tuple{Int, Int}}(undef, 0)

    # save the start locations and length of each file/gap
    start_loc = 0
    for (i, count) in enumerate(discmap)
        push!(isodd(i - 1) ? gaps : files, (start_loc, count))
        start_loc += count
    end

    checksum = 0
    # go through the files in descending order
    for (rev_file_ind, file) in enumerate(reverse(files))
        file_ind = (length(files) - rev_file_ind)

        for (i, gap) in enumerate(gaps)
            # don't bother once no gaps before file
            if gap[1] > file[1]
                break
            end

            # if the gap is larger than the file
            if gap[2] > file[2]
                # move the file into the gap
                files[file_ind + 1] = (gap[1], file[2])

                # move and shrink the gap
                gaps[i] = (gap[1] + file[2], gap[2] - file[2])

                # done with this file
                break

            # if the gap is just large enough for the file
            elseif gap[2] == file[2]
                # move the file
                files[file_ind + 1] = (gap[1], file[2])

                # delete the gap
                deleteat!(gaps, i)
                break
            end
        end

        # calculate the checksum for this file
        file = files[file_ind + 1]
        for i in file[1]:file[1] + file[2] - 1
            checksum += file_ind * i
        end
    end
    return checksum
end

function main()
    println("PART ONE: ", part_one())
    @time part_one()
    println("PART TWO: ", part_two())
    @time part_two()
end

main()
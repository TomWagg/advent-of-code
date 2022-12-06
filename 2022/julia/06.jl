function find_start(unique_size=4)
    start_of_packet = -1
    datastream = open("../inputs/6.txt", "r") do input
        for line in eachline(input)
            datastream = collect(line)
        end;

        i = unique_size
        while ~allunique(datastream[i - unique_size + 1:i])
            i += 1
        end;
        start_of_packet = i
    end;

    return start_of_packet
end;

function main()
    println("PART ONE: ", find_start(4))
    println("PART TWO: ", find_start(14))
end;

main()
function part_one()
    subset_pairs = 0
    subset_pairs = open("../inputs/4.txt", "r") do input
        for line in eachline(input)
            sline = split.(split(line, ","), "-")
            elf_1 = parse.(Int, sline[1])
            elf_2 = parse.(Int, sline[2])
            if (elf_1[1] >= elf_2[1] && elf_1[2] <= elf_2[2]) || (elf_2[1] >= elf_1[1] && elf_2[2] <= elf_1[2])
                subset_pairs += 1
            end;
        end;
        subset_pairs
    end;
    return subset_pairs
end;

function part_two()
    overlap_pairs = 0
    overlap_pairs = open("../inputs/4.txt", "r") do input
        for line in eachline(input)
            sline = split.(split(line, ","), "-")
            elf_1 = parse.(Int, sline[1])
            elf_2 = parse.(Int, sline[2])
            if ~(elf_1[2] < elf_2[1] || elf_1[1] > elf_2[2])
                overlap_pairs += 1
            end;
        end;
        overlap_pairs
    end;
    return overlap_pairs
end;

function main()
    # open up the input file
    println("PART ONE: ", part_one())
    println("PART TWO: ", part_two())
end;

main()
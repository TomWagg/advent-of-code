function evolve_fish(fish_counts, days)
    # for each day of evolution
    for i in 1:days
        # keep track of how many will be spawning
        fish_spawning = fish_counts[1]

        # decrease the timers for the rest
        for j in 1:length(fish_counts) - 1
            fish_counts[j] = fish_counts[j + 1]
        end;

        # create new fish, reset the ones that just finished
        fish_counts[length(fish_counts)] = fish_spawning
        fish_counts[6 + 1] += fish_spawning
    end;
    
    return fish_counts
end;


function main()
    # get the list of fish
    fish_list = open("../inputs/6.txt") do input
        fish_list = parse.(Int, split(readline(input), ","))
    end;

    # add counts for each unique age fish
    fish_counts = [0 for i in 1:9]
    for fish in fish_list
        fish_counts[fish + 1] += 1
    end;

    println("PART ONE: ", sum(evolve_fish(fish_counts, 80)))
    println("PART TWO: ", sum(evolve_fish(fish_counts, 256)))
end;


main()

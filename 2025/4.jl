function sol(lines, p1=false)
    paper_locs = Set([])
    for i in eachindex(lines)
        for j in eachindex(lines[1])
            if lines[i][j] == '@'
                push!(paper_locs, (i, j))
            end
        end
    end

    n_accessible = 0
    accessible = Set([])
    
    nearby = nothing
    while true
        for loc in paper_locs
            nearby = 0
        
            for d_row in -1:1
                for d_col in -1:1
                    if d_row == 0 && d_col == 0
                        continue
                    end
                    if (loc[1] + d_row, loc[2] + d_col) ∈ paper_locs
                        nearby += 1
                    end
                    if nearby ≥ 4
                        break
                    end
                end
            end

            if nearby < 4
                push!(accessible, loc)
            end
        end

        break_it = length(accessible) == 0 || p1

        n_accessible += length(accessible)
        setdiff!(paper_locs, accessible)
        accessible = Set([])
        if break_it
            break
        end
    end
    return n_accessible
end

function main()
    lines = [collect(line) for line in eachsplit(read("inputs/4.txt", String), '\n')]
    

    println("PART ONE: ", sol(lines, true))
    @time sol(lines, true)
    println("PART TWO: ", sol(lines, false))
    @time sol(lines, false)
end

main()
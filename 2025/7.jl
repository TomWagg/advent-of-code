function sol(p2=false)
    lines = readlines("inputs/7.txt")
    visits = zeros(Int, length(lines), length(lines[1]))
    visits[1, findfirst("S", lines[1])[1]] = 1
    n_splits = 0
    for (i, line) in enumerate(lines[1:length(lines) - 1])
        for (j, c) in enumerate(collect(line))
            if c == '^' && visits[i, j] > 0
                n_splits += 1
                visits[i + 1, j + 1] += visits[i, j]
                visits[i + 1, j - 1] += visits[i, j] 
            else
                visits[i + 1, j] += visits[i, j] 
            end
        end
    end
    return p2 ? sum(visits[end, :]) : n_splits
end

function main()
    println("PART ONE: ", sol(false))
    @time sol(false)
    println("PART TWO: ", sol(true))
    @time sol(true)
end

main()
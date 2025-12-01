function sol()
    dial = 50
    dial, p1_pw, p2_pw = 50, 0, 0
    for line in eachsplit(read("inputs/1.txt", String), '\n')
        move = parse(Int, line[2:end]) * (line[1] == 'L' ? -1 : 1)

        clicks, next_dial = divrem(dial + move, 100, RoundDown)
        p1_pw += next_dial == 0
        p2_pw += (
            abs(clicks)
            - ((dial == 0) && (move < 0))
            + ((next_dial == 0) && (move < 0))
        )
        dial = next_dial
    end
    return p1_pw, p2_pw
end

function main()
    p1, p2 = sol()
    println("PART ONE: ", p1)
    println("PART TWO: ", p2)
end

main()
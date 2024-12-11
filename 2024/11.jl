using Memoize

@memoize function blink_stone(stone::Int, n_blinks::Int, total_blinks::Int)
    """Calculate the number of stones that a stone will produce after a total number of blinks"""
    # base case, you reach the total
    if n_blinks == total_blinks
        return 1
    end

    # convert the int to a string and work out how many digits it has
    stone_str = string(stone)
    digits = length(stone_str)

    # convert a 0 to a 1
    if stone == 0
        return blink_stone(1, n_blinks + 1, total_blinks)
    # split numbers with an even number of digits
    elseif digits % 2 == 0
        half = digits ÷ 2
        return (blink_stone(parse(Int, stone_str[1:half]), n_blinks + 1, total_blinks)
              + blink_stone(parse(Int, stone_str[half + 1:end]), n_blinks + 1, total_blinks))
    # multiply the rest
    else
        return blink_stone(stone * 2024, n_blinks + 1, total_blinks)
    end
end

function sol()
    stones = parse.(Int, split(read("inputs/11.txt", String), " "))
    p1 = sum(blink_stone(stone, 0, 25) for stone in stones)
    p2 = sum(blink_stone(stone, 0, 75) for stone in stones)
    return p1, p2
end

function main()
    println("BOTH PARTS: ", sol())
    @time sol()
end

main()
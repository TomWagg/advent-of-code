sol(t, r, op) = 0.5 * op(t, √(t^2 - 4 * r))
get_ways(time::Int, record::Int) = Int(ceil(sol(time, record, +) - 1) - floor(sol(time, record, -) + 1) + 1)

function part_one()
    lines = split.(split(read("../inputs/6.txt", String), '\n'))
    data = parse.(Int, mapreduce(permutedims, vcat, lines)[:, 2:end])
    times, records = data[1, :], data[2, :]
    return prod([get_ways(time, record) for (time, record) in zip(times, records)])
end

function part_two()
    time_str, record_str = split.(replace.(split(read("../inputs/6.txt", String), "\n"), " "=>""), ":")
    time, record = parse(Int, time_str[2]), parse(Int, record_str[2])
    return get_ways(time, record)
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
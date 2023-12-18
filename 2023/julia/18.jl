const int_to_offset = Dict('0'=>[0, 1], '1'=>[-1, 0], '2'=>[0, -1], '3'=>[1, 0])
const dir_to_offset = Dict("U"=>[1, 0], "D"=>[-1, 0], "L"=>[0, -1], "R"=>[0, 1])

shoelace(v) = sum(v[:, 1] .* circshift(v, -1)[:, 2] .- v[:, 2] .* circshift(v, -1)[:, 1]) ÷ 2
function lagoon_size(dirs, sizes)
    vertices = mapreduce(permutedims, vcat, accumulate(.+, pushfirst!(dirs .* sizes, [1, 1])))
    return sum(sizes) + shoelace(vertices) + 1 - sum(sizes) ÷ 2
end

split_input = split(read("../inputs/18.txt", String), '\n')
dirs, sizes = map(x->dir_to_offset[split(x)[1]], split_input), map(x->parse(Int, split(x)[2]), split_input)
println("PART ONE: ", lagoon_size(dirs, sizes))

colours = map(x->replace(split(x)[3], "("=>"", ")"=>""), split_input)
dirs, sizes = map(x->int_to_offset[x[7]], colours), map(x->parse(Int, x[2:6], base=16), colours)
println("PART TWO: ", lagoon_size(dirs, sizes))
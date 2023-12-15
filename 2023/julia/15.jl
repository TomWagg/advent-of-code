using DataStructures
HASH(s::AbstractString) = foldl((l, r) -> mod(17 * (l + r), 256), Int.(collect(s)); init=0)
println("PART ONE: ", sum(HASH.(split(read("../inputs/15.txt", String), ","))))
boxes = [OrderedDict{String, Int}() for _ in 1:256]
for seq in split(read("../inputs/15.txt", String), ",")
    op_location = findfirst(x->x ∈ ['-', '='], seq)
    label, operation = seq[1:op_location - 1], seq[op_location]
    if operation == '='
        focal_length = parse(Int, seq[op_location + 1:end])
        boxes[HASH(label) + 1][label] = focal_length
    else
        delete!(boxes[HASH(label) + 1], label)
    end
end
println("PART TWO: ", sum([i * sum(values(boxes[i]) .* range(1, length(boxes[i]))) for i in eachindex(boxes)]))
using DataStructures

const and(a, b) = a & b
const or(a, b) = a | b
const op_convert = Dict("AND" => and, "OR" => or, "XOR" => xor)

function evaluate(label, gates, values)
    if label ∉ keys(values)
        left, op, right = gates[label]
        values[label] = op(evaluate(left, gates, values), evaluate(right, gates, values))
    end
    return values[label]
end

function get_input()
    """Save a dictionary for whether a value has been calculate, a dictionary for the operations needed to
    calculate a value and a list of output keys"""
    inits, gates_str = split(read("inputs/24.txt", String), "\n\n")
    values = Dict(key => parse(Int, val) for (key, val) in split.(split(inits, "\n"), ": "))
    gates = Dict(res => (left, op_convert[op], right) for (left, op, right, _, res) in split.(split(gates_str, "\n"), " "))
    zs = sort([key for key in keys(gates) ∪ keys(inits) if key[1] == 'z'], rev=true)
    return gates, values, zs
end

function part_one()
    """Simply just evaluate the z keys"""
    gates, values, zs = get_input()
    return parse(Int, "0b" * join([evaluate(key, gates, values) for key in zs], ""))
end

function part_two()
    r"""This solution hinges on a series of assertions about how binary addition works with logic gates.
    The method for this looks like

        d_{i - 1} ------------------------------- z_i = a_i ⊻ d_{i - 1}
                                            \
                                             \
            x_i  --------> a_i = x_i ⊻ y_i -->--- c_i = a_i & d_{i - 1} ------\
                    \  /                                                       \ ____ d_i = c_i | b_i
                     \/                                                        /
            y_i  --------> b_i = x_i & y_i -----------------------------------/

    where x_i and y_i are the individual bits of the input and z_i are the bits of the output.
    
    From this we can see a few conditions are always met and so if we see an operation that fails them we
    can assert that's a broken connection. Details below.
    """
    # get string representation of each gate
    gate_strs = split.(split(split(read("inputs/24.txt", String), "\n\n")[2], "\n"), " ")
    # identify the last z-bit (this'll be useful below)
    z_max = "z" * string(mapreduce(x->x[5][1] == 'z' ? parse(Int, x[5][2:end]) : 0, max, gate_strs))

    # track the bad connections
    bad_connections = Set()

    # step through each logic gate
    for i in eachindex(gate_strs)
        left, op, right, _, res = gate_strs[i]
        first, second = sort([left, right])

        # operations combining initial bits should only use XOR or AND
        if first[1] == 'x' && second[1] == 'y' && op ∉ ["AND", "XOR"]
            push!(bad_connections, gate_strs[i][5])
        end

        # XOR operations should only combine initial bits or create a final bit
        if op == "XOR" && !((first[1] == 'x' && second[1] == 'y') || res[1] == 'z')
            push!(bad_connections, gate_strs[i][5])
        end

        # conditions about operations that create a final bit
        if res[1] == 'z'
            # should only created by an XOR operation (except the very last bit)
            if op != "XOR" && res != z_max
                push!(bad_connections, gate_strs[i][5])
            # even XOR operations shouldn't involve values created by ANDs (except the first bit)
            elseif op == "XOR"
                for j in eachindex(gate_strs)
                    left2, op2, _, _, res2 = gate_strs[j]
                    not_first_bit = left2[2:end] != "00"
                    if j != i && not_first_bit && ((res2 == left && op2 == "AND") || (res2 == right && op2 == "AND"))
                        push!(bad_connections, gate_strs[j][5])
                    end
                end
            end
        end

        # OR operations should only combine values from AND operations
        if op == "OR"
            for j in eachindex(gate_strs)
                _, op2, _, _, res2 = gate_strs[j]
                if j != i && ((res2 == left && op2 != "AND") || (res2 == right && op2 != "AND"))
                    push!(bad_connections, gate_strs[j][5])
                end
            end
        end
    end
    return join(sort([v for v in bad_connections]), ",")
end

println("PART ONE: ", part_one())
@time part_one()
println("PART TWO: ", part_two())
@time part_two()

const regex = r"([&%])([a-z]+) -> ([a-z, ]*)"

mutable struct Flipper
    label::String
    state::Bool
    dest::Vector{String}
end

mutable struct Conjuction
    label::String
    memory::Dict{String, Bool}
    dest::Vector{String}
end

function apply_pulse(m::Flipper, pulse::Bool, from::String)
    if pulse
        return []
    else
        m.state = !m.state
        return [(m.label, d, copy(m.state)) for d in m.dest]
    end
end

function apply_pulse(m::Conjuction, pulse::Bool, from::String)
    m.memory[from] = pulse
    new_pulse = !all(values(m.memory))
    return [(m.label, d, new_pulse) for d in m.dest]
end

function press_button(pulses, modules)
    n_low = 1
    n_high = 0
    while length(pulses) > 0
        from, label, pulse = popfirst!(pulses)
        if pulse
            n_high += 1
        else
            n_low += 1
        end

        if label ∈ keys(modules)
            append!(pulses, apply_pulse(modules[label], pulse, from))
        elseif label == "rx" && !pulse
            return [n_low, n_high], true
        end
    end
    return [n_low, n_high], false
end

function get_modules()
    module_strs = split(read("../inputs/20.txt", String), '\n')
    starts = split(split(module_strs[1], "-> ")[2], ", ")
    modules = Dict()

    conjunction_labels = []
    for m in match.(regex, module_strs[2:end])
        dests = split(m[3], ", ")
        if m[1] == "%"
            modules[m[2]] = Flipper(m[2], false, dests)
        else
            modules[m[2]] = Conjuction(m[2], Dict(), dests)
            push!(conjunction_labels, m[2])
        end
    end

    for l in conjunction_labels
        for mod in values(modules)
            if l ∈ mod.dest
                modules[l].memory[mod.label] = false
            end
        end
    end

    return starts, modules
end

function part_one(starts, modules)
    return reduce(*, mapreduce(x->x[1], .+,
                               press_button([("", s, false) for s in starts], modules) for i in 1:1000))
end

function part_two(starts, modules)
    found_rx = false
    n = [0, 0]
    while !found_rx
        n_more, found_rx = press_button([("", s, false) for s in starts], modules)
        n .+ n_more
    end
    return n
end

starts, modules = get_modules()
@show part_one(starts, modules)

starts, modules = get_modules()
@show part_two(starts, modules)
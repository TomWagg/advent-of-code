"""A module that tracks its label, on/off state, source modules and destination modules"""
mutable struct Flipper
    label::String
    state::Bool
    source::Vector{String}
    dest::Vector{String}
end

"""A module that tracks its source modules, destination modules and retains a memory of the most recent
pulse from each source module"""
mutable struct Conjunction
    label::String
    memory::Dict{String, Bool}
    source::Vector{String}
    dest::Vector{String}
end

function get_modules()
    """Convert the input text into a collection of modules and start points"""
    module_strs = split(read("../inputs/20.txt", String), '\n')

    # NOTE: I cheated and moved the "Broadcaster" to the top of my input
    starts = split(split(module_strs[1], "-> ")[2], ", ")
    modules = Dict(l=>(t == "%") ? Flipper(l, false, [], split(d, ", ")) : Conjunction(l, Dict(), [], split(d, ", "))
                   for (t, l, d) in match.(r"([&%])([a-z]+) -> ([a-z, ]*)", module_strs[2:end]))

    # go through each module and update its source list and (for conjunctions) set its memory
    for k1 in keys(modules)
        for k2 in keys(modules)
            if k1 ∈ modules[k2].dest
                push!(modules[k1].source, k2)
            end
        end
        if typeof(modules[k1]) == Conjunction
            modules[k1].memory = Dict(s=>false for s in modules[k1].source)
        end
    end
    return starts, modules
end

function apply_pulse(m::Flipper, pulse::Bool, from::String)
    """Apply a pulse to a flipper module"""
    # for high pulses do nothing
    if pulse
        return []

    # otherwise flip the state and send off pulses to every destination module
    m.state = !m.state
    return [(m.label, d, copy(m.state)) for d in m.dest]
end

function apply_pulse(m::Conjunction, pulse::Bool, from::String)
    """Apply a pulse to a conjunction module"""
    # update the memory dictionary
    m.memory[from] = pulse

    # send out pulses to all destinations, only sending a low pulse if the memory is all highs
    new_pulse = !all(values(m.memory))
    return [(m.label, d, new_pulse) for d in m.dest]
end

function press_button(pulses, modules, targets)
    # track low and high pulses (there's a single low pulse from the button to start)
    n_low, n_high = 1, 0

    # keep going until all of the pulses are handled
    while length(pulses) > 0
        from, label, pulse = popfirst!(pulses)

        # update high/low count
        if pulse
            n_high += 1
        else
            n_low += 1
        end

        # if this destination is actually in our modules (everything except rx pretty much)
        if label ∈ keys(modules)
            # stack up the new pulses
            new_pulses = apply_pulse(modules[label], pulse, from)
            append!(pulses, new_pulses)

            # (FOR PART TWO): if you send a low pulse out of a target then remove it from the list
            if label ∈ targets && new_pulses != [] && !new_pulses[1][3]
                filter!(e->e≠label, targets)
            end
        end
    end
    return [n_low, n_high], targets
end

function part_one(starts::Vector, modules::Dict)
    """Press the button 1000 times and return the product of the total number of high and low pulses"""
    return reduce(*, mapreduce(x->x[1], .+,
                               press_button([("", s, false) for s in starts], modules, []) for i in 1:1000))
end

function part_two(starts::Vector, modules::Dict)
    """The basis of this solution is that there is a single conjunction connected to the endpoint, then 4
    conjunctions connected to that and 4 conjunctions to those, each with an independent cyclic subgrid

    So the idea is then to just find how often each subgrid cycles to success and do the lowest common
    multiple. This assumes a bunch of things which frustrates me but it works..."""
    # find the penultimate conjunction
    last_one = "rx"
    penultimate = nothing
    for label in keys(modules)
        if last_one ∈ modules[label].dest
            penultimate = label
        end
    end

    # search out the first and second layer of conjunctions, these are our targets to cycle through
    first_layer = modules[penultimate].source
    targets = reduce(vcat, modules[s].source for s in first_layer)

    # start the lowest common multiple going, count button presses
    lcm, button_presses = 1, 1

    # continue until every single target cycles
    while length(targets) > 0
        # press the button and check if we found a target
        _, new_targets = press_button([("", s, false) for s in starts], modules, copy(targets))

        # if so then update the lowest common multiple with this cycle count
        if length(targets) != length(new_targets)
            lcm *= button_presses
        end

        # update targets and button presses and keep on truckin'
        targets = new_targets
        button_presses += 1
    end
    return lcm
end

starts, modules = get_modules()
println("PART ONE: ", part_one(starts, modules))

starts, modules = get_modules()
println("PART TWO: ", part_two(starts, modules))
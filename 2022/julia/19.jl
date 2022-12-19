using DataStructures

function get_blueprints()
    blueprints = []
    open("../inputs/19.txt", "r") do input
        for line in eachline(input)
            push!(blueprints, parse.(Int64, [match.match for match in eachmatch(r"\d+", line)]))
        end
    end
    return blueprints
end

function test_blueprint(blueprint::Array{Int64}, start_time::Int64)
    """Test out a blueprint to see how many geodes you could crack from a given start time. Optimisations:
        1. Cache the states to avoid repeating
        2. If there's not enough time left to create more geodes than max_geodes then abandon this branch
        3. Never make more robots in a resource than the max cost of that resource (or you'll make surplus)
        4. If you can make a geode robot then just do that [this might not be right for all inputs]
        5. If you can make a robot then always do so
        6. Jettison any resources that you won't be able to use before you run out of time

    The code is rather verbose but I figured long names were better than obsure variables.
    """
    # convert a blueprint into costs
    ore_cost = blueprint[1]
    clay_cost = blueprint[2]
    obsidian_cost = blueprint[3], blueprint[4]
    geode_cost = blueprint[5], blueprint[6]

    # track the maximum ore that any robot needs
    max_ore = max(max(max(ore_cost, clay_cost), obsidian_cost[1]), geode_cost[1])

    # state = (ore_robot, clay_robot, obsidian_robot, geode_robot, ore, clay, obsidian, geode)
    queue = [(start_time, 1, 0, 0, 0, 0, 0, 0, 0)]

    cache = DefaultDict(-1)
    max_geodes = 0

    while length(queue) > 0
        time, ore_robot, clay_robot, obsidian_robot, geode_robot, ore, clay, obsidian, geode = pop!(queue)
        state = ore_robot, clay_robot, obsidian_robot, geode_robot, ore, clay, obsidian, geode

        # check if we've been here before with more time left
        if cache[state] >= time
            continue
        else
            cache[state] = time
        end

        # jettison extra resources (to make cache overlap more often)
        ore = min(time * max_ore, ore)
        clay = min(time * obsidian_cost[2], clay)
        obsidian = min(time * geode_cost[2], obsidian)

        # handle running out of time
        if time <= 0
            max_geodes = max(max_geodes, geode)
            continue
        end

        # check whether you have enough time to beat the current record, give up if not
        potential_geodes = geode
        for i in 1:time
            potential_geodes += (geode_robot + i - 1)
        end
        if potential_geodes <= max_geodes
            continue
        end

        # see which robots you can make
        can_make_ore = ore >= ore_cost
        can_make_clay = ore >= clay_cost
        can_make_obsidian = ore >= obsidian_cost[1] && clay >= obsidian_cost[2]
        can_make_geode = ore >= geode_cost[1] && obsidian >= geode_cost[2]

        # if you can make a geode robot then JUST do that
        if can_make_geode
            push!(queue, (time - 1, ore_robot, clay_robot, obsidian_robot, geode_robot + 1,
                          ore + ore_robot - geode_cost[1], clay + clay_robot, obsidian + obsidian_robot - geode_cost[2], geode + geode_robot))
            continue
        end

        # if you can make an ore robot and you don't have to many then do it
        if ore_robot < max_ore && can_make_ore
            push!(queue, (time - 1, ore_robot + 1, clay_robot, obsidian_robot, geode_robot,
                          ore + ore_robot - ore_cost, clay + clay_robot, obsidian + obsidian_robot, geode + geode_robot))
        end

        # same as ore robots
        if clay_robot < obsidian_cost[2] && can_make_clay
            push!(queue, (time - 1, ore_robot, clay_robot + 1, obsidian_robot, geode_robot,
                          ore + ore_robot - clay_cost, clay + clay_robot, obsidian + obsidian_robot, geode + geode_robot))
        end

        # same as clay robots
        if obsidian_robot < geode_cost[2] && can_make_obsidian
            push!(queue, (time - 1, ore_robot, clay_robot, obsidian_robot + 1, geode_robot,
                          ore + ore_robot - obsidian_cost[1], clay + clay_robot - obsidian_cost[2], obsidian + obsidian_robot, geode + geode_robot))
        end

        # if you can't make all of the robots then try just waiting for a minute
        if !(can_make_ore && can_make_clay && can_make_obsidian && can_make_geode)
            push!(queue, (time - 1, ore_robot, clay_robot, obsidian_robot, geode_robot,
                            ore + ore_robot, clay + clay_robot, obsidian + obsidian_robot, geode + geode_robot))
        end
    end
    @show blueprint, max_geodes
    return max_geodes
end

function part_one()
    blueprints = get_blueprints()
    total_quality = 0
    for blueprint in blueprints
        total_quality += test_blueprint(blueprint[2:end], 24) * blueprint[1]
    end
    return total_quality
end

function part_two()
    blueprints = get_blueprints()
    answer = 1
    for blueprint in blueprints[1:3]
        answer *= test_blueprint(blueprint[2:end], 32)
    end
    return answer
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())
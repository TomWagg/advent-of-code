using DelimitedFiles, BenchmarkTools

function get_surface_area(lava_cubes::Set, exposed_cubes::Set)
    """ Get the surface area of a set of lava cubes given set a cubes that exposed to the steam"""
    surface_area = 0
    for cube in lava_cubes
        # loop over adjacent cubes (up and down in all 3 coordinates)
        for offset in [1, -1]
            for ind in 1:3
                new_cube = copy(cube)
                new_cube[ind] += offset

                # check that the adjacent cubes is not lava but is exposed to steam
                if !(new_cube in lava_cubes) && (exposed_cubes == Set() || new_cube in exposed_cubes)
                    surface_area += 1
                end
            end
        end
    end
    return surface_area
end

function part_one()
    """Read in the cubes, turn it into a Set and just pass to get_surface_area!"""
    cubes = readdlm("../inputs/18.txt", ',', Int, '\n')
    lava_cubes = Set(eachrow(cubes))
    return get_surface_area(lava_cubes, Set())
end

function get_exposed_cubes(init_cube::Array{Int}, lava_cubes::Set, bounds::Array{Int})
    """Get a Set of cubes that are exposed to the steam using a Flood Fill algorithm"""
    # start a queue of cubes
    queue = [init_cube]
    exposed_cubes = Set()

    # repeat until queue exhausted
    while length(queue) > 0
        cube = pop!(queue)

        # if the cube is within the bounds of the coordinates and is not lava
        if all([-1, -1, -1] .<= cube .<= bounds) && !(cube in lava_cubes)
            # it's exposed!
            push!(exposed_cubes, cube)

            # now we check each of its neighbours that we haven't looked at yet
            for offset in [1, -1]
                for ind in 1:3
                    new_cube = copy(cube)
                    new_cube[ind] += offset
                    if !(new_cube in exposed_cubes)
                        push!(queue, new_cube)
                    end
                end
            end
        end
    end
    return exposed_cubes
end

function part_two()
    """Same as part 1 but now we find which cubes are exposed to steam."""
    cubes = readdlm("../inputs/18.txt", ',', Int, '\n')
    lava_cubes = Set(eachrow(cubes))

    # work out the bounds of the box and which cubes are exposed
    bounds = maximum.(eachcol(cubes)) .+ 1
    exposed_cubes = get_exposed_cubes([0, 0, 0], lava_cubes, bounds)

    # pass it over to get_surface_area and celebrate!
    return get_surface_area(lava_cubes, exposed_cubes)
end

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())

println("Timing part two...")
@btime part_two()
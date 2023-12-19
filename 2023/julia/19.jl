using DataStructures

# "xmas", love it
const condition_regex = r"([xmas])([<>])([0-9]+)"
const part_regex = r"(?<=[xmas]=)[0-9]+"

# this is definitely unnecessary, I just fancied making a struct today
mutable struct Workflows
    raw_conditions::DefaultDict{String, Vector}       # each condition represented as raw characters and ints
    func_conditions::DefaultDict{String, Vector}      # same but converted to a function that can be evaluated
    destinations::DefaultDict{String, Vector{String}} # the destination workflow after passing each condition
end

function construct_workflows(workflow_strs::Vector)
    """Construct workflows based on an array of workflows represented as strings"""
    w = Workflows(DefaultDict{String, Vector}(Vector),
                  DefaultDict{String, Vector}(Vector),
                  DefaultDict{String, Vector{String}}(Vector))

    for workflow in workflow_strs
        name, rest = replace.(split(workflow, "{"), "}"=>"")
        conditions = split.(split(rest, ","), ":")
        for i in eachindex(conditions)
            # if there's actually a condition rather than just a destination
            if length(conditions[i]) > 1
                # convert the string condition into an anonymous function that can be evaluated
                f = eval(Meta.parse("t -> " * replace(conditions[i][1],
                                                      "x"=>"t['x']", "m"=>"t['m']",
                                                      "a"=>"t['a']", "s"=>"t['s']")))
                # use a regex to split up the string condition into (category, operation, value)
                cat, op, val = match(condition_regex, conditions[i][1])
                push!(w.destinations[name], conditions[i][2])
                push!(w.raw_conditions[name], [cat[1], op[1], parse(Int, val)])
                push!(w.func_conditions[name], t -> Base.invokelatest(f, t))
            # otherwise it's a direct send-off to the destination
            else
                push!(w.destinations[name], conditions[i][1])
                push!(w.raw_conditions[name], [true])
                push!(w.func_conditions[name], t -> true)
            end
        end
    end
    return w
end

function rate_part(part::Dict{Char, Int}, w::Workflows)
    """Rate a part based on a series of conditional workflows"""
    # start with the "in" workflow
    workflow = "in"

    # continue until acceptance or rejection
    while workflow ∉ ["A", "R"]
        # check which condition this part matches in the current workflow (it'll always match at least 1)
        for (condition, destination) in zip(w.func_conditions[workflow], w.destinations[workflow])
            if condition(part)
                # if we pass the condition then move on to the next workflow
                workflow = destination
                break
            end
        end
    end
    # return the sum of the part values if it was accepted, otherwise 0
    return workflow == "A" ? sum(values(part)) : 0
end

function all_paths_to_success(w)
    """Find every path that would lead to acceptance for a part"""
    # track the successful paths
    successful_paths = []
    
    # keep a stack of paths, each path lists the required rating in each category and the next workflow
    paths = [Dict('x'=>(1, 4000), 'm'=>(1, 4000), 'a'=>(1, 4000), 's'=>(1, 4000), "next"=>"in")]
    
    # process every single path
    while length(paths) > 0
        path = pop!(paths)

        # on acceptance save path - on rejection, as one should from any rejection in life, move on
        if path["next"] == "A"
            push!(successful_paths, path)
        elseif path["next"] == "R"
            continue
        end

        # go over every condition in the current workflow
        for (condition, dest) in zip(w.raw_conditions[path["next"]], w.destinations[path["next"]])
            # when it's just a destination then update the current path and move on
            if length(condition) == 1
                path["next"] = dest
                push!(paths, path)
            else
                # otherwise we now need to track two paths: one that passes this condition and one that fails
                # the failing one will need to check the next condition, so we just edit the current path
                passing_path = copy(path)
                passing_path["next"] = dest

                # split the condition into (category, operation, value)
                cat, op, val = condition

                # apply the operation to the passing path and the opposite to the failing path
                if op == '<'
                    # "val - 1" because less than, not "less than or equal to"
                    passing_path[cat] = (path[cat][1], min(path[cat][2], val - 1))
                    path[cat] = (max(path[cat][1], val), path[cat][2])
                else
                    # "val + 1" because greater than, not "greater than or equal to"
                    passing_path[cat] = (max(path[cat][1], val + 1), path[cat][2])
                    path[cat] = (path[cat][1], min(path[cat][2], val))
                end
                push!(paths, passing_path)
            end
        end
    end
    return successful_paths
end

# read in the workflow strings and parts string
workflow_strs, parts_str = split.(split(read("../inputs/19.txt", String), "\n\n"), '\n')

# construct workflows from the string and work out which paths would produce success
workflows = construct_workflows(workflow_strs)
successful_paths = all_paths_to_success(workflows)

# sum up the ratings for every part
parts = [Dict{Char, Int}(key=>val for (key, val) in zip("xmas",
         [parse(Int, m.match) for m in eachmatch(part_regex, part)])) for part in parts_str]
part_one() = reduce(+, rate_part(part, workflows) for part in parts)

# sum up the number of ratings that fit into each successful path
part_two() = reduce(+, mapreduce(x->x[2] - x[1] + 1, *, [path[key] for key in "xmas"]; init=1)
                    for path in successful_paths)

println("PART ONE: ", part_one())
println("PART TWO: ", part_two())

mutable struct Dir
    size::Int
    subdirs::Dict{String, Dir}
    parent
    visited::Bool
end

function file_tree_sizes()
    file_tree = Dir(0, Dict(), nothing, true)
    open("../inputs/7.txt", "r") do input
        current_dir = file_tree
        for line in eachline(input)
            # if the line is changing directories
            if line[1:4] == "\$ cd"
                # work out where you are changing to and do it
                target = split(line, " ")[3]
                if target == ".."
                    current_dir = current_dir.parent
                elseif target == "/"
                    current_dir = file_tree
                else
                    current_dir = current_dir.subdirs[target]
                end;
            # otherwise if it a directory name then create a new Dir with current as parent
            elseif line[1:3] == "dir"
                current_dir.subdirs[split(line, " ")[2]] = Dir(0, Dict(), current_dir, false)
            # finally any other line that isn't listing files will be a file
            elseif line != "\$ ls"
                # work out file size
                file_size = parse(Int, split(line, " ")[1])

                # add to current dir size and dir size of all parents
                current_dir.size += file_size
                pdir = current_dir.parent
                while pdir != nothing
                    pdir.size += file_size
                    pdir = pdir.parent
                end;
            end;
        end;
    end;
    
    # perform a DFS summing directories with at most 100,000
    total = dfs_sums(deepcopy(file_tree))
    println("PART ONE: ", total)

    # work out the minimum size that would clear enough space
    clear_size = 30000000 - (70000000 - file_tree.size)

    # perform a DFS finding the smallest directory that 
    options = dfs_deletes(file_tree, 70000000, clear_size)
    println("PART TWO: ", options)

    return nothing
end;


function dfs_sums(dir::Dir)
    dir.visited = true
    if dir.size <= 100000
        total = dir.size
    else
        total = 0
    end;

    for (key, value) in dir.subdirs
        if ~value.visited
            total += dfs_sums(value)
        end;
    end;
    return total
end;

function dfs_deletes(dir::Dir, delete_size::Int, clear_size::Int)
    dir.visited = true
    if dir.size >= clear_size
        delete_size = min(delete_size, dir.size)
    end;

    for (key, value) in dir.subdirs
        if ~value.visited
            delete_size = min(delete_size, dfs_deletes(value, delete_size, clear_size))
        end;
    end;
    return delete_size
end;


file_tree_sizes()
from collections import defaultdict


def build_graph(pairs):
    # build up a dictionary of edges
    graph = defaultdict(list)
    for start, end in pairs:
        # edges in both directions
        graph[start].append(end)
        graph[end].append(start)
    return graph


def find_paths_to_end(graph, start="start", current_path=["start"], paths=0):
    # go through every node attached to this one
    for node in graph[start]:
        # as long as the node isn't already in the path and lowercase (or the end)
        if not (node in current_path and node.islower()) and node != "end":
            # try every path from this node
            paths = find_paths_to_end(graph, start=node, current_path=current_path + [node], paths=paths)
        # add to path totals whenever the end is found
        elif node == "end":
            paths += 1
    # return the total
    return paths


def find_paths_to_end_part_two(graph, start="start", current_path=["start"], double_visit=False, paths=0):
    # go through every node attached to this one
    for node in graph[start]:
        # special case for the end of the line
        if node == "end":
            paths += 1
        # as long as we haven't visited the cave when it is small then continue searching
        elif not (node in current_path and node.islower()):
            paths = find_paths_to_end_part_two(graph, start=node, current_path=current_path + [node],
                                               double_visit=double_visit, paths=paths)
        # ignore unless we haven't visited one twice yet
        elif not double_visit and node != "start":
            paths = find_paths_to_end_part_two(graph, start=node, current_path=current_path + [node],
                                               double_visit=True, paths=paths)

    # return the total
    return paths


def main():
    pairs = []
    with open("../inputs/12.txt") as input:
        for line in input:
            pairs.append(line.strip().split("-"))

    graph = build_graph(pairs)
    paths = find_paths_to_end(graph)
    print("PART ONE:", paths)

    paths = find_paths_to_end_part_two(graph)
    print("PART TWO:", paths)


if __name__ == "__main__":
    main()

import numpy as np
from collections import defaultdict
from itertools import product
import time


def find_offset(s_base, s_offset, threshold=12):
    base_set = set([tuple(beacon) for beacon in s_base])
    for b1, b2 in product(s_base, s_offset):
        offset = b1 - b2
        offset_set = set([tuple(beacon + offset) for beacon in s_offset])
        if len(base_set.intersection(offset_set)) >= threshold:
            return offset
    return None


def rotate_and_move_scanner(s_base, s_other, threshold=12):
    s_other_vector = s_other.T
    angles = [0, np.pi / 2, np.pi, 3/2 * np.pi]
    for theta_x, theta_y, theta_z in product(angles, angles, angles):
        rotated_vector = rotate_around_z(*rotate_around_y(*rotate_around_x(*s_other_vector, theta_x), theta_y), theta_z)
        rotated_s_other = np.transpose(rotated_vector)

        offset = find_offset(s_base, rotated_s_other, threshold=threshold)
        if offset is not None:
            return [theta_x, theta_y, theta_z], offset

    return None, None


class Graph():
    def __init__(self, edges):
        self.edges = edges
        self.paths = None

    def search_graph(self, start):
        self.visited = set()
        self.paths = dict()
        self.current_path = list()
        self.search_graph_util(node=start)
        return self.paths

    def search_graph_util(self, node):
        self.visited.add(node)
        self.current_path.append(node)
        for neighbour in self.edges[node]:
            if neighbour not in self.visited:
                self.paths[neighbour] = self.current_path.copy()
                self.search_graph_util(node=neighbour)
        self.current_path.pop()


def manhattan_distance(scanner_0, scanner_1):
    return sum([abs(scanner_0[i] - scanner_1[i]) for i in range(3)])


def main():
    # grab the scanners from the input file
    scanners = []
    with open("../inputs/19.txt", "r") as input:
        current_scanner = None
        for line in input:
            line = line.strip()
            if line == "":
                continue
            if line[:3] == "---":
                new_scanner = []
                if current_scanner is not None:
                    scanners.append(np.array(current_scanner))
                current_scanner = new_scanner
            else:
                beacon = list(map(int, line.split(",")))
                current_scanner.append(beacon)
        scanners.append(np.array(current_scanner))

    # start off a graph that related the various scanners
    g = Graph(edges=defaultdict(list))
    transformations = defaultdict(tuple)

    USE_FILE = True
    if USE_FILE:
        transformations = np.load("transformations.npy", allow_pickle=True).item()
        g.edges = np.load("edges.npy", allow_pickle=True).item()
    else:
        start = time.time()
        for i in range(len(scanners)):
            for j in range(len(scanners)):
                if transformations[j, i] == (None, None) or i == j:
                    transformations[i, j] = (None, None)
                else:
                    transform = rotate_and_move_scanner(scanners[i], scanners[j], threshold=12)
                    print((i, j), transform)
                    transformations[i, j] = transform
                    if transform != (None, None):
                        g.edges[i].append(j)
        print("Time to go through all scanners was {:1.2f}".format(time.time() - start))

        np.save("transformations.npy", transformations, allow_pickle=True)
        np.save("edges.npy", g.edges, allow_pickle=True)

    # find how to get to each scanner from the first one
    g.search_graph(0)

    locations = [[0, 0, 0]]
    beacons = set([tuple(beacon) for beacon in scanners[0]])
    for i in range(1, len(scanners)):
        path = g.paths[i]
        operations = []
        for j in range(len(path)):
            op = None
            if j == len(path) - 1:
                op = (path[j], i)
            else:
                op = (path[j], path[j + 1])

            if op not in transformations.keys():
                print("CAN'T CONNECT THEM! :o")
                return

            operations.append(op)

        scanner_location = [0, 0, 0]
        adjusted_scanner = scanners[i]
        for op in list(reversed(operations)):
            angle, offset = transformations[op]
            theta_x, theta_y, theta_z = angle

            adjusted_scanner = np.concatenate((adjusted_scanner, [scanner_location]))
            s_other_vector = adjusted_scanner.T
            rotated_vector = rotate_around_z(*rotate_around_y(*rotate_around_x(*s_other_vector, theta_x), theta_y), theta_z)
            adjusted_scanner = np.transpose(rotated_vector)

            adjusted_scanner += offset

            scanner_location, adjusted_scanner = adjusted_scanner[-1], adjusted_scanner[:-1]

        locations.append(scanner_location)
        beacons = beacons.union(set([tuple(beacon) for beacon in adjusted_scanner]))

    print("PART ONE:", len(beacons))

    max_distance = -1
    for pair in product(locations, repeat=2):
        max_distance = max(max_distance, manhattan_distance(*pair))
    print("PART TWO:", max_distance)




def rotate_around_x(x, y, z, theta):
    c, s = np.cos(theta).astype(int), np.sin(theta).astype(int)
    return [x, c * y - s * z, s * y + c * z]


def rotate_around_y(x, y, z, theta):
    c, s = np.cos(theta).astype(int), np.sin(theta).astype(int)
    return [c * x + s * z, y, -s * x + c * z]


def rotate_around_z(x, y, z, theta):
    c, s = np.cos(theta).astype(int), np.sin(theta).astype(int)
    return [c * x - s * y, s * x + c * y, z]


if __name__ == "__main__":
    main()

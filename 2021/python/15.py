import numpy as np


def shortest_path(risks):
    """ Dijkstra's algorithm basically, find the shortest path to all nodes """
    n_row = len(risks)
    n_col = len(risks[0])
    distances = np.ones_like(risks) * np.inf
    distances[0, 0] = 0

    visited = np.zeros_like(risks).astype(bool)

    row, col = 0, 0
    while not np.all(visited):
        visited[row, col] = True
        for delta in [-1, 1]:
            new_row = row + delta
            if new_row >= 0 and new_row < n_row and not visited[new_row, col]:
                distances[new_row, col] = min(distances[row, col] + risks[new_row, col], distances[new_row, col])

            new_col = col + delta
            if new_col >= 0 and new_col < n_col and not visited[row, new_col]:
                distances[row, new_col] = min(distances[row, col] + risks[row, new_col], distances[row, new_col])

        min_index = np.where(visited, np.inf, distances).argmin()
        row, col = np.unravel_index(min_index, risks.shape)
    return distances[-1, -1].astype(int)


def grow_risks(risks):
    """ create the larger risk grid """
    rows, cols = risks.shape
    new_risks = np.zeros((rows * 5, cols * 5))

    for i in range(5):
        for j in range(5):
            risk_block = np.mod(risks + (i + j), 9)
            risk_block[risk_block == 0] = 9
            new_risks[i * rows:(i + 1) * rows, j * cols:(j + 1) * cols] = risk_block

    return new_risks.astype(int)


def main():
    risks = []
    with open("../inputs/15.txt", "r") as input:
        for line in input:
            risks.append(list(map(int, list(line.strip()))))
    risks = np.array(risks).astype(int)
    print("PART ONE:", shortest_path(risks))

    # grow the risk grid and repeat (this is a bit slow but still under a minute)
    risks = grow_risks(risks)
    print("PART TWO:", shortest_path(risks))


if __name__ == "__main__":
    main()

from scipy.optimize import linprog
import numpy as np
from time import time

def part_two():
    total = 0
    with open("inputs/10.txt") as f:
        for line in f:
            split_line = line.split()
            buttons_str = split_line[1:-1]
            joltage = split_line[-1]

            goal = [int(j) for j in joltage[1:-1].split(',')]
            buttons = [list(map(int, b[1:-1].split(','))) for b in buttons_str]
            
            button_matrix = np.zeros((len(buttons), len(goal)), dtype=int)
            for i, b in enumerate(buttons):
                button_matrix[i, b] = 1
            
            total += int(linprog([1 for _ in buttons], A_eq=button_matrix.T, b_eq=goal, integrality=1).fun)
    
    return total


def main():
    start = time()
    print("PART TWO:", part_two())
    print(f"  {time() - start:1.2f} seconds")

main()
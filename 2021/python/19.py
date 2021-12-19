import numpy as np

def main():
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

    print(scanners)


if __name__ == "__main__":
    main()

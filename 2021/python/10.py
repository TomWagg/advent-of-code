def main():
    openers = ["(", "[", "{", "<"]
    closers = [")", "]", "}", ">"]
    close_to_open = {")": ("(", 3),
                     "]": ("[", 57),
                     "}": ("{", 1197),
                     ">": ("<", 25137)}
    open_to_close = {"(": (")", 1),
                     "[": ("]", 2),
                     "{": ("}", 3),
                     "<": (">", 4)}

    with open("../inputs/10.txt") as input:
        total_corruption = 0
        incomplete_totals = []
        for line in input:
            queue = []
            corrupt = False
            for character in line.strip():
                if character in openers:
                    queue.append(character)
                if character in closers:
                    actual = queue.pop()
                    expected, value = close_to_open[character]
                    if expected != actual:
                        total_corruption += value
                        corrupt = True
                        break

            if not corrupt:
                total_incomplete = 0
                while queue != []:
                    required, value = open_to_close[queue.pop()]
                    total_incomplete *= 5
                    total_incomplete += value
                incomplete_totals.append(total_incomplete)

    print("PART ONE:", total_corruption)
    print("PART TWO:", sorted(incomplete_totals)[(len(incomplete_totals) - 1) // 2])


if __name__ == "__main__":
    main()

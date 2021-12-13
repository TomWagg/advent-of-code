def main():
    openers = ["(", "[", "{", "<"]
    closers = [")", "]", "}", ">"]
    matches = {")": ("(", 3, 1),
               "]": ("[", 57, 2),
               "}": ("{", 1197, 3),
               ">": ("<", 25137, 4)}

    with open("../inputs/10.txt") as input:
        total_corruption = 0
        for line in input:
            queue = []
            for character in line.strip():
                if character in openers:
                    queue.append(character)
                if character in closers:
                    actual = queue.pop()
                    expected, value, _ = matches[character]
                    if expected != actual:
                        total_corruption += value
                        break

            if queue != []:
                print("INCOMLETE LINE")

    print(total_corruption)


if __name__ == "__main__":
    main()

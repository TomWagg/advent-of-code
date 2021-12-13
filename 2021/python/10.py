def main():
    # define which are open and close
    openers = ["(", "[", "{", "<"]
    closers = [")", "]", "}", ">"]

    # map open and close brackets and values
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

        # go through each line in the file
        for line in input:

            # start a queue
            queue = []
            corrupt = False
            for character in line.strip():
                # if the character is an opener then push to queue
                if character in openers:
                    queue.append(character)

                # if the character is a closer
                if character in closers:
                    # get the expected open one from the map
                    expected, value = close_to_open[character]
                    actual = queue.pop()

                    # check if the actual one in the queue was the expected value
                    if expected != actual:
                        # if not we have a corruption, add to the value and break
                        total_corruption += value
                        corrupt = True
                        break

            # if you finished a line without a corruption and something in the queue
            if not corrupt and queue != []:
                # line is incomplete, find the value
                total_incomplete = 0

                while queue != []:
                    total_incomplete *= 5

                    # pop a value off the queue and add to the total
                    _, value = open_to_close[queue.pop()]
                    total_incomplete += value

                # append to the list
                incomplete_totals.append(total_incomplete)

    # print out the total corruption value
    print("PART ONE:", total_corruption)

    # print out the median incomplete value
    print("PART TWO:", sorted(incomplete_totals)[(len(incomplete_totals) - 1) // 2])


if __name__ == "__main__":
    main()

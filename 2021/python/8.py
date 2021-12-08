def count_unique_segments(output_values):
    # unique segment lengths are 2,4,3 and 7 for 1,4,7 and 8 respectively
    unique_lengths = set([2, 4, 3, 7])

    # sum up the lengths in the flattened output values that match this
    return sum([int(len(j) in unique_lengths) for sub in output_values for j in sub])


def main():
    # read in the file
    signal_patterns = []
    output_values = []
    with open("../inputs/8.txt", "r") as input:
        for line in input:
            signal_pattern, output_value = line.strip().split(" | ")
            signal_patterns.append(signal_pattern.split())
            output_values.append(output_value.split())

    print("PART ONE:", count_unique_segments(output_values))


if __name__ == "__main__":
    main()

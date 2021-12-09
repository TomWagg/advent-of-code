def count_unique_segments(output_values):
    # unique segment lengths are 2,4,3 and 7 for 1,4,7 and 8 respectively
    unique_lengths = set([2, 4, 3, 7])

    # sum up the lengths in the flattened output values that match this
    return sum([int(len(j) in unique_lengths) for sub in output_values for j in sub])


def decode_output(signal_patterns, output_values):
    """ This one was a bloody hassle :D """

    # start a running count of the values
    value = 0

    # go through each pattern, output list pair
    for i in range(len(signal_patterns)):

        length_five = []
        length_six = []

        # find the unique numbers and the groups that have lengths 5 or 6
        for j in range(len(signal_patterns[i])):
            if len(signal_patterns[i][j]) == 2:
                one = set(signal_patterns[i][j])
            elif len(signal_patterns[i][j]) == 3:
                seven = set(signal_patterns[i][j])
            elif len(signal_patterns[i][j]) == 4:
                four = set(signal_patterns[i][j])
            elif len(signal_patterns[i][j]) == 7:
                eight = set(signal_patterns[i][j])
            elif len(signal_patterns[i][j]) == 5:
                length_five.append(set(signal_patterns[i][j]))
            elif len(signal_patterns[i][j]) == 6:
                length_six.append(set(signal_patterns[i][j]))
            else:
                raise ValueError("problem")

        # by comparison we can find pairs of vlaues using one, four, seven and eight
        top_left_or_middle = list(four.difference(one))
        bottom_left_or_bottom = list(eight.difference(set.union(seven, four)))

        # then we go logically through and work out which number is which
        for number in length_five:
            # only number five will contain both the top left and middle
            if top_left_or_middle[0] in number and top_left_or_middle[1] in number:
                five = number
            # only number two will contain both the bottom left and bottom
            elif bottom_left_or_bottom[0] in number and bottom_left_or_bottom[1] in number:
                two = number
            else:
                three = number

        for number in length_six:
            # only number zero won't contain both the top left and middle
            if not (top_left_or_middle[0] in number and top_left_or_middle[1] in number):
                zero = number
            # only number nine won't contain both the bottom left and bottom
            elif not (bottom_left_or_bottom[0] in number and bottom_left_or_bottom[1] in number):
                nine = number
            else:
                six = number

        # et voila, a list of sets corresponding to numbers
        numbers = [zero, one, two, three, four, five, six, seven, eight, nine]

        # now we go through each digit output value
        output = []
        for j in range(len(output_values[i])):
            # create a set of the output value and find the corresponding number
            output_set = set(output_values[i][j])
            for k in range(len(numbers)):
                if output_set == numbers[k]:
                    # store that digit
                    output.append(str(k))

        # join the digits into a number and increment the value by this amount
        value += int("".join(output))
    return value


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
    print("PART TWO:", decode_output(signal_patterns, output_values))


if __name__ == "__main__":
    main()

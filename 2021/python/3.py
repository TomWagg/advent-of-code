
def binary_to_decimal(binary):
    decimal = 0
    for i in range(len(binary)):
        decimal += int(binary[i]) * 2**(len(binary) - 1 - i)
    return decimal


def get_most_common(diagnostics, digit):
    total = 0
    for i in range(len(diagnostics)):
        total += int(diagnostics[i][digit])
    total /= len(diagnostics)

    return 0 if total < 0.5 else 1


def main():
    # read in diagnostics
    with open("../inputs/3.txt") as input:
        diagnostics = [line.replace("\n", "") for line in input]

    # count how many digits in each binary number
    n_digit = len(diagnostics[0])

    most_common = ""
    least_common = ""

    # loop over each digit
    for i in range(n_digit):
        # this gives most common and least common
        most = get_most_common(diagnostics, i)
        most_common += str(most)
        least_common += str(1 - most)

    # convert numbers to decimals and multiply
    power = binary_to_decimal(most_common) * binary_to_decimal(least_common)

    # part 1 done!
    print(power)


if __name__ == "__main__":
    main()


def binary_to_decimal(binary):
    decimal = 0
    for i in range(len(binary)):
        decimal += int(binary[i]) * 2**(len(binary) - 1 - i)
    return decimal


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
        total = 0

        # loop over each diagnostic and sum the digits
        for j in range(len(diagnostics)):
            total += int(diagnostics[j][i])

        # divide by the total number of diagnostics
        total /= len(diagnostics)

        # this gives most common and least common
        most_common += str(0) if total < 0.5 else str(1)
        least_common += str(1) if total < 0.5 else str(0)

    # convert numbers to decimals and multiply
    power = binary_to_decimal(most_common) * binary_to_decimal(least_common)

    # part 1 done!
    print(power)


if __name__ == "__main__":
    main()

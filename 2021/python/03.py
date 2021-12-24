
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

    # < not <= so that equal numbers give 1's
    return 0 if total < 0.5 else 1


def get_power_consumption(diagnostics):
    # count how many digits in each binary number
    n_digit = len(diagnostics[0])

    most_common = ""
    least_common = ""

    # get most and least common at each digit
    for i in range(n_digit):
        most = get_most_common(diagnostics, i)
        most_common += str(most)
        least_common += str(1 - most)

    # convert numbers to decimals and multiply
    return binary_to_decimal(most_common) * binary_to_decimal(least_common)


def get_gas_rating(diagnostics, bit_position, least):
    """ Get the rating for either O2 generation or CO2 scrubbing """
    # find the most common bit at this bit position
    most_common = get_most_common(diagnostics, bit_position)
    criterion = 1 - most_common if least else most_common

    reduced_diagnostics = []
    for i in range(len(diagnostics)):
        if diagnostics[i][bit_position] == str(criterion):
            reduced_diagnostics.append(diagnostics[i])

    if len(reduced_diagnostics) == 1:
        return binary_to_decimal(reduced_diagnostics[0])
    else:
        return get_gas_rating(reduced_diagnostics, bit_position + 1,
                              least=least)


def get_life_support(diagnostics):
    return get_gas_rating(diagnostics, 0, least=False) \
        * get_gas_rating(diagnostics, 0, least=True)


def main():
    # read in diagnostics
    with open("../inputs/3.txt") as input:
        diagnostics = [line.replace("\n", "") for line in input]

    print("PART ONE:", get_power_consumption(diagnostics))
    print("PART TWO:", get_life_support(diagnostics))


if __name__ == "__main__":
    main()

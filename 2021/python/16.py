import math


def hex_to_bin(hexstring):
    """ lazy conversion of hexstrings to binarystrings """
    mapper = {
        '0': '0000',
        '1': '0001',
        '2': '0010',
        '3': '0011',
        '4': '0100',
        '5': '0101',
        '6': '0110',
        '7': '0111',
        '8': '1000',
        '9': '1001',
        'A': '1010',
        'B': '1011',
        'C': '1100',
        'D': '1101',
        'E': '1110',
        'F': '1111'
    }
    binarystring = ""
    for letter in hexstring:
        binarystring += mapper[letter]
    return binarystring


def parse_literal(packet, start):
    """ parse a literal value from a packet """
    literal = ""
    keep_going = True
    cursor = start
    while keep_going:
        keep_going = packet[cursor] == "1"
        literal += packet[cursor + 1: cursor + 5]
        cursor += 5
    return int(literal, 2), cursor


def parse_packet(packet, cursor=0, version_total=0):
    # ignore any zeros at the end if the packet is not long enough
    if len(packet[cursor:]) < 7:
        cursor += len(packet[cursor:])
        return cursor, version_total

    # add to the version number total and get the type
    version_total += int(packet[cursor:cursor + 3], 2)
    type_id = int(packet[cursor + 3:cursor + 6], 2)
    cursor += 6

    # if it's a literal value then parse it
    if type_id == 4:
        value, cursor = parse_literal(packet, cursor)

    # if it's an operator
    else:
        values = []
        length_type = packet[cursor]
        cursor += 1

        # if the type is giving a longest length
        if length_type == "0":
            # find that length
            length = int(packet[cursor:cursor + 15], 2)
            cursor += 15
            final_cursor = cursor + length

            # parse new packets until you hit it, appending the results
            while cursor < final_cursor:
                value, cursor, version_total = parse_packet(packet, cursor, version_total)
                values.append(value)
        else:
            # find the number of packets
            n_packets = int(packet[cursor: cursor + 11], 2)
            cursor += 11

            # parse that number of packets and append the values
            for _ in range(n_packets):
                value, cursor, version_total = parse_packet(packet, cursor, version_total)
                values.append(value)

        # perform the desired operation based on rules
        if type_id == 0:
            value = sum(values)
        elif type_id == 1:
            value = math.prod(values)
        elif type_id == 2:
            value = min(values)
        elif type_id == 3:
            value = max(values)
        elif type_id == 5:
            value = 1 if values[0] > values[1] else 0
        elif type_id == 6:
            value = 1 if values[0] < values[1] else 0
        elif type_id == 7:
            value = 1 if values[0] == values[1] else 0

    return value, cursor, version_total


def main():
    with open("../inputs/16.txt") as input:
        hexstring = input.readline().strip()

    value, _, version = parse_packet(hex_to_bin(hexstring))
    print("PART ONE:", version)
    print("PART TWO:", value)


if __name__ == "__main__":
    main()

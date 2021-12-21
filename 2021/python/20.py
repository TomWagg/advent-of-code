import numpy as np


def print_image(img, padding=0):
    """ print out an image for debugging """
    if padding > 0:
        img = np.pad(img, padding, mode="constant", constant_values=".")
    for line in img:
        print("".join(line))


def enhance_once(img, algorithm, pad_char):
    """ enhance an image once with a given algorithm """
    # pad the image so that we capture its 'infiniteness'
    img = np.pad(img, 2, mode="constant", constant_values=pad_char)

    # copy the array so we can use the original as a reference
    enhanced_img = img.copy()

    # for each of the pixel (ignoring the outer layer of padding)
    for i in range(1, len(enhanced_img) - 1):
        for j in range(1, len(enhanced_img[0]) - 1):
            # assemble the binary string of adjacent pixels
            index_string = ""
            for val in [-1, 0, 1]:
                index_string += ''.join(img[i + val, j - 1: j + 2])
            # turn it into zeros and ones, convert to integer
            index_string = index_string.replace(".", "0").replace("#", "1")
            index = int(index_string, 2)

            # use that integer as the index in the 'algorithm'
            enhanced_img[i, j] = algorithm[index]

    return enhanced_img


def enhance(img, algorithm, n, debug=False):
    """ enhance an image n times using a given algorithm """
    if debug:
        print_image(img)

    # initially pad the outside with dots
    pad_char = "."

    # enhance the image twice, printing each time
    for pad in range(n):
        img = enhance_once(img, algorithm, pad_char=pad_char)

        # check if the sneaky buggers but a # for the first index :p
        if algorithm[0] == "#":
            # if so we need to alternate the edge padding with what the algorithm says
            if pad % 2 == 0:
                pad_char = algorithm[0]
            else:
                pad_char = algorithm[-1]

            # set the edges after changing the padding
            img[[0, -1], :] = pad_char
            img[:, [0, -1]] = pad_char

        if debug:
            print()
            print_image(img)
    return img


def main():
    # get algorithm and image from file
    with open("../inputs/20.txt", "r") as input:
        algorithm = input.readline().strip()
        img = []
        for line in input:
            line = line.strip()
            if line != "":
                img.append(list(line))

    # convert to numpy array and print out the original
    img = np.array(img)

    # find number of lit up pixels
    p1_img = enhance(img, algorithm, 2)
    print("PART ONE:", len(p1_img[p1_img == "#"]))

    # same again for part 2 but even more
    p2_img = enhance(p1_img, algorithm, 48)
    print("PART ONE:", len(p2_img[p2_img == "#"]))


if __name__ == "__main__":
    main()

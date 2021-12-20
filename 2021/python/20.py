import numpy as np


def print_image(img):
    for line in img:
        print("".join(line))


def enhance(img, algorithm):
    img = np.pad(img, 2, mode="constant", constant_values=".")
    enhanced_img = img.copy()

    for i in range(1, len(enhanced_img) - 1):
        for j in range(1, len(enhanced_img[0]) - 1):
            index_string = ""
            for val in [-1, 0, 1]:
                index_string += ''.join(img[i + val, j - 1: j + 2])
            index_string = index_string.replace(".", "0").replace("#", "1")
            index = int(index_string, 2)

            enhanced_img[i, j] = algorithm[index]

    return enhanced_img


def main():
    with open("../inputs/20.txt", "r") as input:
        algorithm = input.readline().strip()
        img = []
        for line in input:
            line = line.strip()
            if line != "":
                img.append(list(line))
    img = np.array(img)
    print_image(img)

    for _ in range(2):
        img = enhance(img, algorithm)
        print_image(img)

    print("PART ONE:", len(img[img == "#"]))

if __name__ == "__main__":
    main()

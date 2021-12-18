from math import floor, ceil
from copy import deepcopy


class Pear():
    """ Yes I do mean Pear not Pair. It's a Pear tree. Aren't I hilarious? (: """
    def __init__(self, id, children=[], value=None, parent=None, depth=0):
        self.id = id
        self.children = children
        self.parent = parent
        self.depth = depth
        self.value = value

    def self_index(self):
        """ Find the index of this pair in its parent child array """
        return self.parent.children.index(self)

    def get_adjacent(self, direction):
        """ Get the adjacent value to either the left or right, return None if there are none """
        current = self
        limit = 0 if direction == "left" else len(current.parent.children) - 1

        # search through parents until this pair isn't either the first or last child (depending on direction)
        while current.self_index() == limit:
            current = current.parent
            # if you hit the root then give up
            if current.parent is None:
                return None

            limit = 0 if direction == "left" else len(current.parent.children) - 1

        # once you find the right start then drill down until you hit the closest thing
        sign = -1 if direction == "left" else 1
        index = -1 if direction == "left" else 0
        drill_here = current.parent.children[current.self_index() + sign]
        while drill_here.value is None:
            drill_here = drill_here.children[index]

        return drill_here

    def explode_tree(self):
        # find every possible explosion in the tree
        if self.children is not None:
            if self.depth >= 4:
                self.explode()
            else:
                for child in self.children:
                    child.explode_tree()

    def split_tree(self):
        # find every possible value to split in the tree
        if self.value is None:
            check = True
            for child in self.children:
                check = child.split_tree()
                # return immediately if something splits
                if not check:
                    return check
            return check
        elif self.value > 9:
            # split if the value is too large
            self.split()
            return False
        else:
            return True

    def reduce(self):
        # loop over the tree exploding and splitting until done
        # NOTE: this is very wasteful right now, could probably be smarter but it took too long
        done = False
        while not done:
            self.explode_tree()
            done = self.split_tree()

    def explode(self):
        # only explode pairs with 2 numbers as children
        assert len(self.children) == 2
        assert self.children[0].value is not None
        assert self.children[1].value is not None

        # increase the value on the left and right
        left = self.get_adjacent("left")
        if left is not None:
            left.value += self.children[0].value

        right = self.get_adjacent("right")
        if right is not None:
            right.value += self.children[1].value

        # remove children and set the value to 0
        self.children = None
        self.value = 0

    def split(self):
        # only split values not pairs
        assert self.value is not None

        # remove value and add children
        left, right = floor(self.value / 2), ceil(self.value / 2)
        self.value = None
        self.children = []
        self.children.append(Pear(id=self.id, parent=self, children=None, value=left, depth=self.depth + 1))
        self.children.append(Pear(id=self.id, parent=self, children=None, value=right, depth=self.depth + 1))

        # explode if necessary
        if self.depth >= 4:
            self.explode()

    def deepen(self):
        # increase the depth of everything in the tree by 1
        self.depth += 1
        if self.children is not None:
            for child in self.children:
                child.deepen()

    def add(self, pair):
        """ add a pair to this one """
        new_base = Pear(id=-1, children=[self, pair], parent=None, value=None, depth=0)

        self.deepen()
        self.parent = new_base

        pair.deepen()
        pair.parent = new_base
        return new_base

    def magnitude(self):
        """ calculate the magnitude of the tree """
        if self.children is None:
            return self.value
        else:
            return 3 * self.children[0].magnitude() + 2 * self.children[1].magnitude()

    def print(self, end="\n", suffix=","):
        """ print out the tree just like the problem, highlight anything incorrect in red """
        if self.children is not None:
            if self.depth >= 4:
                print("\033[91m[\033[0m", end="")
            else:
                print("[", end="")
            for i, child in enumerate(self.children):
                child.print(end="", suffix="" if i == len(self.children) - 1 else ",")
            suffix = "" if end == "\n" else suffix
            print("]" + suffix, end=end)
        else:
            if self.value > 9:
                print("\033[91m{}\033[0m{}".format(str(self.value), suffix), end="")
            else:
                print(str(self.value) + suffix, end="")


def get_pairs():
    """ Get the pairs from the file """
    pairs = []
    with open("../inputs/18.txt", "r") as input:
        for line in input:
            if line[0] != "#":
                # create the base pair and set cursor to it
                base_pair = Pear(id=-1, children=[], value=None, parent=None, depth=0)
                current = base_pair

                # loop over every character
                for i, char in enumerate(line[1:-1]):
                    if char == "[":
                        # create a new pair as a child of the current pair
                        pair = Pear(id=i, parent=current, children=[], depth=current.depth + 1)
                        current.children.append(pair)

                        # set the current pair to the new one
                        current = pair
                    elif char.isnumeric():
                        # add values to pairs
                        current.children.append(Pear(id=i, parent=current, children=None,
                                                     value=int(char), depth=current.depth + 1))
                    elif char == "]":
                        # end the current pair and move back to the parent
                        current = current.parent
                pairs.append(base_pair)
    return pairs


def main():
    pairs = get_pairs()
    final_pair = pairs[0]
    for i in range(len(pairs) - 1):
        final_pair = final_pair.add(pairs[i + 1])
        final_pair.reduce()

    print("PART ONE:", final_pair.magnitude())

    pairs = get_pairs()
    max_magnitude = -1
    for i in range(len(pairs)):
        for j in range(i + 1, len(pairs)):
            first, second = deepcopy(pairs[i]), deepcopy(pairs[j])
            forwards = first.add(second)
            forwards.reduce()

            first, second = deepcopy(pairs[i]), deepcopy(pairs[j])
            backwards = second.add(first)
            backwards.reduce()

            max_magnitude = max(max_magnitude, max(forwards.magnitude(), backwards.magnitude()))

    print("PART TWO:", max_magnitude)


if __name__ == "__main__":
    main()

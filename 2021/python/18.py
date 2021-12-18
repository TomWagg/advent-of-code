from math import floor, ceil


class Pear():
    def __init__(self, id, children=[], value=None, parent=None, depth=0):
        self.id = id
        self.children = children
        self.parent = parent
        self.depth = depth
        self.value = value

    def __str__(self):
        if self.value is None:
            return "<Pear: {}, Parent {}, has children>".format(self.id, self.parent.id
                                                                if self.parent is not None else "None")
        else:
            return "<Pear: {}, Parent {}, Value {}>".format(self.id, self.parent.id
                                                            if self.parent is not None else "None",
                                                            self.value)

    def self_index(self):
        return self.parent.children.index(self)

    def get_adjacent(self, direction):
        current = self
        limit = 0 if direction == "left" else len(current.parent.children) - 1
        while current.self_index() == limit:
            current = current.parent
            if current.parent is None:
                return None

            limit = 0 if direction == "left" else len(current.parent.children) - 1

        sign = -1 if direction == "left" else 1
        index = -1 if direction == "left" else 0
        drill_here = current.parent.children[current.self_index() + sign]
        while drill_here.value is None:
            drill_here = drill_here.children[index]

        return drill_here

    def explode_tree(self):
        if self.children is not None:
            if self.depth >= 4:
                self.explode()
            else:
                for child in self.children:
                    child.explode_tree()

    def split_tree(self):
        if self.value is None:
            check = True
            for child in self.children:
                check = child.split_tree()
                if not check:
                    return check
            return check
        elif self.value > 9:
            self.split()
            return False
        else:
            return True

    def reduce(self):
        done = False
        while not done:
            self.explode_tree()
            done = self.split_tree()

    def explode(self):
        # only explode pairs with 2 numbers as children
        assert len(self.children) == 2
        assert self.children[0].value is not None
        assert self.children[1].value is not None

        left = self.get_adjacent("left")
        if left is not None:
            left.value += self.children[0].value

        right = self.get_adjacent("right")
        if right is not None:
            right.value += self.children[1].value

        self.children = None
        self.value = 0

    def split(self):
        assert self.value is not None

        left, right = floor(self.value / 2), ceil(self.value / 2)
        self.value = None
        self.children = []
        self.children.append(Pear(id=self.id, parent=self, children=None, value=left, depth=self.depth + 1))
        self.children.append(Pear(id=self.id, parent=self, children=None, value=right, depth=self.depth + 1))

        if self.depth >= 4:
            self.explode()

    def deepen(self):
        self.depth += 1
        if self.children is not None:
            for child in self.children:
                child.deepen()

    def add(self, pair):
        new_base = Pear(id=-1, children=[self, pair], parent=None, value=None, depth=0)

        self.deepen()
        self.parent = new_base

        pair.deepen()
        pair.parent = new_base
        return new_base

    def magnitude(self):
        if self.children is None:
            return self.value
        else:
            return 3 * self.children[0].magnitude() + 2 * self.children[1].magnitude()

    def recursive_print(self, end="\n", suffix=","):
        if self.children is not None:
            if self.depth >= 4:
                print("\033[91m[\033[0m", end="")
            else:
                print("[", end="")
            for i, child in enumerate(self.children):
                child.recursive_print(end="", suffix="" if i == len(self.children) - 1 else ",")
            suffix = "" if end == "\n" else suffix
            print("]" + suffix, end=end)
        else:
            if self.value > 9:
                print("\033[91m{}\033[0m{}".format(str(self.value), suffix), end="")
            else:
                print(str(self.value) + suffix, end="")


def main():
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

    final_pair = pairs[0]
    for i in range(len(pairs) - 1):
        final_pair = final_pair.add(pairs[i + 1])
        final_pair.reduce()

    print("PART ONE:", final_pair.magnitude())


if __name__ == "__main__":
    main()

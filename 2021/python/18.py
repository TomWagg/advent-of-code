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

    def reduce(self):
        if self.children is not None:
            if self.depth >= 4:
                self.explode()
            for child in self.children:
                child.reduce()

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

        self.parent.children[self.self_index()] = Pear(id=self.id, parent=self.parent,
                                                       children=None, depth=self.depth, value=0)

    def recursive_print(self, end="\n"):
        if self.children is not None:
            print("[", end="")
            for child in self.children:
                child.recursive_print(end="")
            print("]", end=end)
        else:
            print(self.value, end="")


def main():
    pairs = []
    with open("../inputs/18.txt", "r") as input:
        for line in input:
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
                                                 value=int(char), depth=current.depth))
                elif char == "]":
                    # end the current pair and move back to the parent
                    current = current.parent
            pairs.append(base_pair)

    for pair in pairs:
        pair.recursive_print()
        pair.reduce()
        pair.recursive_print()
        print()


if __name__ == "__main__":
    main()

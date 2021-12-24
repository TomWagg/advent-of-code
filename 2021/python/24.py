def ALU(operations, variables={"w": 0, "x": 0, "y": 0, "z": 0}, input_queue=[]):
    """ ALU for testing purposes """
    for op in operations:
        operation_type = op[0]
        if operation_type == "inp":
            variables[op[1]] = input_queue.pop()
        else:
            value = variables[op[2]] if op[2] in variables.keys() else int(op[2])
            if operation_type == "add":
                variables[op[1]] += value
            elif operation_type == "mul":
                variables[op[1]] *= value
            elif operation_type == "div":
                variables[op[1]] = variables[op[1]] // value
            elif operation_type == "mod":
                variables[op[1]] = variables[op[1]] % value
            elif operation_type == "eql":
                variables[op[1]] = int(variables[op[1]] == value)
    return variables


def reduced_function(z_prev, w, constants):
    """ The function that acts on each w input to produce the new z value """
    if w == (z_prev % 26 + constants[1]):
        return z_prev // constants[0]
    else:
        return 26 * (z_prev // constants[0]) + w + constants[2]


def reduced_ALU(model_number, constants):
    """ Function that does the same thing as the ALU for the given input, but faster """
    z = 0
    for i in range(len(model_number)):
        z = reduced_function(z_prev=z, w=model_number[i], constants=constants[i])
    return z


def find_model_number(constants, z_prev=0, model_number=()):
    """ Recursively add to the model number until you find one that works and return it """
    # once there are no constants left
    if constants == []:
        # return the resulting model number if it is a solution, otherwise None
        return model_number if z_prev == 0 else None

    # separate the constants for this step and future steps
    this_step, next_steps = constants[0], constants[1:]

    # first make an early exit condition
    # if the previous z is divided by 26 instead of 1 then it limits the possible values
    if this_step[0] == 26:
        # in this case, the *only* allowable w is the following
        w = (z_prev % 26) + this_step[1]

        # if this w is out of the range then return nothing
        if w <= 0 or w >= 10:
            return None

        # otherwise return the new values
        return find_model_number(constants=next_steps, z_prev=z_prev // this_step[0],
                                 model_number=model_number + (w,))

    # check every possible model number
    for w in reversed(range(1, 10)):
        guessed_number = find_model_number(constants=next_steps,
                                           z_prev=reduced_function(z_prev, w, this_step),
                                           model_number=model_number+(w,))
        if guessed_number is not None:
            return guessed_number


def main():
    operations = []
    with open("../inputs/24.txt", "r") as input:
        for line in input:
            line = line.strip()
            operations.append(tuple(line.split()))

    # find the three numbers that change in the instructions
    first = [int(const[-1]) for const in operations[4::18]]
    second = [int(const[-1]) for const in operations[5::18]]
    third = [int(const[-1]) for const in operations[15::18]]

    # store them in constants
    constants = [[first[i], second[i], third[i]] for i in range(len(first))]

    # find the largest model number
    print("PART ONE:", "".join(list(map(str, find_model_number(constants)))))


if __name__ == "__main__":
    main()

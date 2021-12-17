def brute_force(x_min, x_max, y_min, y_max):
    successes = 0
    for v0x in range(x_max + 1):
        for v0y in range(y_min, abs(y_min) + 1):
            x, y = 0, 0
            vx, vy = v0x, v0y
            while y > y_min:
                x += vx
                y += vy
                vx = vx if vx == 0 else vx - 1
                vy -= 1

                if x >= x_min and x <= x_max and y >= y_min and y <= y_max:
                    successes += 1
                    break
    return successes


def main():
    # feeling lazy today so we aren't reading an input file
    # input was - target area: x=85..145, y=-163..-108
    x_min, x_max = 85, 145
    y_min, y_max = -163, -108

    # symmetry my dudes
    print("PART ONE:", sum(range(-y_min)))

    # brute force because I'm lazy
    print("PART TWO:", brute_force(x_min, x_max, y_min, y_max))


if __name__ == "__main__":
    main()

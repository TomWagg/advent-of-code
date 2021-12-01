with open("inputs/1.txt") as input:
    depths = list(map(int, input.readlines()))

larger = 0

for i in range(1, len(depths)):
    larger += int(depths[i] - depths[i - 1] > 0)

print(larger)
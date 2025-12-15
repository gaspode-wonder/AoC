def read_points(filename):
    points = []
    with open(filename) as f:
        for line in f:
            if line.strip():
                x, y = map(int, line.replace(',', ' ').split())
                points.append((x, y))
    return points

def solve_day9(filename):
    points = read_points(filename)
    n = len(points)
    max_area = 0

    # Check all pairs of red tiles
    for i in range(n):
        for j in range(i+1, n):
            x1, y1 = points[i]
            x2, y2 = points[j]
            area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
            if area > max_area:
                max_area = area

    return max_area

if __name__ == "__main__":
    answer = solve_day9("input/day09.txt")
    print("Day 9 Part One Answer:", answer)


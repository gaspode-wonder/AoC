import heapq

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.size = [1] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.size[ra] < self.size[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.size[ra] += self.size[rb]
        return True

def dist2(p, q):
    dx, dy, dz = p[0]-q[0], p[1]-q[1], p[2]-q[2]
    return dx*dx + dy*dy + dz*dz

def read_points(filename):
    points = []
    with open(filename) as f:
        for line in f:
            if line.strip():
                x,y,z = map(int, line.replace(',', ' ').split())
                points.append((x,y,z))
    return points

def solve_day8(filename):
    points = read_points(filename)
    n = len(points)
    uf = UnionFind(n)

    # Build all pairs into a min-heap
    heap = []
    for i in range(n):
        for j in range(i+1, n):
            d2 = dist2(points[i], points[j])
            heapq.heappush(heap, (d2, i, j))

    part1_answer = None
    part2_answer = None
    pairs_considered = 0

    while heap:
        d2, i, j = heapq.heappop(heap)
        pairs_considered += 1
        uf.union(i, j)

        # Part One: after 1000 pairs considered
        if pairs_considered == 1000 and part1_answer is None:
            seen = {}
            sizes = []
            for idx in range(n):
                root = uf.find(idx)
                if root not in seen:
                    seen[root] = True
                    sizes.append(uf.size[root])
            sizes.sort(reverse=True)
            while len(sizes) < 3:
                sizes.append(1)
            part1_answer = sizes[0] * sizes[1] * sizes[2]

        # Part Two: when all connected
        root0 = uf.find(0)
        if uf.size[root0] == n and part2_answer is None:
            part2_answer = points[i][0] * points[j][0]
            break

    return part1_answer, part2_answer

if __name__ == "__main__":
    part1, part2 = solve_day8("input/day08.txt")
    print("Day 8 Part One Answer:", part1)
    print("Day 8 Part Two Answer:", part2)

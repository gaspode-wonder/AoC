# day07_part2.py
from collections import deque

def load_input(filename="input/day07.txt"):
    with open(filename) as f:
        return [line.rstrip("\n") for line in f if line.strip()]

def find_start(grid):
    for r, row in enumerate(grid):
        c = row.find('S')
        if c != -1:
            return r, c
    raise ValueError("No S found")

def count_timelines(grid):
    h = len(grid)
    w = max(len(row) for row in grid)
    grid = [row.ljust(w, '.') for row in grid]

    sr, sc = find_start(grid)

    # ways[r][c] = number of timelines currently at (r, c)
    ways = {}
    q = deque()
    ways[(sr, sc)] = 1
    q.append((sr, sc))

    total_timelines = 0

    while q:
        r, c = q.popleft()
        count = ways[(r, c)]

        nr = r + 1
        if nr >= h:
            # Exiting manifold: this branch contributes its count
            total_timelines += count
            continue

        cell = grid[nr][c]
        if cell == '^':
            # Branch left and right at same row
            if c - 1 >= 0:
                nxt = (nr, c - 1)
                if nxt not in ways:
                    ways[nxt] = 0
                before = ways[nxt]
                ways[nxt] += count
                if before == 0:
                    q.append(nxt)
            if c + 1 < w:
                nxt = (nr, c + 1)
                if nxt not in ways:
                    ways[nxt] = 0
                before = ways[nxt]
                ways[nxt] += count
                if before == 0:
                    q.append(nxt)
        else:
            # Pass-through downward
            nxt = (nr, c)
            if nxt not in ways:
                ways[nxt] = 0
            before = ways[nxt]
            ways[nxt] += count
            if before == 0:
                q.append(nxt)

    return total_timelines

def main():
    lines = load_input("input/day07.txt")  # swap to test file if needed
    result = count_timelines(lines)
    print(f"Day 7 Part Two Answer: {result}")

if __name__ == "__main__":
    main()

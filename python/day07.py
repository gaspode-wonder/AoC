# day07.py
from collections import deque

def load_input(filename="input/day07.txt"):
    with open(filename) as f:
        return [line.rstrip("\n") for line in f if line.strip()]

def count_splits(grid):
    h, w = len(grid), len(grid[0])
    # find S
    for r, row in enumerate(grid):
        c = row.find('S')
        if c != -1:
            s_row, s_col = r, c
            break
    else:
        raise ValueError("No S found")

    splits = 0
    q = deque([(s_row, s_col)])
    visited = set([(s_row, s_col)])   # track visited positions

    while q:
        r, c = q.popleft()
        nr = r + 1
        if nr >= h:
            continue
        cell = grid[nr][c]
        if cell == '.':
            if (nr, c) not in visited:
                visited.add((nr, c))
                q.append((nr, c))
        elif cell == '^':
            splits += 1
            # spawn left
            if c - 1 >= 0 and (nr, c - 1) not in visited:
                visited.add((nr, c - 1))
                q.append((nr, c - 1))
            # spawn right
            if c + 1 < w and (nr, c + 1) not in visited:
                visited.add((nr, c + 1))
                q.append((nr, c + 1))
        else:
            if (nr, c) not in visited:
                visited.add((nr, c))
                q.append((nr, c))
    return splits

def main():
    lines = load_input("input/day07.txt")   # swap to testday07.txt if needed
    width = max(len(row) for row in lines)
    grid = [row.ljust(width, '.') for row in lines]

    splits = count_splits(grid)
    print(f"Day 7 Answer: {splits}")

if __name__ == "__main__":
    main()

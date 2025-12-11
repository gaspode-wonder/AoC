#!/usr/bin/env python3

INPUT_FILE = "aocdata.txt"

DIRS = [(-1,-1), (0,-1), (1,-1),
        (-1, 0),          (1, 0),
        (-1, 1), (0, 1),  (1, 1)]

def read_grid(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = [line.rstrip('\n') for line in f if line.strip() != '']
    width = len(lines[0])
    for i, line in enumerate(lines):
        if len(line) != width:
            raise ValueError(f"Non-rectangular grid at line {i+1}: expected {width}, got {len(line)}")
    return lines

def count_neighbors(grid, x, y):
    h, w = len(grid), len(grid[0])
    cnt = 0
    for dx, dy in DIRS:
        nx, ny = x + dx, y + dy
        if 0 <= nx < w and 0 <= ny < h and grid[ny][nx] == '@':
            cnt += 1
    return cnt

def compute_accessible(grid):
    h, w = len(grid), len(grid[0])
    accessible = []
    for y in range(h):
        for x in range(w):
            if grid[y][x] == '@':
                n = count_neighbors(grid, x, y)
                if n < 4:
                    accessible.append((x, y, n))
    return accessible

def main():
    grid = read_grid(INPUT_FILE)
    accessible = compute_accessible(grid)

    total_rolls = sum(row.count('@') for row in grid)
    accessible_count = len(accessible)

    print(f"Total rolls: {total_rolls}")
    print(f"Accessible rolls (<4 adjacent '@'): {accessible_count}")
    print(f"\n>>> FINAL RESULT: {accessible_count} rolls can be accessed <<<")

if __name__ == "__main__":
    main()

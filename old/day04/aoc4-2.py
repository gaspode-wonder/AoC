#!/usr/bin/env python3

INPUT_FILE = "aocdata.txt"

DIRS = [(-1,-1), (0,-1), (1,-1),
        (-1, 0),          (1, 0),
        (-1, 1), (0, 1),  (1, 1)]

def read_grid(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = [line.rstrip('\n') for line in f if line.strip() != '']
    return [list(line) for line in lines]

def count_neighbors(grid, x, y):
    h, w = len(grid), len(grid[0])
    cnt = 0
    for dx, dy in DIRS:
        nx, ny = x + dx, y + dy
        if 0 <= nx < w and 0 <= ny < h and grid[ny][nx] == '@':
            cnt += 1
    return cnt

def remove_accessible(grid):
    h, w = len(grid), len(grid[0])
    to_remove = []
    for y in range(h):
        for x in range(w):
            if grid[y][x] == '@':
                if count_neighbors(grid, x, y) < 4:
                    to_remove.append((x, y))
    for x, y in to_remove:
        grid[y][x] = '.'
    return len(to_remove)

def main():
    grid = read_grid(INPUT_FILE)
    total_removed = 0
    while True:
        removed = remove_accessible(grid)
        if removed == 0:
            break
        total_removed += removed
    print(f"Total rolls removed: {total_removed}")

if __name__ == "__main__":
    main()

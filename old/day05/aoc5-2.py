#!/usr/bin/env python3

INPUT_FILE = "aocdata.txt"

def read_ranges(path):
    ranges = []
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line == "":
                break  # stop at blank line
            start, end = map(int, line.split('-'))
            ranges.append((start, end))
    return ranges

def merge_ranges(ranges):
    ranges.sort()
    merged = []
    for start, end in ranges:
        if not merged or start > merged[-1][1] + 1:
            merged.append([start, end])
        else:
            merged[-1][1] = max(merged[-1][1], end)
    return merged

def main():
    ranges = read_ranges(INPUT_FILE)
    merged = merge_ranges(ranges)
    total_fresh = sum(end - start + 1 for start, end in merged)
    print(f"Total fresh IDs: {total_fresh}")

if __name__ == "__main__":
    main()

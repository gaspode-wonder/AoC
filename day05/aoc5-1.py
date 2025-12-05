#!/usr/bin/env python3

INPUT_FILE = "aocdata.txt"

def read_database(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip() != "" or line == "\n"]
    # Split ranges and IDs at the blank line
    if "" in lines:
        split_index = lines.index("")
        ranges = lines[:split_index]
        ids = lines[split_index+1:]
    else:
        raise ValueError("No blank line separating ranges and IDs")
    return ranges, ids

def parse_ranges(range_lines):
    ranges = []
    for line in range_lines:
        start, end = map(int, line.split('-'))
        ranges.append((start, end))
    return ranges

def parse_ids(id_lines):
    return [int(x) for x in id_lines]

def is_fresh(id_val, ranges):
    for start, end in ranges:
        if start <= id_val <= end:
            return True
    return False

def main():
    ranges_raw, ids_raw = read_database(INPUT_FILE)
    ranges = parse_ranges(ranges_raw)
    ids = parse_ids(ids_raw)

    fresh_ids = [id_val for id_val in ids if is_fresh(id_val, ranges)]
    print(f"Total available IDs: {len(ids)}")
    print(f"Fresh IDs: {len(fresh_ids)}")
#    print(f"List of fresh IDs: {fresh_ids}")

if __name__ == "__main__":
    main()

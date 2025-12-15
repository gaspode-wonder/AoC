#!/usr/bin/env python3
import sys

# --- Shape handling ---
def rotations_and_flips(shape):
    variants = set()
    for flip in [1, -1]:
        for rot in range(4):
            coords = [(x, y*flip) for (x,y) in shape]
            for _ in range(rot):
                coords = [(-y, x) for (x,y) in coords]
            # normalize to origin
            minx = min(x for x,y in coords)
            miny = min(y for x,y in coords)
            norm = tuple(sorted((x-minx, y-miny) for x,y in coords))
            variants.add(norm)
    # return unique variants as lists
    return [list(v) for v in variants]

def parse_shapes(lines):
    shapes = {}
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1; continue
        if ":" in line:
            left = line.split(":")[0]
            if left.isdigit():
                idx = int(left)
                grid = []
                i += 1
                while i < len(lines) and lines[i].strip() and ":" not in lines[i]:
                    grid.append(lines[i].rstrip())
                    i += 1
                coords = [(x,y) for y,row in enumerate(grid) for x,ch in enumerate(row) if ch=="#"]
                shapes[idx] = rotations_and_flips(coords)
                continue
        i += 1
    return shapes

def parse_regions(lines):
    regions = []
    for line in lines:
        line=line.strip()
        if "x" in line and ":" in line:
            size, rest = line.split(":")
            w,h = map(int,size.split("x"))
            counts = list(map(int,rest.strip().split()))
            regions.append((w,h,counts))
    return regions

# --- Exact cover matrix with primary (presents) and secondary (cells) columns ---
def build_matrix(w,h,counts,shapes):
    # Primary columns: each present instance (must be covered exactly once)
    prim_cols = []
    for idx,c in enumerate(counts):
        for k in range(c):
            prim_cols.append(("P", idx, k))
    # Secondary columns: each cell (optional; when covered, prevent reuse)
    sec_cols = [("C", x, y) for y in range(h) for x in range(w)]

    colnames = prim_cols + sec_cols
    col_index = {c:i for i,c in enumerate(colnames)}
    nprim = len(prim_cols)

    rows = []
    for idx,c in enumerate(counts):
        for k in range(c):
            for variant in shapes[idx]:
                maxx = max(x for x,y in variant)
                maxy = max(y for x,y in variant)
                # +1 to allow placement touching right/bottom edge
                for oy in range(h - maxy + 1):
                    for ox in range(w - maxx + 1):
                        coords = [(ox+x, oy+y) for x,y in variant]
                        # inside bounds (redundant with bounds above but safe)
                        if all(0 <= x < w and 0 <= y < h for x,y in coords):
                            row = [col_index[("P", idx, k)]]
                            row += [col_index[("C", x, y)] for (x,y) in coords]
                            rows.append(row)
    return nprim, len(colnames), rows

# --- Algorithm X with proper secondary constraint filtering ---
def algorithm_x(nprim, ncols, rows):
    col_rows = [[] for _ in range(ncols)]
    for r, cols in enumerate(rows):
        for c in cols:
            col_rows[c].append(r)

    used_rows = set()
    covered_cols = set()

    def select_column():
        # choose uncovered primary column with fewest candidate rows
        candidates = [i for i in range(nprim) if i not in covered_cols]
        if not candidates:
            return None
        return min(candidates, key=lambda i: len(col_rows[i]))

    def search():
        col = select_column()
        if col is None:
            return True  # all primary columns covered
        options = [r for r in col_rows[col]
                   if r not in used_rows and all(cc not in covered_cols for cc in rows[r])]
        if not options:
            return False
        for r in options:
            used_rows.add(r)
            newly = []
            for cc in rows[r]:
                if cc not in covered_cols:
                    covered_cols.add(cc)
                    newly.append(cc)
            if search():
                return True
            for cc in newly:
                covered_cols.remove(cc)
            used_rows.remove(r)
        return False

    return search()


def can_fit_region(w,h,counts,shapes):
    # Early capacity check: presents must not exceed region area
    total_area = sum(len(shapes[idx][0]) * c for idx, c in enumerate(counts) if c > 0)
    if total_area > w*h:
        return False
    nprim, ncols, rows = build_matrix(w,h,counts,shapes)
    return algorithm_x(nprim, ncols, rows)

def main():
    if len(sys.argv) != 2:
        print("Usage: day12.py input.txt")
        sys.exit(1)
    with open(sys.argv[1]) as f:
        lines = f.readlines()
    shapes = parse_shapes(lines)
    regions = parse_regions(lines)

    fit = 0
    for (w,h,counts) in regions:
        if can_fit_region(w,h,counts,shapes):
            fit += 1
    print(f"{fit} regions can fit all presents")

if __name__ == "__main__":
    main()

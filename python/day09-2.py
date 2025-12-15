from math import log2

def read_points(filename):
    pts = []
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            x, y = map(int, line.replace(',', ' ').split())
            pts.append((x, y))
    return pts

def build_polygon_edges(red):
    # Connect consecutive points, wrapping to first, axis-aligned segments
    edges = []
    n = len(red)
    for i in range(n):
        x1, y1 = red[i]
        x2, y2 = red[(i+1) % n]
        edges.append((x1, y1, x2, y2))
    return edges

def scanline_fill_intervals(edges):
    # For each integer y, compute interior x-intervals via scanline polygon fill
    # Assumes polygon edges axis-aligned; ray casting across vertical edges
    ys = set()
    for _, y1, _, y2 in edges:
        ys.add(y1); ys.add(y2)
    ymin = min(ys)
    ymax = max(ys)

    intervals = {}  # y -> sorted list of (L, R) inclusive
    for y in range(ymin, ymax+1):
        xs = []
        for x1, y1, x2, y2 in edges:
            # Consider edges crossing scanline y; vertical edges contribute intersections
            if x1 == x2:
                # vertical edge spans between y1..y2 inclusive
                lo, hi = sorted((y1, y2))
                # Use half-open on top to avoid double counting; include y in [lo, hi)
                if lo <= y < hi:
                    xs.append(x1)
            else:
                # horizontal edges do not contribute crossings for even-odd fill
                # (standard rule: skip horizontal in crossings to avoid double hits)
                continue
        if not xs:
            continue
        xs.sort()
        # Pair crossings into interior segments
        segs = []
        for i in range(0, len(xs), 2):
            if i+1 >= len(xs):
                break
            L = xs[i]
            R = xs[i+1]
            # Convert to inclusive tiles; interior includes all integer x from L..R
            # Because crossings are at grid lines, ensure inclusivity:
            segs.append((L, R))  # inclusive interval [L, R]
        # Merge adjacent/overlapping intervals just in case
        if segs:
            merged = []
            curL, curR = segs[0]
            for L, R in segs[1:]:
                if L <= curR + 1:
                    curR = max(curR, R)
                else:
                    merged.append((curL, curR))
                    curL, curR = L, R
            merged.append((curL, curR))
            intervals[y] = merged
    return intervals

def build_row_index(intervals):
    rows = sorted(intervals.keys())
    row_to_idx = {y: i for i, y in enumerate(rows)}
    return rows, row_to_idx

def precompute_row_max_width(rows, intervals):
    widths = []
    for y in rows:
        wmax = 0
        for L, R in intervals[y]:
            wmax = max(wmax, R - L + 1)
        widths.append(wmax)
    return widths

def build_sparse_table(arr):
    # RMQ (min) sparse table
    n = len(arr)
    K = int(log2(n)) + 1 if n > 0 else 1
    st = [[0]*n for _ in range(K)]
    st[0] = arr[:]
    j = 1
    while (1 << j) <= n:
        i = 0
        while i + (1 << j) <= n:
            st[j][i] = min(st[j-1][i], st[j-1][i + (1 << (j-1))])
            i += 1
        j += 1
    return st

def rmq_min(st, l, r):
    if l > r: l, r = r, l
    length = r - l + 1
    k = int(log2(length))
    return min(st[k][l], st[k][r - (1 << k) + 1])

def interval_covers(intervals_y, xmin, xmax):
    # Binary search over sorted non-overlapping intervals to find one covering [xmin..xmax]
    if not intervals_y:
        return False
    lo, hi = 0, len(intervals_y)-1
    # Find rightmost interval with L <= xmin
    idx = -1
    while lo <= hi:
        mid = (lo + hi) // 2
        L, R = intervals_y[mid]
        if L <= xmin:
            idx = mid
            lo = mid + 1
        else:
            hi = mid - 1
    if idx == -1:
        return False
    L, R = intervals_y[idx]
    return L <= xmin and R >= xmax

def solve_day9_part2_optimized(filename):
    red = read_points(filename)
    n = len(red)
    edges = build_polygon_edges(red)
    intervals = scanline_fill_intervals(edges)

    # Prepare rows and RMQ over max widths
    rows, row_to_idx = build_row_index(intervals)
    if not rows:
        return 0, None  # no filled rows; no rectangle fits

    widths = precompute_row_max_width(rows, intervals)
    st = build_sparse_table(widths)

    max_area = 0
    best_pair = None

    # Iterate all pairs of red corners
    for i in range(n):
        x1, y1 = red[i]
        for j in range(i+1, n):
            x2, y2 = red[j]
            xmin, xmax = (x1, x2) if x1 <= x2 else (x2, x1)
            ymin, ymax = (y1, y2) if y1 <= y2 else (y2, y1)
            # If y-range contains rows not in intervals, quick reject
            # Map y to indices; if any y in range missing, we still check rows present; to be safe, require coverage for all integer y
            # Prune by RMQ on per-row max widths (width must fit every row in range)
            if ymin not in row_to_idx or ymax not in row_to_idx:
                # If endpoints rows not filled, rectangle cannot be fully inside
                continue
            li = row_to_idx[ymin]
            ri = row_to_idx[ymax]
            # Ensure all intermediate rows exist
            # Fast check: contiguous indices correspond to contiguous y’s only if rows are dense.
            # If rows are not dense (gaps), reject if there is any missing y between ymin..ymax.
            if (rows[li] != ymin) or (rows[ri] != ymax) or (ri - li != (ymax - ymin)):
                # There are missing filled rows in between; rectangle cannot be entirely inside
                continue

            width = xmax - xmin + 1
            min_w = rmq_min(st, li, ri)
            if width > min_w:
                continue  # cannot fit across entire y-range

            # Verify coverage per row with interval check (height cost)
            valid = True
            for idx in range(li, ri+1):
                y = rows[idx]
                if not interval_covers(intervals[y], xmin, xmax):
                    valid = False
                    break
            if not valid:
                continue

            area = width * (ymax - ymin + 1)
            if area > max_area:
                max_area = area
                best_pair = ((x1, y1), (x2, y2))

    return max_area, best_pair

if __name__ == "__main__":
    area, pair = solve_day9_part2_optimized("input/day09.txt")
    print("Day 9 Part Two Answer:", area)
    print("Best rectangle corners:", pair)

from collections import deque
import re

def parse_line(line):
    # Extract diagram, buttons
    diag = re.search(r'\[([.#]+)\]', line).group(1)
    target = 0
    n = len(diag)
    for i, ch in enumerate(diag):
        if ch == '#':
            target |= 1 << i
    buttons = []
    for group in re.findall(r'\(([^)]*)\)', line):
        group = group.strip()
        if not group:  # empty button toggles nothing
            buttons.append(0)
            continue
        nums = [int(x) for x in re.split(r'[,\s]+', group) if x != '']
        mask = 0
        for k in nums:
            if 0 <= k < n:
                mask |= 1 << k
        buttons.append(mask)
    return n, target, buttons

def bidir_bfs(n, target, buttons):
    start = 0
    if start == target:
        return 0
    # Frontier maps state -> distance from respective side
    front_a = {start: 0}
    front_b = {target: 0}
    qa = deque([start])
    qb = deque([target])
    visited_a = set([start])
    visited_b = set([target])

    steps = 0
    # Expand the smaller frontier each time
    while qa and qb:
        if len(qa) <= len(qb):
            size = len(qa)
            for _ in range(size):
                state = qa.popleft()
                da = front_a[state]
                for mask in buttons:
                    nxt = state ^ mask
                    if nxt in front_b:
                        return da + 1 + front_b[nxt]
                    if nxt not in visited_a:
                        visited_a.add(nxt)
                        front_a[nxt] = da + 1
                        qa.append(nxt)
        else:
            size = len(qb)
            for _ in range(size):
                state = qb.popleft()
                db = front_b[state]
                for mask in buttons:
                    nxt = state ^ mask
                    if nxt in front_a:
                        return db + 1 + front_a[nxt]
                    if nxt not in visited_b:
                        visited_b.add(nxt)
                        front_b[nxt] = db + 1
                        qb.append(nxt)
    # Unreachable (shouldn’t happen in valid inputs)
    return None

def solve_day10(lines):
    total = 0
    for line in lines:
        if not line.strip():
            continue
        n, target, buttons = parse_line(line)
        presses = bidir_bfs(n, target, buttons)
        if presses is None:
            raise ValueError("Target unreachable for line: " + line)
        total += presses
    return total

if __name__ == "__main__":
    #sample = [
    #    "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}",
    #    "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}",
    #    "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}",
    #]
    # print("Sample total:", solve_day10(sample))  # Expected: 7
    # For your input file:
    with open("input/day10.txt") as f:
        lines = [line.rstrip("\n") for line in f]
    print("Day 10 Part One Answer:", solve_day10(lines))
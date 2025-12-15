#!/usr/bin/env python3
import sys
from collections import defaultdict

def parse(lines):
    g = defaultdict(list)
    for line in lines:
        line = line.strip()
        if not line:
            continue
        name, rhs = line.split(":", 1)
        name = name.strip()
        targets = [t.strip() for t in rhs.strip().split() if t.strip()]
        g[name] = targets
    return g

# ---------- Part 1 ----------
def count_paths(g, start="you", goal="out"):
    memo = {}
    onstack = set()
    def dfs(u):
        if u == goal:
            return 1
        if u in memo:
            return memo[u]
        if u in onstack:
            return 0
        onstack.add(u)
        total = 0
        for v in g.get(u, []):
            total += dfs(v)
        onstack.remove(u)
        memo[u] = total
        return total
    return dfs(start)

# ---------- Part 2 ----------
def count_paths_with_both(g, start="svr", goal="out", a="dac", b="fft"):
    memo = {}
    onstack = set()
    def dfs(u, va, vb):
        if u == goal:
            return 1 if va and vb else 0
        key = (u, va, vb)
        if key in memo:
            return memo[key]
        if key in onstack:
            return 0
        onstack.add(key)
        va2 = va or (u == a)
        vb2 = vb or (u == b)
        total = 0
        for v in g.get(u, []):
            total += dfs(v, va2, vb2)
        onstack.remove(key)
        memo[key] = total
        return total
    return dfs(start, False, False)

def main():
    if len(sys.argv) != 2:
        print("Usage: reactor.py input.txt")
        sys.exit(1)
    with open(sys.argv[1]) as f:
        lines = f.readlines()
    g = parse(lines)

    part1 = count_paths(g, "you", "out")
    print(f"Part 1: paths you->out = {part1}")

    total_paths = count_paths(g, "svr", "out")
    constrained = count_paths_with_both(g, "svr", "out", "dac", "fft")
    print(f"Part 2: total svr->out = {total_paths}")
    print(f"Part 2: paths visiting dac & fft = {constrained}")

if __name__ == "__main__":
    main()

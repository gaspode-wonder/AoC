#!/usr/bin/env python3
import re, sys
from collections import deque
import pulp   # install with: pip install pulp

# ---------- Part One ----------
def parse_line_part1(line):
    m = re.search(r'\[([.#]+)\]', line)
    diag = m.group(1)
    n = len(diag)
    target = sum(1<<i for i,ch in enumerate(diag) if ch=="#")
    buttons=[]
    for group in re.findall(r'\(([^)]*)\)', line):
        mask=0
        for tok in group.replace(","," ").split():
            mask |= 1<<int(tok)
        buttons.append(mask)
    return n,target,buttons

def bidir_bfs(n,target,buttons):
    start=0
    if start==target: return 0
    qa,qb=deque([start]),deque([target])
    da,db={start:0},{target:0}
    va,vb={start},{target}
    while qa and qb:
        if len(qa)<=len(qb):
            for _ in range(len(qa)):
                s=qa.popleft()
                for m in buttons:
                    t=s^m
                    if t in db: return da[s]+1+db[t]
                    if t not in va:
                        va.add(t); da[t]=da[s]+1; qa.append(t)
        else:
            for _ in range(len(qb)):
                s=qb.popleft()
                for m in buttons:
                    t=s^m
                    if t in da: return db[s]+1+da[t]
                    if t not in vb:
                        vb.add(t); db[t]=db[s]+1; qb.append(t)
    return None

def solve_part1(lines):
    return sum(bidir_bfs(*parse_line_part1(line)) for line in lines if line.strip())

# ---------- Part Two ----------
def parse_line_part2(line):
    btns=[]
    for group in re.findall(r'\(([^)]*)\)', line):
        idxs=[int(x) for x in group.replace(","," ").split() if x]
        btns.append(idxs)
    target=[int(x) for x in re.split(r'[,\s]+', re.search(r'\{([^}]*)\}', line).group(1)) if x]
    m=len(target)
    btns=[[k for k in b if 0<=k<m] for b in btns]
    return btns,target

def solve_machine_ilp(buttons,target):
    prob=pulp.LpProblem("Day10Part2", pulp.LpMinimize)
    x=[pulp.LpVariable(f"x{i}", lowBound=0, cat="Integer") for i in range(len(buttons))]
    prob += pulp.lpSum(x)
    m=len(target)
    for r in range(m):
        prob += pulp.lpSum(x[j] for j,b in enumerate(buttons) if r in b) == target[r]
    prob.solve(pulp.PULP_CBC_CMD(msg=False))
    return int(round(pulp.value(pulp.lpSum(x))))

def solve_part2(lines):
    total=0
    for line in lines:
        if not line.strip(): continue
        b,t=parse_line_part2(line)
        total+=solve_machine_ilp(b,t)
    return total

# ---------- Main ----------
if __name__=="__main__":
    if len(sys.argv)<4:
        print("Usage: day10.py --part 1|2 input.txt"); sys.exit(1)
    if sys.argv[1]!="--part": print("First arg must be --part"); sys.exit(1)
    part=int(sys.argv[2]); filename=sys.argv[3]
    with open(filename) as f: lines=[l.strip() for l in f]
    ans=solve_part1(lines) if part==1 else solve_part2(lines)
    print(f"Day 10 Part {part} Answer:",ans)

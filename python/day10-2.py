import re
from typing import List, Tuple
try:
    import pulp
except ImportError:
    raise SystemExit("Please install PuLP: pip install pulp")

def parse_line(line: str) -> Tuple[int, List[List[int]], List[int]]:
    # Extract buttons (parentheses) and target (curly braces)
    diag_match = re.search(r'\[([.#]+)\]', line)  # ignored in part two
    n = len(diag_match.group(1)) if diag_match else 0  # still useful to bound indices
    btns = []
    for group in re.findall(r'\(([^)]*)\)', line):
        group = group.strip()
        if group == "":
            btns.append([])  # button affecting no counters (useless but allowed)
        else:
            idxs = [int(x) for x in re.split(r'[,\s]+', group) if x != ""]
            btns.append(idxs)
    target_group = re.search(r'\{([^}]*)\}', line)
    if not target_group:
        raise ValueError("Missing target braces in line: " + line)
    target = [int(x) for x in re.split(r'[,\s]+', target_group.group(1).strip()) if x != ""]
    # Counters are 0..len(target)-1; filter out any button indices beyond that
    m = len(target)
    btns = [[k for k in b if 0 <= k < m] for b in btns]
    return m, btns, target

def solve_machine_ilp(m: int, buttons: List[List[int]], target: List[int]) -> int:
    # Build ILP: min sum x_b, s.t. for each counter r: sum_{b affects r} x_b = target[r]
    prob = pulp.LpProblem("aoc_day10_part2", pulp.LpMinimize)
    x_vars = [pulp.LpVariable(f"x_{i}", lowBound=0, cat="Integer") for i in range(len(buttons))]
    # Objective
    prob += pulp.lpSum(x_vars)
    # Constraints per counter
    for r in range(m):
        prob += pulp.lpSum(x_vars[j] for j, b in enumerate(buttons) if r in b) == target[r]
    # Solve
    status = prob.solve(pulp.PULP_CBC_CMD(msg=False))
    if status != pulp.LpStatusOptimal:
        raise ValueError("No optimal solution found; machine may be infeasible.")
    return int(round(pulp.value(pulp.lpSum(x_vars))))

def solve_day10_part2(lines: List[str]) -> int:
    total = 0
    for line in lines:
        if not line.strip():
            continue
        m, btns, tgt = parse_line(line)
        presses = solve_machine_ilp(m, btns, tgt)
        total += presses
    return total

if __name__ == "__main__":
    # sample = [
    #     "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}",
    #     "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}",
    #     "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}",
    # ]
    # print("Sample total (expected 33):", solve_day10_part2(sample))
    # To run on your input:
    with open("input/day10.txt") as f:
        lines = [line.rstrip("\n") for line in f]
    print("Day 10 Part Two Answer:", solve_day10_part2(lines))

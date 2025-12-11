import re, itertools, functools, operator

ops = {'+': operator.add, '*': operator.mul}

def parse_ops(line):
    return [tok for tok in re.sub(r"\s+", " ", line).strip().split(" ") if tok]

def parse_grid_tokens(lines):
    # Split each row into tokens (numbers), then transpose into columns
    rows = [r.split() for r in lines]
    width = max(len(r) for r in rows)
    for r in rows:
        if len(r) != width:
            raise ValueError("Ragged rows in token grid")
    cols = list(map(list, zip(*rows)))  # transpose
    return [[int(x) for x in col] for col in cols]

def parse_grid_constructed(lines):
    # Character-wise transpose; group contiguous digit-columns into numbers
    maxlen = max(len(r) for r in lines)
    padded = [r.ljust(maxlen) for r in lines]
    transposed = ["".join(row[c] for row in padded) for c in range(maxlen)]
    groups = [
        list(element)
        for key, element in itertools.groupby(
            transposed, lambda x: not re.match(r"^\s+$", x)
        )
        if key
    ]
    return [[int(x) for x in group] for group in groups]

def eval_and_print(label, operators, columns):
    total = 0
    print(f"\n--- {label} ---")
    for op, nums in zip(operators, columns):
        res = functools.reduce(ops[op], nums)
        print(f"{op} on {nums} -> {res}")
        total += res
    print(f"{label} Total = {total}")
    return total

def solve(filename="input/day06.txt"):
    with open(filename) as f:
        data = [line.rstrip("\n") for line in f if line.strip()]

    op_line = data[-1]
    body = data[:-1]
    operators = parse_ops(op_line)

    # L2R: simple arithmetic
    l2r_cols = parse_grid_tokens(body)
    total_l2r = eval_and_print("Left-to-Right", operators, l2r_cols)

    # R2L: constructed numbers
    r2l_cols = parse_grid_constructed(body)[::-1]
    total_r2l = eval_and_print("Right-to-Left", operators[::-1], r2l_cols)

    return total_l2r, total_r2l

if __name__ == "__main__":
    l2r, r2l = solve("input/day06.txt")
    print(f"\nDay 6 Answer (Left-to-Right): {l2r}")
    print(f"Day 6 Answer (Right-to-Left): {r2l}")

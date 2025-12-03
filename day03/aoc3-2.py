def largest_bank_number_twelve(line: str, k: int = 12) -> int:
    digits = [int(ch) for ch in line if ch.isdigit()]
    n = len(digits)
    if n < k:
        return -1

    removals = n - k
    stack = []

    for d in digits:
        while removals > 0 and stack and stack[-1] < d:
            stack.pop()
            removals -= 1
        stack.append(d)

    # Trim if still too long
    if len(stack) > k:
        stack = stack[:k]

    return int("".join(str(x) for x in stack))


def process_file_twelve(filename: str = "aocdata.txt"):
    total = 0
    with open(filename) as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            val = largest_bank_number_twelve(s, 12)
            print(f"Bank: {s} -> Largest possible 12-digit number: {val}")
            if val != -1:
                total += val
    print(f"Total sum of largest 12-digit numbers: {total}")


# Run with test data
process_file_twelve("aocdata.txt")

def largest_bank_number_two(line: str) -> int:
    digits = [int(ch) for ch in line if ch.isdigit()]
    n = len(digits)
    if n < 2:
        return -1

    # Suffix max: for each i, the largest digit strictly to its right
    sufmax = [-1] * n
    cur = -1
    for i in range(n - 1, -1, -1):
        sufmax[i] = cur
        if digits[i] > cur:
            cur = digits[i]

    best_val = -1
    for i in range(n - 1):  # i can be up to n-2
        right_max = sufmax[i]
        if right_max == -1:
            continue
        val = digits[i] * 10 + right_max
        if val > best_val:
            best_val = val

    return best_val


def process_file_two(filename: str):
    total = 0
    with open(filename) as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            val = largest_bank_number_two(s)
            print(f"Bank: {s} -> Largest possible 2-digit number: {val}")
            if val != -1:
                total += val
    print(f"Total sum of largest 2-digit numbers: {total}")


# Example usage
process_file_two("aocdata.txt")

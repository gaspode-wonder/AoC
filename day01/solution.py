def method_end_only(rotations, start=50, dial_size=100):
    """Count times dial ends at 0 after a rotation."""
    position = start
    zero_hits = 0

    for move in rotations:
        direction = move[0]
        distance = int(move[1:])

        if direction == 'L':
            position = (position - distance) % dial_size
        elif direction == 'R':
            position = (position + distance) % dial_size
        else:
            raise ValueError(f"Invalid rotation: {move}")

        if position == 0:
            zero_hits += 1

    return zero_hits


def method_clicks(rotations, start=50, dial_size=100):
    """Count times dial points at 0 during any click (method 0x434C49434B)."""
    position = start
    zero_hits = 0

    for move in rotations:
        direction = move[0]
        distance = int(move[1:])

        if direction == 'L':
            for _ in range(distance):
                position = (position - 1) % dial_size
                if position == 0:
                    zero_hits += 1
        elif direction == 'R':
            for _ in range(distance):
                position = (position + 1) % dial_size
                if position == 0:
                    zero_hits += 1
        else:
            raise ValueError(f"Invalid rotation: {move}")

    return zero_hits


# --- Main program ---
with open("aocdata.txt") as f:
    rotations = [line.strip() for line in f if line.strip()]

password_end_only = method_end_only(rotations)
password_clicks = method_clicks(rotations)

print("Password (end-only method):", password_end_only)
print("Password (method 0x434C49434B, count all clicks):", password_clicks)

from aocd import get_data

day_data = get_data(day=11, year=2025)
print(day_data)

with open('aocdata.txt', 'w') as f:
    f.write(day_data)
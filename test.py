from aocd import get_data

# For today's data (if AOC_SESSION is set)
# print(data)
# 

# For a specific day and year:
day_data = get_data(day=9, year=2025)
print(day_data)

with open('day09.txt', 'w') as f:
    f.write(day_data)
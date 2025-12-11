from aocd import get_data

# For today's data (if AOC_SESSION is set)
# print(data)
# 

# For a specific day and year:
day_data = get_data(day=1, year=2025)
print(day_data)

with open('aocdata.txt', 'w') as f:
    f.write(day_data)
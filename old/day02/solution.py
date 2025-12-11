from aocd import get_data


day_data = get_data(day=2, year=2025)
print(day_data)

with open('aocdata.csv', 'w') as f:
    f.write(day_data)

"""
data = []
with open("aocdata.csv", "r") as f:
    for line in f:"""
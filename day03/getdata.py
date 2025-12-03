day_data = get_data(day=3, year=2025)
print(day_data)

with open('aocdata.txt', 'w') as f:
    f.write(day_data)
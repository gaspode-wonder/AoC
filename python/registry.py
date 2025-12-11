PUZZLES = {}

def register(day):
    def decorator(func):
        PUZZLES[day] = func
        return func
    return decorator

def run(day: int):
    return PUZZLES[day]()

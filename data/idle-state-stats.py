import os
import sys
import numpy as np

implementations = ["Kmp", "Native"]
metrics = ["cpu", "memory"]
data = {impl: {m: [] for m in metrics} for impl in implementations}

for impl in implementations:
    filename = f"{impl}IdleState.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    with open(filename, "r") as f:
        lines = f.readlines()

    in_iteration = False
    start_time = None
    buffer = {m: [] for m in metrics}

    for line in lines:
        line = line.strip()
        if line == "--- NEW ITERATION ---":
            # Save previous iteration data
            if start_time is not None:
                for m in metrics:
                    data[impl][m].extend(buffer[m])
            # Reset for new iteration
            in_iteration = True
            start_time = None
            buffer = {m: [] for m in metrics}
            continue

        if not in_iteration or not line or line.startswith("---") or line.startswith("CPU"):
            continue

        try:
            cpu, _, _, memory, timestamp = map(float, [p.strip() for p in line.split("|")])
        except ValueError:
            continue

        if start_time is None:
            start_time = timestamp

        if timestamp - start_time < 2:
            continue  # Skip first 2 seconds

        buffer["cpu"].append(cpu)
        buffer["memory"].append(memory)

    if start_time is not None:
        for m in metrics:
            data[impl][m].extend(buffer[m])

print("\nIdle State CPU & Memory (excluding first 2 seconds of each iteration):")
print(f"{'Metric':<10} {'Impl':<8} {'Mean':>10} {'Std':>10}")
print("-" * 40)

for m in metrics:
    for impl in implementations:
        values = data[impl][m]
        if len(values) < 2:
            print(f"{m:<10} {impl:<8} Not enough data.")
            continue
        mean = np.mean(values)
        std = np.std(values, ddof=1)
        print(f"{m:<10} {impl:<8} {mean:10.2f} {std:10.2f}")

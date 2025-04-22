import os
import sys
import numpy as np
from scipy.stats import ttest_ind

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
metrics = ["cpu", "fps", "dropped", "memory"]
data = {impl: {m: [] for m in metrics} for impl in implementations}

for impl in implementations:
    filename = f"{impl}{benchmark}.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    with open(filename, "r") as f:
        lines = f.readlines()

    in_iteration = False
    timestamps = []
    buffer = {m: [] for m in metrics}
    start_time = None

    for line in lines:
        line = line.strip()
        if line == "--- NEW ITERATION ---":
            # Save completed iteration
            if timestamps:
                for m in metrics:
                    data[impl][m].extend(buffer[m])
            # Reset for next
            in_iteration = True
            timestamps = []
            buffer = {m: [] for m in metrics}
            start_time = None
            continue

        if not in_iteration or not line or line.startswith("---") or line.startswith("CPU"):
            continue

        try:
            cpu, fps, dropped, memory, timestamp = map(float, [p.strip() for p in line.split("|")])
        except ValueError:
            continue

        if start_time is None:
            start_time = timestamp

        if timestamp - start_time < 10:
            continue  # skip warmup

        buffer["cpu"].append(cpu)
        buffer["fps"].append(fps)
        buffer["dropped"].append(dropped)
        buffer["memory"].append(memory)
        timestamps.append(timestamp)

    # Save final iteration if needed
    if timestamps:
        for m in metrics:
            data[impl][m].extend(buffer[m])

# Run t-tests and print results
print(f"\nT-Test Results for Benchmark: {benchmark}")
print(f"{'Metric':<10} {'KMP Mean':>10} {'KMP Std':>10} {'Swift Mean':>12} {'Swift Std':>12} {'t-stat':>10} {'p-value':>10} {'Significant':>12}")
print("-" * 85)

for m in metrics:
    kmp_vals = data["Kmp"][m]
    native_vals = data["Native"][m]

    if len(kmp_vals) < 2 or len(native_vals) < 2:
        print(f"{m:<10} Not enough data.")
        continue

    mean_k = np.mean(kmp_vals)
    std_k = np.std(kmp_vals, ddof=1)
    mean_n = np.mean(native_vals)
    std_n = np.std(native_vals, ddof=1)

    t_stat, p_value = ttest_ind(kmp_vals, native_vals, equal_var=False)
    significant = "YES" if p_value < 0.05 else "NO"

    print(f"{m:<10} {mean_k:10.2f} {std_k:10.2f} {mean_n:12.2f} {std_n:12.2f} {t_stat:10.2f} {p_value:10.20f} {significant:>12}")

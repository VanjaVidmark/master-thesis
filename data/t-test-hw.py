import os
import sys
import numpy as np
from scipy.stats import ttest_ind

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
metrics = ["cpu", "memory", "exec_time"]
data = {impl: {m: [] for m in metrics} for impl in implementations}

for impl in implementations:
    filename = f"{impl}{benchmark}.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    with open(filename, "r") as f:
        lines = f.readlines()

    timestamps = []
    cpu_values = []
    memory_values = []
    exec_times = []

    for line in lines:
        line = line.strip()

        if line.startswith("Execution time:"):
            try:
                exec_time = float(line.replace("Execution time:", "").strip())
                exec_times.append(exec_time)
            except ValueError:
                continue
            continue

        if not line or line.startswith("---") or line.startswith("CPU"):
            continue

        try:
            cpu, memory, timestamp = map(float, line.split("|"))
            cpu_values.append(cpu)
            memory_values.append(memory)
            timestamps.append(timestamp)
        except ValueError:
            continue

    data[impl]["cpu"].extend(cpu_values)
    data[impl]["memory"].extend(memory_values)
    data[impl]["exec_time"].extend(exec_times)

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

    try:
        t_stat, p_value = ttest_ind(kmp_vals, native_vals, equal_var=False)
    except Exception as e:
        t_stat, p_value = float("nan"), float("nan")

    significant = "YES" if p_value < 0.05 else "NO"

    print(f"{m:<10} {mean_k:10.2f} {std_k:10.2f} {mean_n:12.2f} {std_n:12.2f} {t_stat:10.2f} {p_value:10.20f} {significant:>12}")

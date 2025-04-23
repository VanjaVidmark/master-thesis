import os
import sys
import numpy as np
from scipy.stats import ttest_ind

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
metrics = ["cpu", "memory", "exec_time"]
data = {impl: {m: [] for m in metrics} for impl in implementations}

for impl in implementations:
    perf_filename = f"{impl}{benchmark}Performance.txt"
    time_filename = f"{impl}{benchmark}Time.txt"

    # Read performance data (CPU + Memory)
    if not os.path.isfile(perf_filename):
        raise FileNotFoundError(f"Could not find file: {perf_filename}")

    with open(perf_filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("---") or line.startswith("CPU"):
                continue
            try:
                cpu, memory, _ = map(float, line.split("|"))
                data[impl]["cpu"].append(cpu)
                data[impl]["memory"].append(memory)
            except ValueError:
                continue

    # Read time data
    if not os.path.isfile(time_filename):
        raise FileNotFoundError(f"Could not find file: {time_filename}")

    with open(time_filename, "r") as f:
        for line in f:
            line = line.strip()
            try:
                exec_time = float(line)
                data[impl]["exec_time"].append(exec_time)
            except ValueError:
                continue

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
    except Exception:
        t_stat, p_value = float("nan"), float("nan")

    significant = "YES" if p_value < 0.05 else "NO"

    print(f"{m:<10} {mean_k:10.2f} {std_k:10.2f} {mean_n:12.2f} {std_n:12.2f} {t_stat:10.2f} {p_value:10.20f} {significant:>12}")

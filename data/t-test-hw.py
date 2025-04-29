import os
import sys
import numpy as np
from scipy.stats import ttest_ind

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
metrics = ["cpu", "memory", "exec_time"]

# initialize nested dictionary for all data
data = {}
for impl in implementations:
    data[impl] = {}
    for m in metrics:
        data[impl][m] = []


for impl in implementations:
    perf_filename = f"{impl}{benchmark}Performance.txt"
    time_filename = f"{impl}{benchmark}Time.txt"

    # Handle CPU and memory data

    if not os.path.isfile(perf_filename):
        raise FileNotFoundError(f"Could not find file: {perf_filename}")

    with open(perf_filename, "r") as f:
        for line in f:
            line = line.strip()
            # Skip lines not containing data
            if not line or line.startswith("---") or line.startswith("CPU"):
                continue
            try:
                cpu, memory, _ = map(float, line.split("|"))
                data[impl]["cpu"].append(cpu)
                data[impl]["memory"].append(memory)
            except ValueError:
                continue

    # Handle time data

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

# T-TESTS

print(f"\nT-Test Results for Benchmark: {benchmark}")
print(f"{'Metric':<10} {'KMP Mean':>15} {'KMP Std':>15} {'Swift Mean':>15} {'Swift Std':>15} {'t-stat':>15} {'p-value':>15} {'Significant':>15}")
print("-" * 120)

for m in metrics:
    kmp_vals = data["Kmp"][m]
    native_vals = data["Native"][m]

    mean_kmp = np.mean(kmp_vals)
    std_kmp = np.std(kmp_vals, ddof=1)
    mean_native = np.mean(native_vals)
    std_native = np.std(native_vals, ddof=1)

    try:
        t_stat, p_value = ttest_ind(kmp_vals, native_vals, equal_var=False)
    except Exception:
        t_stat, p_value = float("nan"), float("nan")

    significant = "YES" if p_value < 0.05 else "NO"

    print(f"{m:<10} {mean_kmp:15.5f} {std_kmp:15.5f} {mean_native:15.5f} {std_native:15.5f} {t_stat:15.5f} {p_value:15.5f} {significant:>12}")

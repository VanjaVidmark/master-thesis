import os
import sys
import numpy as np
from scipy.stats import ttest_ind

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
metrics = ["cpu", "fps", "dropped", "memory"]

# initialize nested dictionary for all data
data = {}
for impl in implementations:
    data[impl] = {}
    for m in metrics:
        data[impl][m] = []

for impl in implementations:
    filename = f"{impl}{benchmark}.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    with open(filename, "r") as f:
        lines = f.readlines()

    start_time = None  # timestamp of first sample per run (to discard warmup)
    frame_drops_per_second = {}  

    for line in lines:
        line = line.strip()

        if line == "--- NEW BENCHMARK RUN ---":
            # When starting a new run, write all calculated fame drops per second to data
            if frame_drops_per_second:
                for second in sorted(frame_drops_per_second.keys()):
                    data[impl]["dropped"].append(frame_drops_per_second[second])
            # reset variables
            frame_drops_per_second = {}
            start_time = None
            continue

        if not line or line.startswith("---") or line.startswith("CPU"):
            continue

        try:
            cpu, fps, dropped, memory, timestamp = map(float, line.split("|"))
        except ValueError:
            continue

        # If first row of the benchmark run
        if start_time is None:
            start_time = timestamp

        if timestamp - start_time < 10:
            continue  # Skip warmup first 10 seconds

        # Adds number of frame drops during each second
        second = int(timestamp - start_time)
        if second not in frame_drops_per_second:
            frame_drops_per_second[second] = 0
        frame_drops_per_second[second] += dropped

        data[impl]["cpu"].append(cpu)
        data[impl]["fps"].append(fps)
        data[impl]["memory"].append(memory)

    # Finalize last benchmark run (in case it doesnt end at a whole second)
    if frame_drops_per_second:
        for second in sorted(frame_drops_per_second.keys()):
            data[impl]["dropped"].append(frame_drops_per_second[second])

# T-TESTS

print(f"\nT-Test Results for Benchmark: {benchmark}")
print(f"{'Metric':<10} {'KMP Mean':>15} {'KMP Std':>15} {'Swift Mean':>15} {'Swift Std':>15} {'t-stat':>15} {'p-value':>15} {'Significant':>15}")
print("-" * 120)

for m in metrics:
    kmp_vals = data["Kmp"][m]
    native_vals = data["Native"][m]

    if m == "dropped":
        print(len(kmp_vals))
        print(len(native_vals))

    mean_kmp = np.mean(kmp_vals)
    std_kmp = np.std(kmp_vals, ddof=1)
    mean_native = np.mean(native_vals)
    std_native = np.std(native_vals, ddof=1)

    try:
        t_stat, p_value = ttest_ind(kmp_vals, native_vals, equal_var=False)
    except Exception:
        t_stat, p_value = float("nan"), float("nan")

    significant = "YES" if p_value < 0.05 else "NO"

    print(f"{m:<10} {mean_kmp:15.5f} {std_kmp:15.5f} {mean_native:15.5f} {std_native:15.5f} {t_stat:15.5f} {p_value:15.5f} {significant:>15}")

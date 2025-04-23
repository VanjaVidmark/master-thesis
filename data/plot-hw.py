import matplotlib.pyplot as plt
import os
import sys
import numpy as np

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]

data = {}

for impl in implementations:
    perf_filename = f"{impl}{benchmark}Performance.txt"
    time_filename = f"{impl}{benchmark}Time.txt"

    if not os.path.isfile(perf_filename):
        raise FileNotFoundError(f"Could not find performance file: {perf_filename}")
    if not os.path.isfile(time_filename):
        raise FileNotFoundError(f"Could not find time file: {time_filename}")

    print(f"Using {impl}:")
    print(f"  Performance: {perf_filename}")
    print(f"  Time: {time_filename}")

    timestamps = []
    cpu_values = []
    memory_values = []
    exec_times = []

    # Read performance data
    with open(perf_filename, "r") as file:
        lines = file.readlines()
        for line in lines:
            line = line.strip()
            if not line or line.startswith("---") or line.startswith("CPU"):
                continue
            try:
                cpu, memory, timestamp = map(float, line.split("|"))
                cpu_values.append(cpu)
                memory_values.append(memory)
                timestamps.append(timestamp)
            except ValueError:
                print(f"Skipped line: {line}")
                continue

    # Normalize timestamps to start from 0
    if timestamps:
        base_time = timestamps[0]
        timestamps = [t - base_time for t in timestamps]

    # Read execution times
    with open(time_filename, "r") as file:
        for line in file:
            line = line.strip()
            try:
                exec_times.append(float(line))
            except ValueError:
                continue

    data[impl] = {
        "timestamp": timestamps,
        "cpu": cpu_values,
        "memory": memory_values,
        "exec_times": exec_times
    }

fig, axs = plt.subplots(3, 1, figsize=(12, 9), sharex=False)

metrics = [
    ("cpu", "CPU Usage (%)", axs[0]),
    ("memory", "Memory Usage (MB)", axs[1]),
]

for key, ylabel, ax in metrics:
    for impl in implementations:
        ax.plot(data[impl]["timestamp"], data[impl][key], label=impl.upper(), linewidth=1.5)
    ax.set_ylabel(ylabel)
    ax.legend()
    ax.grid(True)

for impl in implementations:
    axs[2].plot(range(len(data[impl]["exec_times"])), data[impl]["exec_times"], marker='o', label=impl.upper())

axs[2].set_ylabel("Execution Time (s)")
axs[2].set_xlabel("Run Index")
axs[2].legend()
axs[2].grid(True)

fig.suptitle(f"{benchmark} Benchmark", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

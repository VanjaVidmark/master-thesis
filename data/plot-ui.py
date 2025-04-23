import matplotlib.pyplot as plt
import os
import sys

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]

data = {}

for impl in implementations:
    filename = f"{impl}{benchmark}.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    print(f"Using {impl}: {filename}")

    timestamps = []
    cpu_values = []
    fps_values = []
    dropped_values = []

    with open(filename, "r") as file:
        lines = file.readlines()

    in_first_iteration = False
    for line in lines:
        line = line.strip()
        if line == "--- NEW ITERATION ---":
            if not in_first_iteration:
                in_first_iteration = True
                continue
            else:
                break  # stop after first iteration

        if not in_first_iteration or not line or line.startswith("---") or line.startswith("CPU"):
            continue

        parts = [p.strip() for p in line.split("|")]
        if len(parts) >= 5:
            try:
                cpu, fps, dropped, _, timestamp = map(float, parts)
                cpu_values.append(cpu)
                fps_values.append(fps)
                dropped_values.append(dropped)
                timestamps.append(timestamp)
            except ValueError:
                continue

    if timestamps:
        base_time = timestamps[0]
        timestamps = [t - base_time for t in timestamps]

    data[impl] = {
        "timestamp": timestamps,
        "cpu": cpu_values,
        "fps": fps_values,
        "dropped": dropped_values
    }

# Plot
import numpy as np

fig, axs = plt.subplots(2, 2, figsize=(12, 6), sharex=True)

metrics = [
    ("cpu", "CPU Usage (%)", axs[0][0]),
    ("fps", "FPS", axs[0][1]),
    ("dropped", "Frame Drops", axs[1][0])
]

for key, ylabel, ax in metrics:
    for impl in implementations:
        if data[impl]["timestamp"]:  # Only plot if there's data
            ax.plot(data[impl]["timestamp"], data[impl][key], label=impl.upper(), linewidth=1.5)
    ax.set_ylabel(ylabel)
    ax.legend()
    ax.grid(True)

for ax in axs[1]:
    ax.set_xlabel("Seconds since start")

fig.suptitle(f"{benchmark} Benchmark (First Iteration)", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()
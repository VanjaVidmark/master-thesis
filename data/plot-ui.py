import matplotlib.pyplot as plt
import os
import sys
import numpy as np

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
    ram_values = []

    with open(filename, "r") as file:
        lines = file.readlines()

    in_iteration = False
    for line in lines:
        line = line.strip()

        if line.startswith("--- NEW BENCHMARK RUN ---"):
            if not in_iteration:
                in_iteration = True
                continue
            else:
                break  # Stop after the first iteration

        if not in_iteration or not line or line.startswith("CPU") or line.startswith("---"):
            continue

        parts = [p.strip() for p in line.split("|")]
        if len(parts) == 5:
            try:
                cpu = float(parts[0])
                fps = float(parts[1])
                dropped = float(parts[2])
                ram = float(parts[3])
                timestamp = float(parts[4])

                cpu_values.append(cpu)
                fps_values.append(fps)
                dropped_values.append(dropped)
                ram_values.append(ram)
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
        "dropped": dropped_values,
        "ram": ram_values
    }

# Plotting
fig, axs = plt.subplots(2, 2, figsize=(12, 8), sharex=True)

metrics = [
    ("cpu", "CPU Usage (%)", axs[0][0]),
    ("fps", "FPS", axs[0][1]),
    ("dropped", "Frame Drops", axs[1][0]),
    ("ram", "RAM Usage (MB)", axs[1][1])
]

for key, ylabel, ax in metrics:
    for impl in implementations:
        if data[impl]["timestamp"]:
            ax.plot(data[impl]["timestamp"], data[impl][key], label=impl.upper(), linewidth=1.5)
    ax.set_ylabel(ylabel)
    ax.legend()
    ax.grid(True)

for ax in axs[1]:
    ax.set_xlabel("Seconds since start")

fig.suptitle(f"{benchmark} Benchmark (First Iteration)", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

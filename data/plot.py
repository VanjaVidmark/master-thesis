import matplotlib.pyplot as plt
import os
import glob
import sys
import numpy as np

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]

data = {}

for impl in implementations:
    filename = f"{impl}{benchmark}BenchmarkResults.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    print(f"Using {impl}: {filename}")

    timestamps = []
    cpu_values = []
    fps_values = []
    overrun_values = []
    memory_values = []

    with open(filename, "r") as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip()
        if not line or line.startswith("---") or line.startswith(f"{benchmark} Benchmark") or line.startswith("CPU"):
            continue
        try:
            cpu, fps, overrun, memory, timestamp = map(float, line.split("|"))
            cpu_values.append(cpu)
            fps_values.append(fps)
            overrun_values.append(overrun)
            memory_values.append(memory)
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
        "overrun": overrun_values,
        "memory": memory_values,
    }
    time_deltas = np.diff(timestamps)
    data[impl]["time_deltas"] = time_deltas

if len(time_deltas) > 0:
    print(f"\nTime delta stats for {impl}:")
    print(f"  Avg delta:  {np.mean(time_deltas):.4f} s")
    print(f"  Min delta:  {np.min(time_deltas):.4f} s")
    print(f"  Max delta:  {np.max(time_deltas):.4f} s")
    print(f"  Count:      {len(time_deltas)} samples")

fig, axs = plt.subplots(2, 2, figsize=(12, 6), sharex=True)

metrics = [
    ("cpu", "CPU Usage (%)", axs[0][0]),
    ("fps", "FPS", axs[0][1]),
    ("overrun", "Frame Overrun (ms)", axs[1][0]),
    ("memory", "Memory Usage (MB)", axs[1][1]),
]

for key, ylabel, ax in metrics:
    for impl in implementations:
        ax.plot(data[impl]["timestamp"], data[impl][key], label=impl.upper(), linewidth=1.5)
    ax.set_ylabel(ylabel)
    ax.legend()
    ax.grid(True)

for ax in axs[1]:
    ax.set_xlabel("Seconds since start")

fig.suptitle(f"{benchmark} Benchmark", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()


# New figure to plot time deltas
plt.figure(figsize=(10, 4))
for impl in implementations:
    plt.plot(data[impl]["timestamp"][1:], data[impl]["time_deltas"], label=impl.upper(), linewidth=1.2)

plt.title("Time Between Measurements")
plt.xlabel("Seconds since start")
plt.ylabel("Delta Time (s)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()


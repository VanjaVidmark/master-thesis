import matplotlib.pyplot as plt
import os
import sys
import numpy as np
import statistics

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
    memory_values = []
    exec_times = []

    with open(filename, "r") as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip()

        if line.startswith("Execution time:"):
            try:
                exec_time = float(line.replace("Execution time:", "").strip())
                exec_times.append(exec_time)
            except ValueError:
                pass
            continue

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

    if timestamps:
        base_time = timestamps[0]
        timestamps = [t - base_time for t in timestamps]

    data[impl] = {
        "timestamp": timestamps,
        "cpu": cpu_values,
        "memory": memory_values,
        "exec_times": exec_times
    }

# ⬇️ Plotting
fig, axs = plt.subplots(2, 1, figsize=(12, 6), sharex=True)

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

axs[1].set_xlabel("Seconds since start")
fig.suptitle(f"{benchmark} Benchmark", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

# 📊 Stats printing
print("\n Resource Usage Summary:\n")
for impl in implementations:
    cpu_vals = data[impl]["cpu"]
    mem_vals = data[impl]["memory"]
    exec_vals = data[impl]["exec_times"]
    if cpu_vals and mem_vals:
        print(f"{impl.upper()}:")
        print(f"  Avg CPU:     {statistics.mean(cpu_vals):.2f} %")
        print(f"  CPU StdDev:  {statistics.stdev(cpu_vals):.2f} %")
        print(f"  Avg Memory:  {statistics.mean(mem_vals):.2f} MB")
        print(f"  Mem StdDev:  {statistics.stdev(mem_vals):.2f} MB")
        if exec_vals:
            print(f"  Avg Exec Time:  {statistics.mean(exec_vals):.4f} sec")
            print(f"  Exec StdDev:    {statistics.stdev(exec_vals):.4f} sec\n")
        else:
            print("  No execution time data.\n")
    else:
        print(f"{impl.upper()}: No data found.\n")

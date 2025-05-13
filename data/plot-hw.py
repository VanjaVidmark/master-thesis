import matplotlib.pyplot as plt
import os
import sys
import numpy as np

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]

# Each impl -> list of runs -> each run has timestamp, cpu, memory, exec_times
data = {}

for impl in implementations:
    perf_filename = f"{impl}{benchmark}Performance.txt"
    time_filename = f"{impl}{benchmark}Time.txt"

    if not os.path.isfile(perf_filename):
        raise FileNotFoundError(f"Could not find performance file: {perf_filename}")
    if not os.path.isfile(time_filename):
        raise FileNotFoundError(f"Could not find time file: {time_filename}")

    print(f"Using {impl}: {perf_filename} and {time_filename}")

    data[impl] = []

    with open(perf_filename, "r") as file:
        lines = file.readlines()

    current_run_data = None
    current_run = 0
    last_timestamp = None

    for line in lines:
        line = line.strip()
        if line.startswith("--- NEW BENCHMARK RUN ---"):
            current_run += 1
            if current_run > 3:
                break
            current_run_data = {
                "timestamp": [],
                "cpu": [],
                "memory": [],
                "iteration_markers": []
            }
            data[impl].append(current_run_data)
            continue

        if line.startswith("--- Iteration"):
            if last_timestamp is not None:
                current_run_data["iteration_markers"].append(last_timestamp)
            continue

        if not current_run_data or not line or line.startswith("CPU") or line.startswith("---"):
            continue

        try:
            cpu, memory, timestamp = map(float, line.split("|"))
            current_run_data["cpu"].append(cpu)
            current_run_data["memory"].append(memory)
            current_run_data["timestamp"].append(timestamp)
            last_timestamp = timestamp  # Only update when timestamp is valid
        except ValueError:
            continue

    # Normalize timestamps for each run
    for run_data in data[impl]:
        if run_data["timestamp"]:
            base_time = run_data["timestamp"][0]
            run_data["timestamp"] = [t - base_time for t in run_data["timestamp"]]
            run_data["iteration_markers"] = [t - base_time for t in run_data["iteration_markers"]]

    # Read execution times
    exec_times = []
    with open(time_filename, "r") as file:
        for line in file:
            line = line.strip()
            try:
                exec_times.append(float(line))
            except ValueError:
                continue

    # Slice exec_times per run (assuming roughly equal splits)
    split_exec_times = np.array_split(exec_times, min(3, len(exec_times)))
    for i, times in enumerate(split_exec_times):
        if i < len(data[impl]):
            data[impl][i]["exec_times"] = times.tolist()

# Plotting all small plots together
'''
fig, axs = plt.subplots(3, 3, figsize=(15, 8), sharex=False)
axs = axs.flatten()

metric_labels = {"cpu": "CPU Usage (%)", "memory": "Memory Usage (MB)", "exec_times": "Execution Time (s)"}

plot_idx = 0

for run_idx in range(3):
    for metric in ["cpu", "memory", "exec_times"]:
        if plot_idx >= len(axs):
            break
        ax = axs[plot_idx]
        for impl in implementations:
            if run_idx < len(data[impl]):
                run_data = data[impl][run_idx]
                if metric == "exec_times":
                    if "exec_times" in run_data and run_data["exec_times"]:
                        ax.plot(range(len(run_data["exec_times"])), run_data["exec_times"], marker='o', label=impl.upper(), linewidth=1.0)
                else:
                    if run_data["timestamp"]:
                        ax.plot(run_data["timestamp"], run_data[metric], label=impl.upper(), linewidth=1.0)

                        # Plot iteration markers as red dots
                        iteration_markers = run_data.get("iteration_markers", [])
                        timestamps = run_data["timestamp"]
                        values = run_data[metric]
                        for marker_time in iteration_markers:
                            if timestamps and values:
                                closest_idx = min(range(len(timestamps)), key=lambda i: abs(timestamps[i] - marker_time))
                                ax.scatter(timestamps[closest_idx], values[closest_idx], marker='o', color='red', s=30)

        ax.set_title(f"Run {run_idx + 1} - {metric_labels[metric]}", fontsize=10)
        ax.set_xlabel("Time (s)" if metric != "exec_times" else "Run Index", fontsize=8)
        ax.set_ylabel(metric_labels[metric], fontsize=8)
        ax.legend(fontsize=6)
        ax.grid(True)
        ax.tick_params(axis='both', which='major', labelsize=6)
        plot_idx += 1

fig.suptitle(f"{benchmark} Hardware Benchmark", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()
'''

# Plot only first run memory usage
import matplotlib.pyplot as plt

# Custom colors
colors = {
    "Kmp": "#8062f8",
    "Native": "#f19f26"
}

# Plot only first run memory usage (prettier version)
plt.figure(figsize=(8, 4))

for impl in implementations:
    if len(data[impl]) > 0:
        run_data = data[impl][0]
        timestamps = run_data["timestamp"]
        memory = run_data["memory"]
        if timestamps and memory:
            plt.plot(
                timestamps,
                memory,
                label=impl,
                color=colors[impl],
                linewidth=2.2,
                alpha=0.9
            )

# Styling
plt.title(f"{benchmark} - Run 1: Memory Usage", fontsize=14, pad=12)
plt.xlabel("Time (s)", fontsize=12)
plt.ylabel("Memory Usage (MB)", fontsize=12)
plt.legend(fontsize=10, title_fontsize=11)
plt.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)
plt.tight_layout()
plt.show()


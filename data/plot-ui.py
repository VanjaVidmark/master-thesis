import matplotlib.pyplot as plt
import os
import sys
import numpy as np

benchmark = sys.argv[1]
implementations = ["Kmp", "Native"]
run_indices = [3, 4, 5]

# Each impl -> list of runs -> each run has timestamp, cpu, fps, dropped, ram
data = {}

for impl in implementations:
    filename = f"{impl}{benchmark}.txt"
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"Could not find file: {filename}")

    print(f"Using {impl}: {filename}")

    data[impl] = []

    with open(filename, "r") as file:
        lines = file.readlines()

    current_run_data = None
    current_run = 0

    for line in lines:
        line = line.strip()

        if line.startswith("--- NEW BENCHMARK RUN ---"):
            current_run += 1
            if current_run not in run_indices:
                continue
            current_run_data = {
                "timestamp": [],
                "cpu": [],
                "fps": [],
                "dropped": [],
                "ram": []
            }
            data[impl].append(current_run_data)
            continue

        if not current_run_data or not line or line.startswith("CPU") or line.startswith("---"):
            continue

        parts = [p.strip() for p in line.split("|")]
        if len(parts) == 5:
            try:
                cpu = float(parts[0])
                fps = float(parts[1])
                dropped = float(parts[2])
                ram = float(parts[3])
                timestamp = float(parts[4])

                current_run_data["cpu"].append(cpu)
                current_run_data["fps"].append(fps)
                current_run_data["dropped"].append(dropped)
                current_run_data["ram"].append(ram)
                current_run_data["timestamp"].append(timestamp)
            except ValueError:
                continue

# Now plot all runs together

fig, axs = plt.subplots(3, 4, figsize=(15, 8), sharex=False)
axs = axs.flatten()

metrics = ["cpu", "fps", "dropped", "ram"]
metric_labels = {"cpu": "CPU Usage (%)", "fps": "FPS", "dropped": "Frame Drops", "ram": "RAM Usage (MB)"}

plot_idx = 0

for run_idx in range(3):
    for metric in metrics:
        if plot_idx >= len(axs):
            break
        ax = axs[plot_idx]
        for impl in implementations:
            if run_idx < len(data[impl]):
                run_data = data[impl][run_idx]
                if run_data["timestamp"]:
                    base_time = run_data["timestamp"][0]
                    timestamps = [t - base_time for t in run_data["timestamp"]]
                    ax.plot(timestamps, run_data[metric], label=impl.upper(), linewidth=1.0)
        ax.set_title(f"{benchmark} Run {run_idx + 1} - {metric_labels[metric]}", fontsize=8)
        ax.legend(fontsize=6)
        ax.grid(True)
        plot_idx += 1

for ax in axs:
    ax.set_xlabel("Time (s)", fontsize=7)
    ax.set_ylabel("Value", fontsize=7)
    ax.tick_params(axis='both', which='major', labelsize=6)

fig.suptitle(f"{benchmark} Benchmark Results", fontsize=14)
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

'''

# === FPS Plot: Only First Run, After 10 Seconds ===
plt.figure(figsize=(8, 4))
colors = {
    "Kmp": "#8062f8",
    "Native": "#f19f26"
}

for impl in implementations:
    if len(data[impl]) > 0:
        run_data = data[impl][0]  # First run only
        timestamps = run_data["timestamp"]
        fps_values = run_data["fps"]

        if timestamps and fps_values:
            # Normalize timestamps
            base_time = timestamps[0]
            normalized_timestamps = [t - base_time for t in timestamps]

            # Filter out first 10 seconds
            filtered = [(t, f) for t, f in zip(normalized_timestamps, fps_values) if t >= 10.0]
            if filtered:
                filtered_timestamps, filtered_fps = zip(*filtered)
                plt.plot(
                    filtered_timestamps,
                    filtered_fps,
                    label=impl,
                    color=colors[impl],
                    linewidth=2.2,
                    alpha=0.9
                )

plt.title(f"Multiple {benchmark} - Run 1: FPS", fontsize=14, pad=12)
plt.xlabel("Time (s)", fontsize=12)
plt.ylabel("FPS", fontsize=12)
plt.legend(fontsize=10, title_fontsize=11)
plt.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)
plt.tight_layout()
plt.show()
'''
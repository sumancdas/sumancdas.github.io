import os
import pandas as pd
import matplotlib.pyplot as plt

DATA_DIR = "../data"
PLOT_DIR = "../plots"

os.makedirs(PLOT_DIR, exist_ok=True)

baseline = pd.read_csv(f"{DATA_DIR}/baseline_metrics.csv")
dos = pd.read_csv(f"{DATA_DIR}/dos_metrics.csv")
fdi = pd.read_csv(f"{DATA_DIR}/fdi_metrics.csv")


def split_runs(df, gap_seconds=5):
    df = df.copy().sort_values("timestamp").reset_index(drop=True)
    df["gap"] = df["timestamp"].diff().fillna(0)
    df["run_id"] = (df["gap"] > gap_seconds).cumsum()
    runs = []

    for _, run in df.groupby("run_id"):
        run = run.copy()
        run["time_sec"] = run["timestamp"] - run["timestamp"].min()
        runs.append(run)

    return runs


def choose_run(df):
    runs = split_runs(df)

    if not runs:
        return df.copy()

    runs = sorted(runs, key=len, reverse=True)
    run = runs[0].copy()
    run = run[run["time_sec"] <= 180].copy()

    return run


def make_bins(run_df, metric, bin_size=1):
    df = run_df.copy()
    df["time_bin"] = (df["time_sec"] // bin_size).astype(int)

    grouped = (
        df.groupby("time_bin", as_index=False)[metric]
        .mean()
        .rename(columns={metric: "value"})
    )

    grouped["time_sec"] = grouped["time_bin"] * bin_size
    return grouped


baseline_run = choose_run(baseline)
dos_run = choose_run(dos)
fdi_run = choose_run(fdi)

colors = {
    "Baseline": "#4C78A8",
    "DoS": "#E45756",
    "FDI": "#54A24B"
}

def plot_metric(metric, ylabel, filename):
    if metric == "ipdv":
        bin_size = 2
    else:
        bin_size = 5

    baseline_plot = make_bins(baseline_run, metric, bin_size=bin_size)
    dos_plot = make_bins(dos_run, metric, bin_size=bin_size)
    fdi_plot = make_bins(fdi_run, metric, bin_size=bin_size)

    plt.figure(figsize=(10, 4.8))

    plt.plot(
        baseline_plot["time_sec"], baseline_plot["value"],
        label="Baseline", color=colors["Baseline"], linewidth=1.8
    )
    plt.plot(
        dos_plot["time_sec"], dos_plot["value"],
        label="DoS", color=colors["DoS"], linewidth=1.8
    )
    plt.plot(
        fdi_plot["time_sec"], fdi_plot["value"],
        label="FDI", color=colors["FDI"], linewidth=1.8
    )

    plt.xlabel("Time (seconds)")
    plt.ylabel(ylabel)
    plt.title(f"{ylabel} over time")
    plt.xlim(0, 180)
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()

    output_path = f"{PLOT_DIR}/{filename}"
    plt.savefig(output_path, dpi=300)
    plt.close()

    print(f"Saved: {output_path}")

plot_metric("latency", "Latency (s)", "latency_timeseries.png")
plot_metric("jitter", "Jitter (s)", "jitter_timeseries.png")
plot_metric("ipdv", "IPDV (s)", "ipdv_timeseries.png")

import pandas as pd
import matplotlib.pyplot as plt

baseline = pd.read_csv("../data/baseline_metrics.csv")
dos = pd.read_csv("../data/dos_metrics.csv")
fdi = pd.read_csv("../data/fdi_metrics.csv")

metrics = ["latency", "jitter", "ipdv"]

colors = ["#4C78A8", "#E45756", "#54A24B"]
labels = ["Baseline", "DoS", "FDI"]

for metric in metrics:
    plt.figure(figsize=(8, 6))

    data = [
        baseline[metric],
        dos[metric],
        fdi[metric]
    ]

    box = plt.boxplot(
        data,
        labels=labels,
        showfliers=False,
        patch_artist=True,
        medianprops={"color": "black", "linewidth": 1.3},
        whiskerprops={"linewidth": 1.1},
        capprops={"linewidth": 1.1},
        boxprops={"linewidth": 1.1}
    )

    for patch, color in zip(box["boxes"], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.55)

    plt.ylabel(metric.upper() if metric == "ipdv" else metric.capitalize())
    plt.title(f"{metric.upper() if metric == 'ipdv' else metric.capitalize()} comparison")
    plt.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()

    output_path = f"../plots/{metric}_boxplot.png"
    plt.savefig(output_path, dpi=300)
    plt.close()

    print(f"Saved: {output_path}")

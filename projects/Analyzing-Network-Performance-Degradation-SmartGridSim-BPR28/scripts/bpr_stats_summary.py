import pandas as pd

baseline = pd.read_csv("../data/baseline_metrics.csv")
dos = pd.read_csv("../data/dos_metrics.csv")
fdi = pd.read_csv("../data/fdi_metrics.csv")

metrics = ["latency", "jitter", "ipdv"]
output_file = "../results/statistical_summary.csv"

results = []

for metric in metrics:
    baseline_mean = baseline[metric].mean()
    baseline_std = baseline[metric].std()

    threshold_2sigma = baseline_mean + 2 * baseline_std
    threshold_3sigma = baseline_mean + 3 * baseline_std

    dos_mean = dos[metric].mean()
    dos_std = dos[metric].std()
    dos_above_2sigma = (dos[metric] > threshold_2sigma).mean() * 100
    dos_above_3sigma = (dos[metric] > threshold_3sigma).mean() * 100

    fdi_mean = fdi[metric].mean()
    fdi_std = fdi[metric].std()
    fdi_above_2sigma = (fdi[metric] > threshold_2sigma).mean() * 100
    fdi_above_3sigma = (fdi[metric] > threshold_3sigma).mean() * 100

    results.append([
        metric,
        baseline_mean, baseline_std,
        dos_mean, dos_std,
        fdi_mean, fdi_std,
        threshold_2sigma, threshold_3sigma,
        dos_above_2sigma, dos_above_3sigma,
        fdi_above_2sigma, fdi_above_3sigma
    ])

baseline_loss = baseline["packet_loss"].mean() * 100
dos_loss = dos["packet_loss"].mean() * 100
fdi_loss = fdi["packet_loss"].mean() * 100

columns = [
    "metric",
    "baseline_mean", "baseline_std",
    "dos_mean", "dos_std",
    "fdi_mean", "fdi_std",
    "threshold_2sigma", "threshold_3sigma",
    "dos_%_above_2sigma", "dos_%_above_3sigma",
    "fdi_%_above_2sigma", "fdi_%_above_3sigma"
]

summary_df = pd.DataFrame(results, columns=columns)
summary_df.to_csv(output_file, index=False)

print("Packet loss ratio (%)")
print("---------------------")
print(f"Baseline: {baseline_loss:.3f}%")
print(f"DoS     : {dos_loss:.3f}%")
print(f"FDI     : {fdi_loss:.3f}%")
print(f"\nSaved: {output_file}")

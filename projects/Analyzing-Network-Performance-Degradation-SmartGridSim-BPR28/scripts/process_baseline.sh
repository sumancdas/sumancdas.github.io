#!/bin/bash

# Process baseline PCAP files
# Combines 12 PCAPs into one master CSV file

PCAP_DIR="../pcaps/baseline"
CSV_OUT="../csv/baseline/baseline_metrics.csv"
EXTRACT_SCRIPT="./extract_metrics.sh"

echo "[INFO] Processing BASELINE PCAPs..."
rm -f "$CSV_OUT"

# Add each PCAP to one CSV file
for PCAP in "$PCAP_DIR"/control_run_*.pcap; do
  echo "[INFO] Processing $(basename "$PCAP")"
  "$EXTRACT_SCRIPT" "$PCAP" "$CSV_OUT"
done

echo "[DONE] Baseline master CSV created:"
echo "       $CSV_OUT"

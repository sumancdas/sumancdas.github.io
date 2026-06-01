#!/bin/bash

# Process DoS PCAP files
# Combines 12 PCAPs into one master CSV

PCAP_DIR="../pcaps/dos"
CSV_OUT="../csv/dos/dos_metrics.csv"
EXTRACT_SCRIPT="./extract_metrics.sh"

echo "[INFO] Processing DoS PCAPs..."
rm -f "$CSV_OUT"

# Add each PCAP to one CSV file

for PCAP in "$PCAP_DIR"/control_run_*.pcap; do
  echo "[INFO] Processing $(basename "$PCAP")"
  "$EXTRACT_SCRIPT" "$PCAP" "$CSV_OUT"
done

echo "[DONE] DoS master CSV created:"
echo "       $CSV_OUT"

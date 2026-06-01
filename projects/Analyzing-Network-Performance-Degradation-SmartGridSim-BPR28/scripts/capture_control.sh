#!/bin/bash

# Capture Control Center traffic
IFACE="CONTROLSW-eth3"
TOTAL_DURATION=180
BASE_DIR="/home/suman/Desktop/SmartGridSim/experiments"
OUTDIR="${BASE_DIR}/$1"
RUN_ID="$2"

if [ -z "$OUTDIR" ] || [ -z "$RUN_ID" ]; then
  echo "Usage: ./capture_control.sh <OUTDIR> <RUN_ID>"
  exit 1
fi

PCAP_FILE="${OUTDIR}/control_run_${RUN_ID}.pcap"

# Prepare output folder
echo "[INFO] Preparing capture directory"
sudo mkdir -p "$OUTDIR"
sudo chmod 777 "$OUTDIR"

echo "[INFO] Starting packet capture"
echo "[INFO] Interface : $IFACE"
echo "[INFO] Duration  : $TOTAL_DURATION seconds"
echo "[INFO] Output    : $PCAP_FILE"

sudo tshark -i "$IFACE" \
  -a duration:$TOTAL_DURATION \
  -w "$PCAP_FILE"

echo "[INFO] Capture finished successfully"

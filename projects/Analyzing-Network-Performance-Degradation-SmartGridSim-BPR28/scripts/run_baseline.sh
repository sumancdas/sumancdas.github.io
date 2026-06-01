#!/bin/bash

# Baseline experiment and traffic capture
RUN_ID=$1
OUTDIR="pcaps/baseline"

if [ -z "$RUN_ID" ]; then
  echo "Usage: ./run_baseline.sh <RUN_ID>"
  exit 1
fi

PRE_STABILIZATION=30
BASELINE_TIME=120
POST_STABILIZATION=30

echo "BASELINE RUN $RUN_ID STARTED"

# Start packet capture
./capture_control.sh "$OUTDIR" "$RUN_ID" &
CAPTURE_PID=$!

echo "[INFO] Pre-stabilization (${PRE_STABILIZATION}s)"
sleep $PRE_STABILIZATION

echo "[INFO] Baseline traffic only (${BASELINE_TIME}s)"
sleep $BASELINE_TIME

echo "[INFO] Post-stabilization (${POST_STABILIZATION}s)"
sleep $POST_STABILIZATION

wait $CAPTURE_PID

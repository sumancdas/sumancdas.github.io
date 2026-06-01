#!/bin/bash

# FDI experiment and traffic capture
RUN_ID=$1
OUTDIR="pcaps/fdi"

if [ -z "$RUN_ID" ]; then
  echo "Usage: ./run_fdi.sh <RUN_ID>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FDI_SCRIPT="${SCRIPT_DIR}/inject_fdi.py"

PRE_STABILIZATION=30
ATTACK_TIME=120
POST_STABILIZATION=30

echo "FDI RUN $RUN_ID STARTED"

# Start packet capture
./capture_control.sh "$OUTDIR" "$RUN_ID" &
CAPTURE_PID=$!

echo "[INFO] Pre-attack stabilization (${PRE_STABILIZATION}s)"
sleep $PRE_STABILIZATION

echo "[INFO] Starting FDI attack (${ATTACK_TIME}s)"
if [ ! -f "$FDI_SCRIPT" ]; then
  echo "[ERROR] FDI injection script not found:"
  echo "        $FDI_SCRIPT"
  kill $CAPTURE_PID 2>/dev/null
  exit 1
fi

# Start FDI script
python3 "$FDI_SCRIPT" &
FDI_PID=$!

sleep $ATTACK_TIME

echo "[INFO] Stopping FDI attack"
kill $FDI_PID 2>/dev/null

echo "[INFO] Post-attack stabilization (${POST_STABILIZATION}s)"
sleep $POST_STABILIZATION

wait $CAPTURE_PID

echo "FDI RUN $RUN_ID COMPLETED"

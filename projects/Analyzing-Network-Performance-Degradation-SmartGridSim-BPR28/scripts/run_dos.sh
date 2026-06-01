#!/bin/bash

# DoS experiment and traffic capture
RUN_ID=$1
OUTDIR="pcaps/dos"

if [ -z "$RUN_ID" ]; then
  echo "Usage: ./run_dos.sh <RUN_ID>"
  exit 1
fi

PRE_STABILIZATION=30
ATTACK_TIME=120
POST_STABILIZATION=30

echo "DoS RUN $RUN_ID STARTED"

# Start packet capture
./capture_control.sh "$OUTDIR" "$RUN_ID" &
CAPTURE_PID=$!

echo "[INFO] Pre-attack stabilization (${PRE_STABILIZATION}s)"
sleep $PRE_STABILIZATION

echo "[INFO] Starting DoS attack (${ATTACK_TIME}s)"
# Start DoS traffic
mininet h1 ping -f 1.1.10.10 > /dev/null 2>&1 &
DOS_PID=$!

sleep $ATTACK_TIME

echo "[INFO] Stopping DoS attack"
kill $DOS_PID 2>/dev/null

echo "[INFO] Post-attack stabilization (${POST_STABILIZATION}s)"
sleep $POST_STABILIZATION

wait $CAPTURE_PID

echo "DoS RUN $RUN_ID COMPLETED"

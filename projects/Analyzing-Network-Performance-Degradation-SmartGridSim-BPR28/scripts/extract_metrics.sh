#!/bin/bash

# Extract metrics from one PCAP file
PCAP_FILE="$1"
CSV_FILE="$2"

if [ -z "$PCAP_FILE" ] || [ -z "$CSV_FILE" ]; then
  echo "Usage: ./extract_metrics.sh <input.pcap> <output.csv>"
  exit 1
fi

if [ ! -f "$CSV_FILE" ]; then
  echo "timestamp,src_ip,dst_ip,frame_len,latency,jitter,ipdv,packet_loss" > "$CSV_FILE"
fi

TMP_FILE=$(mktemp)

# Read TCP fields with tshark
tshark -r "$PCAP_FILE" \
  -Y "tcp" \
  -T fields \
  -e frame.time_epoch \
  -e ip.src \
  -e ip.dst \
  -e frame.len \
  -e tcp.analysis.ack_rtt \
  -e tcp.analysis.retransmission \
  -E separator=, \
  -E occurrence=f \
  > "$TMP_FILE"

awk -F',' '
BEGIN {
    prev_latency = ""
}
{
    timestamp = $1
    src = $2
    dst = $3
    len = $4
    latency = $5
    retrans = $6

    if (latency == "") {
        next
    }

    if (prev_latency == "") {
        jitter = 0
        ipdv = 0
    } else {
        # Calculate IPDV and jitter
        delta = latency - prev_latency
        ipdv = delta

        if (delta < 0) {
            jitter = -delta
        } else {
            jitter = delta
        }
    }

    prev_latency = latency

    if (retrans != "") {
        packet_loss = 1
    } else {
        packet_loss = 0
    }

    printf "%s,%s,%s,%s,%.6f,%.6f,%.6f,%d\n",
           timestamp, src, dst, len, latency, jitter, ipdv, packet_loss
}
' "$TMP_FILE" >> "$CSV_FILE"

rm "$TMP_FILE"

echo "[INFO] Done: $(basename "$PCAP_FILE")"

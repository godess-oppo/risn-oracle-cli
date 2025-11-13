#!/usr/bin/env bash
# demo/trigger_incident.sh — create a simulated incident for ops demo
set -e
BASE="${HOME}/risn-cli"
mkdir -p "$BASE/demo"
cat > "$BASE/demo/incident.json" <<'JSON'
{"id":"incident-demo","severity":"medium","service":"worker","detected":"$(date -u +"%Y-%m-%dT%H:%M:%SZ")","note":"simulated worker crash"}
JSON
echo "[demo] incident written to $BASE/demo/incident.json"

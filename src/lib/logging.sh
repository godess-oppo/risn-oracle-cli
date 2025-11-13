#!/bin/bash
AUDIT_LOG="$RISN_HOME/audit/audit.log"
MACHINE_LOG="$RISN_HOME/audit/machine.log"
init_logging() { mkdir -p "$(dirname "$AUDIT_LOG")"; }
log_audit() {
    local level="$1" component="$2" message="$3" timestamp=$(date -Iseconds)
    echo "[$timestamp] [$level] [$component] $message" | tee -a "$AUDIT_LOG"
    jq -n --arg ts "$timestamp" --arg lvl "$level" --arg comp "$component" --arg msg "$message" \
        '{timestamp: $ts, level: $lvl, component: $comp, message: $msg, host: "'$(hostname)'", risn_version: "1.0.0"}' >> "$MACHINE_LOG"
    echo "" >> "$MACHINE_LOG"
}
log_action() {
    local action="$1" params="$2" action_id=$(date +%s%N | sha256sum | head -c 16)
    local action_file="$ACTIONS_DIR/pending/$action_id.json"
    jq -n --arg id "$action_id" --arg action "$action" --arg params "$params" --arg timestamp "$(date -Iseconds)" \
        '{id: $id, action: $action, parameters: ($params | fromjson? // $params), timestamp: $timestamp, status: "pending", rollback_plan: {}}' > "$action_file"
    echo "$action_id"
}
complete_action() {
    local action_id="$1" result="$2"
    local action_file="$ACTIONS_DIR/pending/$action_id.json"
    local completed_file="$ACTIONS_DIR/completed/$action_id.json"
    if [[ -f "$action_file" ]]; then
        jq --arg result "$result" --arg status "completed" '.status = $status | .result = $result' "$action_file" > "$completed_file"
        rm "$action_file"
    fi
}

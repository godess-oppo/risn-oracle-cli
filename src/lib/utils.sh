#!/bin/bash
generate_id() { date +%s%N | sha256sum | head -c 16; }
validate_json() { jq empty <<< "$1" 2>/dev/null; }
check_dry_run() { for arg in "$@"; do [[ "$arg" == "--dry-run" ]] && return 0; done; return 1; }
is_auto_mode() { for arg in "$@"; do [[ "$arg" == "--auto" ]] && return 0; done; return 1; }
safe_rollback() {
    local action_id="$1" reason="$2"
    log_audit "WARN" "rollback" "Initiating rollback for action $action_id: $reason"
    local action_file="$ACTIONS_DIR/completed/$action_id.json"
    if [[ -f "$action_file" ]]; then
        local rollback_plan=$(jq -r '.rollback_plan' "$action_file")
        if [[ "$rollback_plan" != "{}" ]]; then
            log_audit "INFO" "rollback" "Executing rollback plan: $rollback_plan"
            jq --arg status "rolled-back" --arg reason "$reason" '.status = $status | .rollback_reason = $reason' \
               "$action_file" > "$ACTIONS_DIR/rolled-back/$action_id.json"
            rm "$action_file"
        fi
    fi
}
health_check() {
    local component="$1"
    case "$component" in
        "api")
            curl -s -f "${STORE_URL}/health" >/dev/null && return 0 || return 1
            ;;
        "database")
            psql "${DATABASE_URL}" -c "SELECT 1;" >/dev/null 2>&1 && return 0 || return 1
            ;;
        "redis")
            redis-cli -u "${REDIS_URL}" ping >/dev/null && return 0 || return 1
            ;;
        *) return 1 ;;
    esac
}

#!/bin/bash
ops_command() {
    local subcommand="$1"
    shift
    case "$subcommand" in
        heal) ops_heal "$@" ;;
        status) ops_status "$@" ;;
        --help|-h) show_ops_help ;;
        *) log_audit "ERROR" "ops" "Unknown subcommand: $subcommand"; return 1 ;;
    esac
}
ops_heal() {
    local auto_mode=false dry_run=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto) auto_mode=true; shift ;;
            --dry-run) dry_run=true; shift ;;
            --help|-h) show_ops_heal_help; return 0 ;;
            *) shift ;;
        esac
    done
    log_audit "INFO" "ops" "Starting system health diagnosis"
    safety_pause "system_healing" "high"
    local incidents=()
    health_check "api" || incidents+=("api_unreachable")
    health_check "database" || incidents+=("database_connection")
    health_check "redis" || incidents+=("redis_connection")
    local disk_usage=$(df "$RISN_HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
    [[ $disk_usage -gt 90 ]] && incidents+=("disk_space_low")
    [[ ${#incidents[@]} -eq 0 ]] && log_audit "INFO" "ops" "All systems operational" && return 0
    log_audit "WARN" "ops" "Detected incidents: ${incidents[*]}"
    [[ "$auto_mode" == true ]] && {
        for incident in "${incidents[@]}"; do
            auto_remediate "$incident" "{}" "$dry_run" && log_audit "SUCCESS" "ops" "Auto-remediation successful" || log_audit "ERROR" "ops" "Auto-remediation failed"
        done
    } || log_audit "INFO" "ops" "Auto-mode not enabled. Manual intervention required"
}
ops_status() {
    echo "System Status:"
    echo "✅ API: $(health_check "api" && echo "Healthy" || echo "Unhealthy")"
    echo "✅ Database: $(health_check "database" && echo "Healthy" || echo "Unhealthy")"
    echo "✅ Redis: $(health_check "redis" && echo "Healthy" || echo "Unhealthy")"
    echo "📊 Disk: $(df -h "$RISN_HOME" | awk 'NR==2 {print $5}') used"
}
show_ops_help() {
    cat << EOL
Manage system operations and healing

Usage: risn ops <command> [options]

Commands:
  heal      Diagnose and auto-remediate system incidents
  status    Show system status and health
  --help, -h  Show this help message
EOL
}
show_ops_heal_help() {
    cat << EOL
Diagnose and heal system incidents

Usage: risn ops heal [options]

Options:
  --auto        Enable automatic remediation
  --dry-run     Simulate healing without making changes
  --help, -h    Show this help message
EOL
}

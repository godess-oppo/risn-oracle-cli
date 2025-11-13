#!/bin/bash
awaken_command() {
    local aspect="$1"
    shift
    
    case "$aspect" in
        "consciousness")
            awaken_consciousness "$@"
            ;;
        "identity")
            awaken_identity "$@"
            ;;
        "expression")
            awaken_expression "$@"
            ;;
        "flow")
            awaken_flow "$@"
            ;;
        --help|-h)
            show_awaken_help
            return 0
            ;;
        *)
            log_error "Unknown aspect to awaken: $aspect"
            return 1
            ;;
    esac
}

awaken_consciousness() {
    local level="beginner" focus="present"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --level)
                level="$2"
                shift 2
                ;;
            --focus)
                focus="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log_identity "Awakening consciousness to fluid identity")
    
    local awakening_data=$(jq -n \
        --arg level "$level" \
        --arg focus "$focus" \
        --arg timestamp "$(date -Iseconds)" \
        '{
            awakening_type: "consciousness",
            level: $level,
            focus: $focus,
            timestamp: $timestamp,
            flow_state: "awakening"
        }')
    
    # Activate awakening agents
    "$RISN_AGENTS/fluid_weaver/weaver_agent.sh" "emerge" "$awakening_data" "{}"
    "$RISN_AGENTS/identity_oracle/oracle_agent.sh" "guide_emergence" "$awakening_data"
    
    flow_memory "awakening" "$awakening_data" "consciousness_awakening"
    
    log_success "Consciousness awakened to fluid identity")
}

awaken_identity() {
    local name="" current="exploration" intensity="medium"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                name="$2"
                shift 2
                ;;
            --current)
                current="$2"
                shift 2
                ;;
            --intensity)
                intensity="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$name" ]] && log_error "Identity name is required" && return 1
    
    log_identity "Awakening fluid identity: $name")
    
    local identity_data=$(jq -n \
        --arg name "$name" \
        --arg current "$current" \
        --arg intensity "$intensity" \
        --arg timestamp "$(date -Iseconds)" \
        '{
            identity_name: $name,
            awakening_current: $current,
            flow_intensity: $intensity,
            timestamp: $timestamp,
            state: "awakening"
        }')
    
    local identity_file="$RISN_IDENTITY/profiles/${name}.flow.json"
    echo "$identity_data" > "$identity_file"
    
    log_success "Fluid identity awakened: $name")
    echo "$identity_data" | jq .
}

show_awaken_help() {
    cat << EOL
Awaken aspects of your fluid identity consciousness

Usage: risn awaken <aspect> [options]

Aspects:
  consciousness    Awaken to fluid identity awareness
  identity         Begin a new fluid identity journey
  expression       Awaken creative expression channels
  flow             Connect to the universal flow

Options for consciousness:
  --level <type>    Awakening level (beginner, intermediate, advanced)
  --focus <area>    Focus area (present, past, future, integration)

Options for identity:
  --name <text>     Identity stream name (required)
  --current <type>  Starting current (exploration, expression, integration)
  --intensity <level> Flow intensity (gentle, medium, strong)

Examples:
  risn awaken consciousness --level beginner --focus present
  risn awaken identity --name river --current exploration --intensity gentle
EOL
}

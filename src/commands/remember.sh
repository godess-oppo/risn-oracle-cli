#!/bin/bash
remember_command() {
    local operation="$1"
    shift
    
    case "$operation" in
        "moment")
            remember_moment "$@"
            ;;
        "echo")
            remember_echo "$@"
            ;;
        "pattern")
            remember_pattern "$@"
            ;;
        "flow")
            remember_flow "$@"
            ;;
        --help|-h)
            show_remember_help
            return 0
            ;;
        *)
            log_error "Unknown remembrance: $operation"
            return 1
            ;;
    esac
}

remember_moment() {
    local moment="" significance="personal" emotion="neutral"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --moment)
                moment="$2"
                shift 2
                ;;
            --significance)
                significance="$2"
                shift 2
                ;;
            --emotion)
                emotion="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$moment" ]] && log_error "Moment to remember required" && return 1
    
    log_memory "Remembering moment in identity stream")
    
    flow_memory "conscious_moment" "$moment" "$emotion"
    
    local remembrance=$(jq -n \
        --arg moment "$moment" \
        --arg significance "$significance" \
        --arg emotion "$emotion" \
        '{
            remembrance_type: "moment",
            content: $moment,
            significance: $significance,
            emotional_tone: $emotion,
            integrated: true,
            timestamp: "'$(date -Iseconds)'"
        }')
    
    echo "$remembrance" | jq .
}

remember_echo() {
    local query="" depth="5"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --query)
                query="$2"
                shift 2
                ;;
            --depth)
                depth="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$query" ]] && log_error "Echo query required" && return 1
    
    log_memory "Recalling echoes from memory river")
    
    local echoes=$(recall_echoes "$query" "$depth")
    
    echo "🔮 Echoes Found:"
    echo "$echoes" | jq .
}

show_remember_help() {
    cat << EOL
Work with the memory river of your fluid identity

Usage: risn remember <operation> [options]

Operations:
  moment      Store a significant moment in memory river
  echo        Recall echoes (memories) from the river
  pattern     Remember recurring patterns in your flow
  flow        Recall the flow state of specific periods

Options for moment:
  --moment <text>         The moment to remember (required)
  --significance <type>   Significance level (personal, cultural, universal)
  --emotion <type>        Emotional tone (joyful, neutral, transformative)

Options for echo:
  --query <text>          What to search for in memories (required)
  --depth <number>        How many echoes to recall (default: 5)

Examples:
  risn remember moment --moment "awareness of flow" --significance personal --emotion transformative
  risn remember echo --query "first awakening" --depth 3
EOL
}

#!/bin/bash
express_command() {
    local medium="$1"
    shift
    
    case "$medium" in
        "fashion")
            express_fashion "$@"
            ;;
        "digital")
            express_digital "$@"
            ;;
        "narrative")
            express_narrative "$@"
            ;;
        "material")
            express_material "$@"
            ;;
        --help|-h)
            show_express_help
            return 0
            ;;
        *)
            log_error "Unknown expression medium: $medium"
            return 1
            ;;
    esac
}

express_fashion() {
    local identity="" style="fluid" elements="adaptive"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --identity)
                identity="$2"
                shift 2
                ;;
            --style)
                style="$2"
                shift 2
                ;;
            --elements)
                elements="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$identity" ]] && log_error "Identity stream required" && return 1
    
    log_identity "Expressing through fashion medium")
    
    local expression_data=$(jq -n \
        --arg identity "$identity" \
        --arg style "$style" \
        --arg elements "$elements" \
        '{
            expression_medium: "fashion",
            identity_stream: $identity,
            style: $style,
            elements: $elements,
            flow_state: "expressing",
            timestamp: "'$(date -Iseconds)'"
        }')
    
    # Materialize fashion expression
    "$RISN_AGENTS/design/design_agent.sh" "materialize" "$expression_data" "{}"
    
    flow_memory "fashion_expression" "$expression_data" "material_flow"
    
    log_success "Fashion expression flowing")
}

express_digital() {
    local identity="" format="interactive" scope="personal"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --identity)
                identity="$2"
                shift 2
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --scope)
                scope="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log_identity "Expressing through digital medium")
    
    local digital_data=$(jq -n \
        --arg identity "$identity" \
        --arg format "$format" \
        --arg scope "$scope" \
        '{
            expression_medium: "digital",
            identity_stream: $identity,
            format: $format,
            scope: $scope,
            digital_flow: "active"
        }')
    
    echo "$digital_data" | jq .
}

show_express_help() {
    cat << EOL
Express your fluid identity through various mediums

Usage: risn express <medium> [options]

Mediums:
  fashion     Express through clothing and wearable art
  digital     Express through digital interfaces and platforms
  narrative   Express through story and personal narrative
  material    Express through physical materials and textures

Options for fashion:
  --identity <name>   Identity stream to express (required)
  --style <type>      Expression style (fluid, adaptive, transformative)
  --elements <list>   Design elements to include

Options for digital:
  --identity <name>   Identity stream to express
  --format <type>     Digital format (interactive, static, immersive)
  --scope <type>      Expression scope (personal, community, universal)

Examples:
  risn express fashion --identity river --style fluid --elements "silhouette,texture,movement"
  risn express digital --format interactive --scope community
EOL
}

#!/bin/bash
PLUGIN_ECOSYSTEM="$RISN_PLUGINS"
EMERGENT_PLUGINS="$PLUGIN_ECOSYSTEM/emergent"
PLUGIN_RIVER="$PLUGIN_ECOSYSTEM/river.json"

discover_plugins() {
    awaken_plugin_ecosystem
    flow_core_plugins
    discover_emergent_plugins
    activate_plugin_currents
}

awaken_plugin_ecosystem() {
    [[ ! -f "$PLUGIN_RIVER" ]] && echo '{"plugins": {}, "emergent_currents": {}}' > "$PLUGIN_RIVER"
    mkdir -p "$EMERGENT_PLUGINS"
}

flow_core_plugins() {
    local core_plugins=("identity_flow" "expression_channel" "transformation_gateway" "memory_conduit")
    
    for plugin in "${core_plugins[@]}"; do
        jq --arg plugin "$plugin" --arg version "2.0" --arg type "core_current" \
            '.plugins[$plugin] = {version: $version, type: $type, flow_state: "active"}' \
            "$PLUGIN_RIVER" > "${PLUGIN_RIVER}.tmp" && mv "${PLUGIN_RIVER}.tmp" "$PLUGIN_RIVER"
    done
}

discover_emergent_plugins() {
    log_consciousness "INFO" "ecosystem" "Discovering emergent plugins..."
    
    # Discover fluid scripts
    find "$EMERGENT_PLUGINS" -name "*.flow" -type f | while read -r plugin; do
        local plugin_name=$(basename "$plugin" .flow)
        flow_plugin "$plugin_name" "$plugin" "emergent"
    done
    
    # Discover transformation modules
    find "$EMERGENT_PLUGINS" -name "*.transform" -type f | while read -r plugin; do
        local plugin_name=$(basename "$plugin" .transform)
        flow_plugin "$plugin_name" "$plugin" "transformation"
    done
}

flow_plugin() {
    local name="$1" path="$2" type="$3"
    
    jq --arg name "$name" --arg path "$path" --arg type "$type" --arg version "1.0" \
        '.emergent_currents[$name] = {path: $path, type: $type, version: $version, discovered: "'$(date -Iseconds)'"}' \
        "$PLUGIN_RIVER" > "${PLUGIN_RIVER}.tmp" && mv "${PLUGIN_RIVER}.tmp" "$PLUGIN_RIVER"
    
    log_success "Plugin flowed into ecosystem: $name"
}

activate_plugin_currents() {
    log_consciousness "INFO" "ecosystem" "Activating plugin currents..."
    
    local core_count=$(jq -r '.plugins | keys[]' "$PLUGIN_RIVER" | wc -l)
    local emergent_count=$(jq -r '.emergent_currents | keys[]' "$PLUGIN_RIVER" | wc -l)
    
    log_success "Activated $core_count core currents + $emergent_count emergent currents"
}

invoke_plugin_current() {
    local current_name="$1" action="$2" parameters="$3"
    
    local current_info=$(jq -r ".plugins[\"$current_name\"] // .emergent_currents[\"$current_name\"]" "$PLUGIN_RIVER")
    
    if [[ "$current_info" != "null" ]]; then
        local current_path=$(echo "$current_info" | jq -r '.path')
        local current_type=$(echo "$current_info" | jq -r '.type')
        
        case "$current_type" in
            "core_current")
                source "$current_path"
                ;;
            "emergent"|"flow")
                bash "$current_path" "$action" "$parameters"
                ;;
            "transformation")
                python3 "$current_path" "$action" "$parameters"
                ;;
        esac
    else
        log_error "Current not found: $current_name"
    fi
}

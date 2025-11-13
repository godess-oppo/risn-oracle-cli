#!/bin/bash
PLUGIN_DIR="$RISN_PLUGINS"
AUTO_REGISTER_DIR="$PLUGIN_DIR/auto_registered"
PLUGIN_REGISTRY="$PLUGIN_DIR/registry.json"

load_plugins() {
    initialize_plugin_system
    register_core_plugins
    auto_discover_plugins
    activate_plugins
}

initialize_plugin_system() {
    [[ ! -f "$PLUGIN_REGISTRY" ]] && echo '{"plugins": {}, "auto_registered": {}}' > "$PLUGIN_REGISTRY"
    mkdir -p "$AUTO_REGISTER_DIR"
}

register_core_plugins() {
    local core_plugins=("identity_evolver" "speculative_generator" "harmony_optimizer")
    
    for plugin in "${core_plugins[@]}"; do
        jq --arg plugin "$plugin" --arg version "2.0.0" --arg type "core" \
            '.plugins[$plugin] = {version: $version, type: $type, active: true}' \
            "$PLUGIN_REGISTRY" > "${PLUGIN_REGISTRY}.tmp" && mv "${PLUGIN_REGISTRY}.tmp" "$PLUGIN_REGISTRY"
    done
}

auto_discover_plugins() {
    log_info "Scanning for auto-registrable plugins..."
    
    # Discover shell scripts in auto_registered directory
    find "$AUTO_REGISTER_DIR" -name "*.sh" -type f | while read -r plugin; do
        local plugin_name=$(basename "$plugin" .sh)
        register_plugin "$plugin_name" "$plugin" "auto"
    done
    
    # Discover Python modules
    find "$AUTO_REGISTER_DIR" -name "*.py" -type f | while read -r plugin; do
        local plugin_name=$(basename "$plugin" .py)
        register_plugin "$plugin_name" "$plugin" "python"
    done
}

register_plugin() {
    local name="$1" path="$2" type="$3"
    
    jq --arg name "$name" --arg path "$path" --arg type "$type" --arg version "1.0.0" \
        '.auto_registered[$name] = {path: $path, type: $type, version: $version, registered: "'$(date -Iseconds)'"}' \
        "$PLUGIN_REGISTRY" > "${PLUGIN_REGISTRY}.tmp" && mv "${PLUGIN_REGISTRY}.tmp" "$PLUGIN_REGISTRY"
    
    log_success "Auto-registered plugin: $name"
}

activate_plugins() {
    log_info "Activating registered plugins..."
    
    local active_count=$(jq -r '.plugins | keys[]' "$PLUGIN_REGISTRY" | wc -l)
    local auto_count=$(jq -r '.auto_registered | keys[]' "$PLUGIN_REGISTRY" | wc -l)
    
    log_success "Activated $active_count core plugins + $auto_count auto-registered plugins"
}

plugin_invoke() {
    local plugin_name="$1" action="$2" parameters="$3"
    
    local plugin_info=$(jq -r ".plugins[\"$plugin_name\"] // .auto_registered[\"$plugin_name\"]" "$PLUGIN_REGISTRY")
    
    if [[ "$plugin_info" != "null" ]]; then
        local plugin_path=$(echo "$plugin_info" | jq -r '.path')
        local plugin_type=$(echo "$plugin_info" | jq -r '.type')
        
        case "$plugin_type" in
            "core")
                source "$plugin_path"
                ;;
            "auto"|"shell")
                bash "$plugin_path" "$action" "$parameters"
                ;;
            "python")
                python3 "$plugin_path" "$action" "$parameters"
                ;;
        esac
    else
        log_error "Plugin not found: $plugin_name"
    fi
}

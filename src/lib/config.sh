#!/bin/bash
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        export STORE_URL=$(jq -r '.store_url // "http://localhost:9000"' "$CONFIG_FILE")
        export API_KEY=$(jq -r '.api_key // ""' "$CONFIG_FILE")
        export SD_WEBUI_URL=$(jq -r '.sd_webui_url // "http://localhost:7860"' "$CONFIG_FILE")
        export OLLAMA_URL=$(jq -r '.ollama_url // "http://localhost:11434"' "$CONFIG_FILE")
        export DATABASE_URL=$(jq -r '.database_url // "postgresql://localhost:5432/risn"' "$CONFIG_FILE")
        export REDIS_URL=$(jq -r '.redis_url // "redis://localhost:6379"' "$CONFIG_FILE")
        export ENABLE_AUTO_HEAL=$(jq -r '.enable_auto_heal // "false"' "$CONFIG_FILE")
        export CANARY_ENABLED=$(jq -r '.canary_enabled // "true"' "$CONFIG_FILE")
    else
        export STORE_URL="http://localhost:9000"
        export SD_WEBUI_URL="http://localhost:7860"
        export OLLAMA_URL="http://localhost:11434"
        export DATABASE_URL="postgresql://localhost:5432/risn"
        export REDIS_URL="redis://localhost:6379"
        export ENABLE_AUTO_HEAL="false"
        export CANARY_ENABLED="true"
    fi
    if [[ -f "$RISN_HOME/.env" ]]; then
        set -a
        source "$RISN_HOME/.env"
        set +a
    fi
}
save_config() {
    jq -n --arg store_url "$STORE_URL" --arg sd_webui_url "$SD_WEBUI_URL" --arg ollama_url "$OLLAMA_URL" \
        --arg database_url "$DATABASE_URL" --arg redis_url "$REDIS_URL" \
        --arg enable_auto_heal "$ENABLE_AUTO_HEAL" --arg canary_enabled "$CANARY_ENABLED" \
        '{store_url: $store_url, sd_webui_url: $sd_webui_url, ollama_url: $ollama_url, database_url: $database_url, redis_url: $redis_url, enable_auto_heal: $enable_auto_heal, canary_enabled: $canary_enabled}' > "$CONFIG_FILE"
    log_audit "INFO" "config" "Configuration saved"
}

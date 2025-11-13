#!/bin/bash
init_command() {
    local connect_path=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            --connect) connect_path="$2"; shift 2 ;;
            --help|-h) show_init_help; return 0 ;;
            *) shift ;;
        esac
    done
    log_audit "INFO" "init" "Initializing RISN CLI environment"
    if [[ -n "$connect_path" ]]; then
        [[ -f "$connect_path" ]] || [[ -d "$connect_path" ]] && setup_store_connection "$connect_path" || log_audit "ERROR" "init" "Store path not found"
    else
        scaffold_store_connector
    fi
    health_check "api" && health_check "database"
    log_audit "SUCCESS" "init" "RISN CLI initialization completed"
}
setup_store_connection() {
    local path="$1"
    if [[ -f "$path/package.json" ]] && grep -q "medusa" "$path/package.json"; then
        log_audit "INFO" "init" "Detected Medusa store"
        configure_medusa_store "$path"
    else
        log_audit "WARN" "init" "Unknown store type, using generic configuration"
    fi
}
configure_medusa_store() {
    local path="$1"
    export STORE_URL="http://localhost:9000"
    save_config
    log_audit "INFO" "init" "Medusa store configured at $path"
}
scaffold_store_connector() {
    cat > "$RISN_HOME/store-connector.js" << 'EOL'
const axios = require('axios');
class RISNStoreConnector {
    constructor(config) {
        this.baseURL = config.store_url;
        this.apiKey = config.api_key;
        this.client = axios.create({
            baseURL: this.baseURL,
            headers: {
                'Authorization': `Bearer ${this.apiKey}`,
                'Content-Type': 'application/json'
            }
        });
    }
    async createProduct(productData) {
        try {
            const response = await this.client.post('/admin/products', productData);
            return response.data;
        } catch (error) {
            throw new Error(`Product creation failed: ${error.message}`);
        }
    }
}
module.exports = RISNStoreConnector;
EOL
    log_audit "INFO" "init" "Store connector scaffolded"
}
show_init_help() {
    cat << EOL
Initialize RISN CLI environment

Usage: risn init [options]

Options:
  --connect <path>    Connect to existing store directory or configuration file
  --help, -h         Show this help message
EOL
}

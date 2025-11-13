#!/bin/bash
memory_command() {
    local operation="$1"
    shift
    
    case "$operation" in
        "store")
            memory_store_command "$@"
            ;;
        "recall")
            memory_recall_command "$@"
            ;;
        "evolve")
            memory_evolve_command "$@"
            ;;
        "status")
            memory_status_command "$@"
            ;;
        --help|-h)
            show_memory_help
            return 0
            ;;
        *)
            log_error "Unknown memory operation: $operation"
            return 1
            ;;
    esac
}

memory_store_command() {
    local key="" data="{}" embedding="default"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --key)
                key="$2"
                shift 2
                ;;
            --data)
                data="$2"
                shift 2
                ;;
            --embedding)
                embedding="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$key" ]] && log_error "Memory key is required" && return 1
    
    memory_store "$key" "$data" "$embedding"
    log_success "Stored in AI memory: $key"
}

memory_recall_command() {
    local query=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --query)
                query="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$query" ]] && log_error "Recall query is required" && return 1
    
    local results=$(memory_recall "$query")
    echo "🧠 Memory Recall Results:"
    echo "$results" | jq .
}

memory_evolve_command() {
    local pattern="" insight=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --pattern)
                pattern="$2"
                shift 2
                ;;
            --insight)
                insight="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    [[ -z "$pattern" ]] && log_error "Pattern key is required" && return 1
    
    memory_evolve "$pattern" "$insight"
    log_success "Evolved learning pattern: $pattern"
}

memory_status_command() {
    local vector_count=$(jq -r 'length' "$VECTOR_STORE" 2>/dev/null || echo "0")
    local context_count=$(jq -r 'length' "$CONTEXT_CACHE" 2>/dev/null || echo "0")
    local pattern_count=$(jq -r 'length' "$LEARNING_LOOPS" 2>/dev/null || echo "0")
    
    echo "🎭 AI Memory System Status:"
    echo "   Vector Memories: $vector_count"
    echo "   Context Caches: $context_count" 
    echo "   Learning Patterns: $pattern_count"
    echo "   Total Memories: $((vector_count + context_count + pattern_count))"
}

show_memory_help() {
    cat << EOL
Manage the AI memory system for continuous learning

Usage: risn memory <operation> [options]

Operations:
  store     Store new memories with embeddings
  recall    Retrieve memories using semantic search
  evolve    Update learning patterns with new insights
  status    Show memory system statistics

Store Options:
  --key <name>        Unique memory identifier (required)
  --data <json>       Memory data content
  --embedding <type>  Embedding type for semantic search

Recall Options:
  --query <text>      Semantic search query (required)

Evolve Options:
  --pattern <name>    Learning pattern to evolve (required)
  --insight <text>    New insight or learning

Examples:
  risn memory store --key "user_preference" --data '{"style": "minimalist"}'
  risn memory recall --query "minimalist fashion"
  risn memory evolve --pattern "design_trends" --insight "rising_interest_sustainability"
EOL
}

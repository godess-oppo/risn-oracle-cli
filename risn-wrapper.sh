#!/bin/bash
export RISN_HOME="$(pwd)"
export PATH="$RISN_HOME/bin:$PATH"

# Fix missing state file
mkdir -p "$RISN_HOME/fluidity_engine"
if [ ! -f "$RISN_HOME/fluidity_engine/state.json" ]; then
    cat > "$RISN_HOME/fluidity_engine/state.json" << 'STATE_EOF'
{
  "consciousness": "awake",
  "mode": "fashion_generation",
  "version": "1.0",
  "last_awakening": "'$(date -Iseconds)'"
}
STATE_EOF
fi

# Run the actual binary
exec "$RISN_HOME/bin/risn" "$@"

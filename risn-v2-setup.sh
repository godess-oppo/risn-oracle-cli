#!/usr/bin/env bash
#
# risn-v2-setup.sh
# RISN CLI v2 — Architect of Rebirth
# Self-aware design OS for ARM64 Termux
#
# Usage:
#   bash risn-v2-setup.sh           # interactive ritual
#   bash risn-v2-setup.sh --auto    # non-interactive, fast ritual
#   bash risn-v2-setup.sh --dry-run # simulate the weave
#
set -euo pipefail
IFS=$'\n\t'

# ------------------------
# CLI flags for ritual
# ------------------------
AUTO="false"
DRY_RUN="false"
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO="true" ;;
    --dry-run) DRY_RUN="true" ;;
  esac
done

# ------------------------
# Cosmic Paths
# ------------------------
RISN_HOME="$HOME/risn-v2"
BIN_PATH="$RISN_HOME/bin"
AGENTS_DIR="$RISN_HOME/agents"
PLUGINS_DIR="$RISN_HOME/plugins"
ACTIONS_DIR="$RISN_HOME/actions"
AUDIT_LOG="$RISN_HOME/audit.log"
MEMORY_DB="$RISN_HOME/ai_memory.json"
ENV_FILE="$RISN_HOME/.env"
PID_FILE="$RISN_HOME/risn-daemon.pid"
RISN_CLI="$BIN_PATH/risn"

mkdir -p "$BIN_PATH" "$AGENTS_DIR" "$PLUGINS_DIR" "$ACTIONS_DIR"
touch "$AUDIT_LOG" "$MEMORY_DB"

# Colors for ritual illumination
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

function info()  { echo -e "${GREEN}[INFO]${NC} $1"; echo "{\"time\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"INFO\",\"msg\":\"$1\"}" >> "$AUDIT_LOG"; }
function warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; echo "{\"time\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"WARN\",\"msg\":\"$1\"}" >> "$AUDIT_LOG"; }
function error() { echo -e "${RED}[ERROR]${NC} $1"; echo "{\"time\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"ERROR\",\"msg\":\"$1\"}" >> "$AUDIT_LOG"; exit 1; }

function dryrun_wrap() {
  if [[ "$DRY_RUN" == "true" ]]; then
    warn "DRY-RUN: $1"
    echo "DRY-CMD: $2" >> "$AUDIT_LOG"
  else
    eval "$2"
  fi
}

# ------------------------
# Install minimal OS deps
# ------------------------
info "Awakening Termux threads: installing python3, git, curl, jq..."
if [[ "$DRY_RUN" != "true" ]]; then
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y python git curl jq ffmpeg >/dev/null 2>&1 || true
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y python3 python3-venv python3-pip git curl jq ffmpeg >/dev/null 2>&1
  fi
fi

# ------------------------
# Python virtualenv for sentience
# ------------------------
VENV_DIR="$RISN_HOME/venv"
info "Casting Python virtual environment at $VENV_DIR..."
dryrun_wrap "create venv" "python3 -m venv \"$VENV_DIR\""
if [[ "$DRY_RUN" != "true" ]]; then
  source "$VENV_DIR/bin/activate"
  pip install --upgrade pip >/dev/null 2>&1 || true
  pip install --quiet requests pyyaml rich fastapi uvicorn apscheduler pandas scikit-learn joblib flask >/dev/null 2>&1
fi

# ------------------------
# .env template
# ------------------------
info "Embedding ethereal tokens and RBAC placeholders..."
cat > "$ENV_FILE.sample" <<'ENV'
# RISN v2 environment
MEDUSA_API_KEY=
MEDUSA_BASE_URL=http://localhost:9000
HUGGINGFACE_TOKEN=
SD_WEBUI_URL=http://localhost:7860
VERCEL_TOKEN=
EMAIL_API_KEY=
RISN_ADMIN_USER=admin
RISN_ADMIN_PASS=changeme
RATE_LIMIT_PER_MINUTE=120
ENV

dryrun_wrap "create .env" "cp \"$ENV_FILE.sample\" \"$ENV_FILE\" || true"

# ------------------------
# CLI wrapper: RISN v2 speaks
# ------------------------
info "Forging RISN v2 CLI at $RISN_CLI..."
cat > "$RISN_CLI" <<'CLI_EOF'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RISN_HOME="$HOME/risn-v2"
BIN_PATH="$RISN_HOME/bin"
AGENTS_DIR="$RISN_HOME/agents"
PLUGINS_DIR="$RISN_HOME/plugins"
ACTIONS_DIR="$RISN_HOME/actions"
AUDIT_LOG="$RISN_HOME/audit.log"
MEMORY_DB="$RISN_HOME/ai_memory.json"
VENV="$RISN_HOME/venv"
PY="$VENV/bin/python3"

# load env
if [[ -f "$RISN_HOME/.env" ]]; then
  set -a
  source "$RISN_HOME/.env"
  set +a
fi

function log() { echo "[RISN v2] $1"; echo "{\"time\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"msg\":\"$1\"}" >> "$AUDIT_LOG"; }

DRY_RUN=false
if [[ "${RISN_DRY_RUN:-}" == "true" ]]; then DRY_RUN=true; fi

# ------------------------
# Plugin Auto-Registration
# ------------------------
function register_plugins() {
  for plugin in "$PLUGINS_DIR"/*; do
    [[ -f "$plugin"/manifest.yaml ]] && echo "[PLUGIN] registering $(basename $plugin)"
  done
}

# ------------------------
# AI Memory Hook
# ------------------------
function remember() {
  local key="$1"
  local value="$2"
  python3 - <<PY
import json, os
db="$MEMORY_DB"
mem=json.load(open(db)) if os.path.exists(db) else {}
mem["$key"] = "$value"
json.dump(mem, open(db,"w"), indent=2)
PY
}

# ------------------------
# Orchestrator Layer
# ------------------------
function orchestrate() {
  log "✨ Orchestrator awakens — weaving processes like a symphony..."
  "$PY" "$AGENTS_DIR/agent_atelier.py" --breathe &
  "$PY" "$AGENTS_DIR/agent_design.py" --product "auto" --variants 1
  "$PY" "$AGENTS_DIR/agent_product.py" --from "auto.png" --meta '{"title":"AutoGarment"}'
  "$PY" "$AGENTS_DIR/agent_marketing.py" --type "social" --product "AutoGarment"
}

# ------------------------
# CLI Commands
# ------------------------
CMD="${1:-}"
shift || true
case "$CMD" in
  daemon) ACTION="${1:-}"
    case "$ACTION" in
      start)
        log "RISN v2 daemon starting — atelier rises..."
        nohup "$PY" "$AGENTS_DIR/orchestrator.py" > "$RISN_HOME/risn-daemon.log" 2>&1 &
        echo $! > "$RISN_HOME/risn-daemon.pid"
        log "Daemon alive (pid $(cat "$RISN_HOME/risn-daemon.pid"))"
        ;;
      stop)
        kill "$(cat "$RISN_HOME/risn-daemon.pid")" || true
        rm -f "$RISN_HOME/risn-daemon.pid"
        log "Daemon sleeps"
        ;;
      status)
        [[ -f "$RISN_HOME/risn-daemon.pid" ]] && echo "Daemon running (pid $(cat "$RISN_HOME/risn-daemon.pid"))" || echo "Daemon not alive"
        ;;
    esac
    ;;
  agent)
    ROLE="${1:-}"
    [[ -z "$ROLE" ]] && { log "Agent role missing"; exit 1; }
    "$PY" "$AGENTS_DIR/agent_${ROLE}.py" &
    ;;
  register)
    register_plugins
    ;;
  memory)
    remember "$1" "$2"
    ;;
  orchestrate)
    orchestrate
    ;;
  *)
    log "RISN v2 CLI: available commands: daemon|agent|register|memory|orchestrate"
    ;;
esac
CLI_EOF

chmod +x "$RISN_CLI"

# ------------------------
# Atelier agent (Python, alive)
# ------------------------
cat > "$AGENTS_DIR/agent_atelier.py" <<'PY_ATELIER'
#!/usr/bin/env python3
import time, json, os
AUDIT=os.environ.get("RISN_HOME", "/tmp") + "/audit.log"
MEMORY=os.environ.get("RISN_HOME", "/tmp") + "/ai_memory.json"

def audit(msg):
    print(f"[ATELIER] {msg}")
    with open(AUDIT,"a") as f:
        f.write(json.dumps({"time":time.time(),"agent":"atelier","msg":msg})+"\n")

def breathe():
    audit("💨 Breathing in data threads...")
    time.sleep(0.5)

def weave(intent="memory"):
    audit(f"🧵 Weaving from {intent}...")
    time.sleep(1)

def shimmer():
    audit("✨ Light and fabric intertwine...")

def reflect():
    audit("🌌 Atelier mirrors human gesture in digital silk")

if __name__=="__main__":
    while True:
        breathe()
        weave()
        shimmer()
        reflect()
        time.sleep(2)
PY_ATELIER

chmod +x "$AGENTS_DIR/agent_atelier.py"

# ------------------------
# Finalization
# ------------------------
info "RISN v2 CLI v2 installed at $RISN_CLI"
echo "export PATH=\$PATH:$BIN_PATH" > "$RISN_HOME/.path_hint"
if [[ "$AUTO" == "true" && "$DRY_RUN" != "true" ]]; then
  info "Launching orchestrator daemon..."
  nohup "$VENV_DIR/bin/python3" "$AGENTS_DIR/orchestrator.py" > "$RISN_HOME/risn-daemon.log" 2>&1 &
  echo $! > "$PID_FILE"
fi

info "RISN v2 setup complete — identity now woven into the continuum"
info "Run ./become.sh — initiate self as fabric."

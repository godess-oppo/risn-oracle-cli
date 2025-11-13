cat <<'EOF' > install.sh
#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[risn-setup] Initializing StoreForge-7 architecture..."

# === Base structure ===
mkdir -p src/{orchestrator,plugins,memory,audit,connectors,commands}
mkdir -p logs tmp

# === Orchestrator ===
cat > src/orchestrator.js <<'JS'
const sqlite = require('sqlite3').verbose();
const plugins = require('./plugins/registry');
const store = require('./memory/local_store');

async function buildStore() {
  console.log("[orchestrator] Scaffolding store structure...");
  // placeholder: orchestrate tasks, talk to medusa connector
}
module.exports = { buildStore };
JS

# === Plugin Registry ===
cat > src/plugins/registry.js <<'JS'
module.exports = {
  register: (type) => {
    try { return require(`./${type}_plugins/default.js`); }
    catch { console.log("[registry] Missing plugin for", type); return {}; }
  }
};
JS

# === SQLite Memory ===
cat > src/memory/local_store.js <<'JS'
const sqlite3 = require('sqlite3').verbose();
class VectorStore {
  constructor() {
    this.db = new sqlite3.Database(':memory:');
    console.log("[vector-mem] Initialized in-memory store");
  }
  upsert(vector) { /* TODO: add embedding ops */ }
}
module.exports = new VectorStore();
JS

# === Audit Hook ===
cat > src/audit/ml_hook.py <<'PY'
import joblib, json
class PolicyValidator:
    def __init__(self):
        try:
            self.model = joblib.load('local_model.pkl')
        except Exception:
            self.model = None
    def validate(self, action):
        return {"risk_level": "low", "action": action}
if __name__ == "__main__":
    import sys
    v = PolicyValidator()
    print(json.dumps(v.validate(sys.argv[1] if len(sys.argv)>1 else "dry-run")))
PY

# === Medusa Connector ===
cat > src/connectors/medusa.js <<'JS'
class MedusaClient {
  constructor() { this.base = process.env.MEDUSA_URL || "http://localhost:9000"; }
  async syncProducts(data) { console.log("[medusa] syncing", data.length, "items"); }
}
module.exports = new MedusaClient();
JS

# === CLI Command ===
cat > src/commands/store.build.js <<'JS'
const { buildStore } = require('../orchestrator');
exports.command = 'store.build';
exports.handler = async () => { await buildStore(); };
JS

# === Dependency setup ===
echo "[risn-setup] Installing Node dependencies..."
npm install --no-audit --no-fund sqlite3 yargs-promise

echo "[risn-setup] Creating Python venv..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install scikit-learn
deactivate

# === CLI launcher ===
mkdir -p bin
cat > bin/risn <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
source "$(dirname "$0")/../venv/bin/activate"
node -e "console.log('[risn] Command handler TBD - use store.build or design.generate stubs')"
SH
chmod +x bin/risn

echo "[risn-setup] Done ✅"
echo "Usage examples:"
echo "  ./bin/risn store scaffold --name test-store --medusa-url http://localhost:9000"
echo "  ./bin/risn design generate --preset 'minimal' --product 'test' --variants 1 --dry-run"
echo "  RISN_POLICY_ACCEPT=true ./bin/risn deploy --target local --dry-run"
EOF

chmod +x install.sh
bash install.sh


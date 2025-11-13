#!/bin/bash
set -e

echo "🔍 Detecting RISN-CLI installation..."
if [ -d "./risn-cli" ]; then
  echo "🔄 Upgrading existing risn-cli installation"
  cd ./risn-cli
else
  echo "🛠️  Scaffolding new risn-cli project"
  mkdir -p risn-cli
  cd risn-cli
fi

echo "📂 Building project structure..."
mkdir -p \
  bin \
  src/{commands,lib} \
  prompts \
  risn/{actions,memory} \
  hooks \
  ci \
  demo \
  plugins

echo "📝 Generating core application files..."

# Create executable wrapper
cat > bin/risn <<EOF
#!/bin/bash
node -r dotenv/config src/cli.js "$@"
EOF
chmod +x bin/risn

# Main CLI router
cat > src/cli.js <<EOF
#!/usr/bin/env node
/* RISN CLI - Main Entry Point */
const fs = require('fs');
const path = require('path');
const logger = require('./lib/logger');

// Command registry
const COMMANDS = {
  init: require('./commands/init'),
  store: require('./commands/store'),
  design: require('./commands/design'),
  product: require('./commands/product'),
  marketing: require('./commands/marketing'),
  deploy: require('./commands/deploy'),
  analytics: require('./commands/analytics'),
  ops: require('./commands/ops'),
  aicm: require('./commands/aicm'),
  agent: require('./commands/agent'),
  plugin: require('./commands/plugin'),
  audit: require('./commands/audit')
};

// Ensure action directory exists
if (!fs.existsSync('risn/actions')) {
  fs.mkdirSync('risn/actions', { recursive: true });
}

// Parse command
const command = process.argv[2] || '--help';
const args = process.argv.slice(3);
const dryRun = !args.includes('--policy-accept') && 
  !(process.env.RISN_POLICY_ACCEPT === 'true');

if (!COMMANDS[command]) {
  logger.info(`Usage: risn <command> [options]
Available commands:
  init       Bootstrap new RISN store
  store      Configure store settings
  design     Generate design assets
  product    Manage products
  marketing  Create marketing content
  deploy     Deployment operations
  analytics  View store analytics
  ops        System operations
  aicm       AI commit messages
  agent      Autonomous agent
  plugin     Plugin management
  audit      Audit operations`);
  process.exit(1);
}

if (dryRun) {
  logger.info('🌱 Dry-run mode (add --policy-accept to execute changes)');
}

// Execute command
COMMANDS[command]({ dryRun, args })
  .catch(err => {
    logger.error(`Command failed: ${err.message}`);
    process.exit(1);
  });
EOF

# Generate command modules
for cmd in init store design product marketing deploy analytics ops aicm agent plugin audit; do
  cat > src/commands/${cmd}.js <<EOF
/* RISN CLI - ${cmd} command */
const fs = require('fs');
const path = require('path');
const logger = require('../lib/logger');
const policy = require('../lib/policy');

module.exports = async ({ dryRun, args }) => {
  // Generate reversible action plan
  const actionPlan = {
    command: '${cmd}',
    args: args,
    timestamp: new Date().toISOString(),
    steps: [
      { action: '${cmd}_step_1', details: { status: 'pending' } },
      { action: '${cmd}_step_2', details: { status: 'pending' } }
    ],
    rollback: [
      { action: 'undo_${cmd}', details: { method: 'revert' } }
    ]
  };

  const planFile = \`risn/actions/${cmd}_${Date.now()}.json\`;
  fs.writeFileSync(planFile, JSON.stringify(actionPlan, null, 2));
  logger.info(\`📝 Generated action plan: ${planFile}\`);

  // Policy check
  const policyCheck = policy.verify('${cmd}', args);
  if (policyCheck.riskScore > 0.7 && !dryRun) {
    throw new Error(\`Policy violation: ${policyCheck.reason}\`);
  }

  if (dryRun) {
    logger.info('✅ Dry run completed successfully');
    return;
  }

  // Real execution
  logger.info('🚀 Executing live operations');
  // TODO: Implement actual ${cmd} operations
  return { status: 'completed' };
};
EOF
done

# Generate library modules
cat > src/lib/logger.js <<EOF
/* RISN Logger - Structured logging */
module.exports = {
  info: (msg) => console.log(`ℹ️  [${new Date().toISOString()}] ${msg}`),
  warn: (msg) => console.log(`⚠️  [${new Date().toISOString()}] ${msg}`),
  error: (msg) => console.log(`❌ [${new Date().toISOString()}] ${msg}`)
};
EOF

cat > src/lib/policy.js <<EOF
/* RISN Policy Engine */
module.exports = {
  verify: (command, args) => {
    // TODO: Implement actual policy checks
    const risks = {
      deploy: 0.4,
      delete: 0.8
    };
    return {
      allowed: true,
      riskScore: risks[command] || 0.2,
      reason: 'Generic policy check'
    };
  }
};
EOF

cat > src/lib/llm.js <<EOF
/* RISN LLM Integration */
/* CONFIG - Set OLLAMA_BASE_URL for local models */
const axios = require('axios');

module.exports = {
  generate: async (prompt) => {
    if (process.env.OLLAMA_BASE_URL) {
      try {
        const res = await axios.post(
          `${process.env.OLLAMA_BASE_URL}/api/generate`,
          { model: process.env.OLLAMA_MODEL || 'llama3', prompt }
        );
        return res.data.response;
      } catch (err) {
        throw new Error(`LLM request failed: ${err.message}`);
      }
    }
    return `Simulated response to: ${prompt}`;
  }
};
EOF

cat > src/lib/orchestrator.js <<EOF
/* RISN Orchestrator - Agent workflow */
const fs = require('fs');
const path = require('path');
const logger = require('./logger');

module.exports = {
  runWorkflow: async (workflow) => {
    const results = [];
    const timestamp = new Date().toISOString();

    for (const [index, agent] of workflow.entries()) {
      logger.info(`⚡ Running agent: ${agent.name}`);
      // Simulate agent execution
      const result = {
        input: agent.input || results[index-1]?.output,
        output: `${agent.name} processed result`,
        timestamp
      };
      results.push(result);
    }

    // Save action plan
    const plan = {
      workflow,
      results,
      timestamp
    };
    const planFile = `risn/actions/workflow_${Date.now()}.json`;
    fs.writeFileSync(planFile, JSON.stringify(plan, null, 2));

    return {
      finalOutput: results[results.length - 1].output,
      planFile
    };
  }
};
EOF

cat > src/lib/plugin-registry.js <<EOF
/* RISN Plugin Registry */
const fs = require('fs');
const path = require('path');

module.exports = {
  discover: () => {
    const pluginsDir = path.join(__dirname, '../../plugins');
    if (!fs.existsSync(pluginsDir)) return [];

    return fs.readdirSync(pluginsDir)
      .filter(pluginDir => {
        const manifestPath = path.join(pluginsDir, pluginDir, 'manifest.json');
        return fs.existsSync(manifestPath);
      })
      .map(pluginDir => {
        const manifest = require(path.join(pluginsDir, pluginDir, 'manifest.json'));
        return {
          name: manifest.name,
          init: () => require(path.join(pluginsDir, pluginDir, manifest.main))
        };
      });
  }
};
EOF

cat > src/lib/memory.js <<EOF
/* RISN Memory - Vector storage */
/* CONFIG: For production, set SUPABASE_URL/KEY */
const path = require('path');
const fs = require('fs');

// Initialize storage
if (!fs.existsSync('risn/memory')) {
  fs.mkdirSync('risn/memory', { recursive: true });
}

module.exports = {
  store: async (key, content) => {
    const id = Date.now();
    const data = { id, key, content };
    const file = path.join('risn/memory', `${id}_${key}.json`);
    fs.writeFileSync(file, JSON.stringify(data));
    return id;
  },
  
  query: async (query, limit = 3) => {
    // Simulate vector search
    return Array(limit).fill(0).map((_, i) => ({
      id: i,
      key: query,
      content: `Sample result ${i} for "${query}"`,
      score: 1 - (i * 0.1)
    }));
  }
};
EOF

cat > src/lib/medusa-connector.js <<EOF
/* RISN Medusa Integration */
/* CONFIG: Set MEDUSA_API_URL and API_KEY in .env */
const axios = require('axios');
const logger = require('./logger');

module.exports = {
  pushProduct: async (product) => {
    const baseUrl = process.env.MEDUSA_API_URL || 'http://localhost:9000';
    try {
      const res = await axios.post(
        `${baseUrl}/admin/products`,
        product,
        {
          headers: {
            'Authorization': `Bearer ${process.env.MEDUSA_API_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );
      logger.info(`Product ${product.title} created`);
      return res.data;
    } catch (err) {
      logger.error(`Medusa API error: ${err.message}`);
      throw err;
    }
  }
};
EOF

cat > src/lib/audit-hook.js <<EOF
/* RISN Audit Hook - Safety checks */
const fs = require('fs');
const path = require('path');
const logger = require('./logger');

// Initialize audit log
if (!fs.existsSync('risn/audit.log')) {
  fs.writeFileSync('risn/audit.log', '');
}

module.exports = {
  checkContent: (content) => {
    // Simulate risk assessment
    const riskScore = Math.random();
    const blocked = content.includes('unsafe') || riskScore > 0.7;
    
    const entry = {
      timestamp: new Date().toISOString(),
      contentHash: require('crypto')
        .createHash('sha256')
        .update(content)
        .digest('hex'),
      riskScore,
      blocked,
      reason: blocked ? 'Potential policy violation' : null
    };

    fs.appendFileSync(
      'risn/audit.log',
      JSON.stringify(entry) + '\n'
    );

    if (blocked && !process.env.RISN_POLICY_ACCEPT) {
      throw new Error('Content blocked by audit policy');
    }

    return entry;
  }
};
EOF

# Generate prompt templates
cat > prompts/design.json <<EOF
{
  "system": "You are RISN's Design AI. Create sustainable fashion designs that embody resilience and adaptability.",
  "parameters": {
    "color_palette": ["earth tones", "bold accents"],
    "materials": ["organic cotton", "recycled polyester"],
    "requirements": ["modular components", "easy care"]
  },
  "examples": [
    {
      "input": "design a versatile jacket",
      "output": {
        "name": "Adaptive Shell Jacket",
        "features": ["removable hood", "zip-off sleeves"],
        "materials": ["recycled nylon"]
      }
    }
  ]
}
EOF

cat > prompts/marketing.json <<EOF
{
  "system": "You are RISN's Marketing AI. Create ethical promotional content focused on product benefits.",
  "guidelines": [
    "Avoid hyperbole",
    "Highlight sustainability features",
    "Include care instructions"
  ],
  "formats": {
    "social": "max 120 characters",
    "description": "50-100 words"
  }
}
EOF

cat > prompts/devops.json <<EOF
{
  "system": "You are RISN's DevOps AI. Generate safe deployment plans with rollback procedures.",
  "requirements": [
    "Zero-downtime deploys",
    "Environment parity",
    "Automated rollback"
  ],
  "output": {
    "steps": [],
    "verification": [],
    "rollback": []
  }
}
EOF

cat > prompts/audit.json <<EOF
{
  "system": "You are RISN's Audit AI. Identify potential content issues before publication.",
  "checks": [
    "Brand consistency",
    "Regulatory compliance",
    "Cultural sensitivity"
  ],
  "risk_levels": {
    "low": "0-0.3",
    "medium": "0.4-0.6", 
    "high": "0.7-1.0"
  }
}
EOF

cat > prompts/policy.json <<EOF
{
  "brand_values": ["resilience", "adaptability", "sustainability"],
  "automation_limits": {
    "max_autonomous_steps": 3,
    "critical_approvals": ["publish", "delete"]
  },
  "risk_thresholds": {
    "warning": 0.6,
    "block": 0.8
  }
}
EOF

# Generate supporting files
cat > hooks/prepare-commit-msg.example <<EOF
#!/bin/sh
# RISN AICM Hook Example
if [ -z "$RISN_AICM_DISABLED" ]; then
  risn aicm --msg-file="$1" --commit-source="$2"
fi
EOF

cat > ci/github-actions.yml <<EOF
name: RISN CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: risn audit --check
      - run: risn test

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: risn deploy --policy-accept
EOF

cat > .env.example <<EOF
# RISN Configuration
MEDUSA_API_URL=http://localhost:9000
MEDUSA_API_KEY=your_admin_key

# AI Configuration
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3

# Policy Controls
RISN_POLICY_ACCEPT=false
RISN_AUDIT_STRICT=true

# Optional Supabase
# SUPABASE_URL=
# SUPABASE_KEY=
EOF

cat > README.md <<EOF
# RISN CLI v2

## Store Builder Engine for RISN Fashion

### Features
- 🏗️ Medusa-backed store scaffolding
- 🤖 AI-assisted design & marketing
- 🔒 Policy-enforced safety controls
- 📊 Built-in audit system

### Quick Start

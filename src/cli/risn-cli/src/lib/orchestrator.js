// RISN Orchestrator
// Chain agents, run safety checks, create reversible action plans
const fs = require('fs');
const path = require('path');
const llm = require('./llm');
const logger = require('./logger');
const auditHook = require('./audit-hook');

function runChain(agents, argv) {
  const chainId = `chain_${agents.join('_')}_${Date.now()}`;
  console.log(`[orchestrator] Chain ID: ${chainId}`);
  
  const results = [];
  
  agents.forEach((agent, idx) => {
    console.log(`  [${idx + 1}/${agents.length}] ${agent}...`);
    
    if (agent === 'audit') {
      // Run content audit on previous outputs
      const prevContent = results.map(r => r.response).join(' ');
      const auditResult = auditHook.checkContent(prevContent, argv);
      results.push({ agent, result: auditResult });
      
      if (!auditResult.safe) {
        console.log(`    ⚠️  Audit flagged unsafe content`);
      } else {
        console.log(`    ✓ Audit passed`);
      }
    } else {
      // Execute agent via LLM
      const prompt = loadPrompt(agent);
      const result = llm.query(prompt, { dryRun: argv['dry-run'] });
      results.push({ agent, result });
      console.log(`    ✓ Completed`);
    }
    
    logger.log('orchestrator', { chainId, agent, step: idx + 1 });
  });
  
  const plan = {
    chainId,
    agents,
    timestamp: new Date().toISOString(),
    results,
    status: 'completed'
  };
  
  writeReversiblePlan(chainId, plan);
  return plan;
}

function loadPrompt(agentType) {
  const promptPath = path.join(__dirname, '../../prompts', `${agentType}.json`);
  if (fs.existsSync(promptPath)) {
    const promptData = JSON.parse(fs.readFileSync(promptPath, 'utf8'));
    return promptData.prompt || `Execute ${agentType} task`;
  }
  return `Execute ${agentType} agent task`;
}

function writeReversiblePlan(name, plan) {
  const sanitizedName = name.replace(/[^a-z0-9_-]/gi, '_');
  const filename = path.join(process.cwd(), 'risn/actions', `${sanitizedName}.json`);
  fs.mkdirSync(path.dirname(filename), { recursive: true });
  fs.writeFileSync(filename, JSON.stringify(plan, null, 2));
  return filename;
}

module.exports = { runChain, writeReversiblePlan, loadPrompt };

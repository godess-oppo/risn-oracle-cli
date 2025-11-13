// RISN Orchestrator
// Chain agents: Design → Marketing → Ethics → Deploy
const fs = require('fs');
const path = require('path');
const llm = require('./llm');
const logger = require('./logger');

function runChain(agents, argv) {
  console.log(`[orchestrator] Running agent chain: ${agents.join(' → ')}`);
  
  agents.forEach(agent => {
    console.log(`  [${agent}] Processing...`);
    const result = llm.query(`Execute ${agent} task`, { dryRun: argv['dry-run'] });
    logger.log('orchestrator', { agent, result });
  });
  
  const plan = {
    chain: agents,
    timestamp: new Date().toISOString(),
    status: 'completed'
  };
  
  writeReversiblePlan(`chain_${agents.join('_')}`, plan);
}

function writeReversiblePlan(name, plan) {
  const filename = path.join(process.cwd(), 'risn/actions', `${name}_${Date.now()}.json`);
  fs.mkdirSync(path.dirname(filename), { recursive: true });
  fs.writeFileSync(filename, JSON.stringify(plan, null, 2));
  console.log(`[orchestrator] Plan written: ${filename}`);
}

module.exports = { runChain, writeReversiblePlan };

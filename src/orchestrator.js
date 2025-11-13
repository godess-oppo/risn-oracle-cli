const sqlite = require('sqlite3').verbose();
const plugins = require('./plugins/registry');
const store = require('./memory/local_store');

async function buildStore() {
  console.log("[orchestrator] Scaffolding store structure...");
  // placeholder: orchestrate tasks, talk to medusa connector
}
module.exports = { buildStore };

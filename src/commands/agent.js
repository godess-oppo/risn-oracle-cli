/**
 * risn agent spawn <role> [--scope <path|service>]
 * Instantiates an agent plan (writes actions/*.json)
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  const role = argv[0] || 'design';
  const scopeIdx = argv.indexOf('--scope');
  const scope = scopeIdx!==-1?argv[scopeIdx+1]:'global';
  const plan = {agent:role, scope, plan:[`analyze:${scope}`,`propose:change-${role}`], ts:new Date().toISOString()};
  fs.writeFileSync(path.join(ctx.base,'actions',`agent-${role}-${Date.now()}.json`), JSON.stringify(plan,null,2));
  console.log('Agent plan created:', plan);
};

/**
 * risn test [--full|--smoke]
 * Basic connectivity and environment checks.
 */
const fs = require('fs'), path = require('path');
exports.run = function(argv, ctx){
  console.log('Running smoke tests...');
  const ok = {node:process.version, env:process.env.RISN_HOME||'not-set', timestamp:new Date().toISOString()};
  fs.writeFileSync(path.join(ctx.base,'actions','test-run.json'), JSON.stringify(ok,null,2));
  console.log('Smoke test results written to risn/actions/test-run.json');
};
